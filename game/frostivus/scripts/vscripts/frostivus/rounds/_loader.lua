if Round == nil then Round = class({}) end

GameRules.vRoundDefinations = LoadKeyValues('kv/rounds.kv')

LinkLuaModifier("modifier_preround_freeze","frostivus/modifiers/states.lua",LUA_MODIFIER_MOTION_NONE)

function Round:constructor(roundData)
	self.vRoundData = roundData
	self.vPendingOrders = roundData.Orders
	self.nTimeLimit = roundData.TimeLImit

	self.vRoundScript =  {}
	if roundData.ScriptFile then
		self.vRoundScript = require(roundData.ScriptFile)
	end

	self.vFinishedOrders = {}
	self.vCurrentOrders = {}
	self.nPreRoundTime = 10 -- time till next round starts
	
	if self.vRoundScript.OnInitialize then
		self.vRoundScript.OnInitialize(self)
	end
end

function Round:OnTimer()
	-- count down pre round time
	if self.nPreRoundCountDownTimer == nil then
		self.nPreRoundCountDownTimer = self.nPreRoundTime

		LoopOverHeroes(function(hero)
			hero:RespawnHero(false,false,false)
			hero:AddNewModifier(hero,nil,"modifier_preround_freeze",{})
		end)

		-- on pre round start, show initial recipes
		if self.vPendingOrders[0] then
			local orders = self.vPendingOrders[0]
			for recipeName, orderCount in pairs(orders) do
				for i = 1, orderCount do
					table.insert(self.vCurrentOrders, {
						nTimeRemaining = g_DEFAULT_ORDER_TIME_LIMIT,
						pszItemName = recipeName
					})
				end
			end
			self.vPendingOrders[0] = nil
		end
		if self.vRoundScript.OnPreRoundStart then
			self.vRoundScript.OnPreRoundStart(self)
		end
	end
	self.nPreRoundCountDownTimer = self.nPreRoundCountDownTimer - 1
	if self.nPreRoundCountDownTimer > 0 then
		-- @todo, display pre round count down on client
		return
	end

	-- ROUND START!

	if self.nCountDownTimer == nil then
		self.nCountDownTimer = self.nTimeLimit
		self.nExpiredTime = 0
		if self.vRoundScript.OnRoundStart then
			self.vRoundScript.OnRoundStart(self)
		end

		LoopOverHeroes(function(hero)
			hero:RemoveModifierByName("modifier_preround_freeze")
		end)
	end

	self.nCountDownTimer = self.nCountDownTimer - 1
	self.nExpiredTime = self.nExpiredTime + 1

	-- time's up
	if self.nCountDownTimer <= 0 then
		
		GameRules._vRoundManager:OnRoundEnd()

		if self.vRoundScript.OnRoundEnd then
			self.vRoundScript.OnRoundEnd(self)
		end

		-- @todo clear everything created in this round
		-- I have to know what may happen in rounds 
		-- to finish this

	end

	-- time for more orders
	local time = self.nExpiredTime - self.nPreRoundTime
	for t, orders in pairs(self.vPendingOrders) do
		if t <= time then
			for recipeName, orderCount in pairs(orders) do
				for i = 1, orderCount do
					table.insert(self.vCurrentOrders, {
						nTimeRemaining = g_DEFAULT_ORDER_TIME_LIMIT,
						pszItemName = recipeName,
					})
				end
			end
			self.vPendingOrders[t] = nil -- remove from pending orders
		end
	end

	-- reduce all recipe time remaining
	for k, order in pairs(self.vCurrentOrders) do
		order.nTimeRemaining = order.nTimeRemaining - 1
		if order.nTimeRemaining <= 0 then -- remove the un-finished orders
			-- @todo, punishment??
			self.vCurrentOrders[k] = nil
			self:UpdateOrdersToClient()
			if self.vRoundScript.OnRecipeExpired then
				self.vRoundScript.OnRecipeExpired(self, order)
			end
		end
	end

	if self.vRoundScript.OnTimer then
		self.vRoundScript.OnTimer(self.nExpiredTime, self.nCountDownTimer)
	end
end

function Round:OnServe(itemEntity)
	-- the item entity should be CDOTA_Item, not a CDOTA_Item_Physical
	if not itemEntity.GetContainer then
		error(debug.traceback("The param 'itemEntity' should be an CDOTA_Item"))
	end

	if self:TryServe(itemEntity) then

		-- find the order with least time left
		table.sort(self.vCurrentOrders, function(a, b) return a.nTimeRemaining < b.nTimeRemaining end)
		for k, order in pairs(self.vCurrentOrders) do
			if order.pszItemName == itemName then
				table.remove(self.vCurrentOrders, k)
				order.nFinishTime = self.nCountDownTimer
				table.insert(self.vFinishedOrders, order)
				self:UpdateOrdersToClient()
				break
			end
		end

		local itemPhysical = itemEntity:GetContainer()
		if itemPhysical then
			UTIL_Remove(itemPhysical)
		end
	else
	end
end

function Round:TryServe(itemEntity)
	-- the item entity should be CDOTA_Item, not a CDOTA_Item_Physical
	if not itemEntity.GetContainer then
		error(debug.traceback("The param 'itemEntity' should be an CDOTA_Item"))
	end

	local itemName = itemEntity:GetAbilityName()
	if table.contains(self.vCurrentOrders, itemName) then
		return true
	end

	return false
end

function Round:UpdateOrdersToClient()
	CustomNetTables:SetTableValue("orders","orders",self.vCurrentOrders)
end

function Round:_Debug_SetRoundTime(time)
	self.nCountDownTimer = time
end