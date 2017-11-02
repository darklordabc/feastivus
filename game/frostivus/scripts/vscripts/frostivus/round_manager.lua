_G.g_DEFAULT_ORDER_TIME_LIMIT = 80

GameRules.vRoundDefinations = LoadKeyValues('scripts/kv/rounds.kv')
for level, data in pairs(GameRules.vRoundDefinations) do
	GameRules.vRoundDefinations[tonumber(level)] = data
end

LinkLuaModifier("modifier_teleport_to_new_round","frostivus/modifiers/modifier_teleport_to_new_round.lua",LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------
-- GLOBAL API
--=====================================================================================
-- g_TryServe(itemEntity) trying to serve an item, return true if it's a valid serve
-- this is a function for functions such as trying to put something on the serve window
-- do nothing real but validation
-- @param itemEntity CDOTA_Item
--=====================================================================================
function g_TryServe(itemEntity)
	local roundManager = GameRules.RoundManager
	local round = roundManager:GetCurrentRound()
	if round then
		return round:TryServe(itemEntity)
	end
end
GameRules.TryServe = g_TryServe
--=====================================================================================
-- g_Serve(itemEntity) trying to serve some item and make a progress
-- this function will remove the itemEntity and its container(if exists)
-- @param itemEntity CDOTA_Item
--=====================================================================================
function g_Serve(itemEntity)
	local round = g_GetCurrentRound()
	if round then
		local success = round:OnServe(itemEntity)
	end
end
GameRules.Serve = g_Serve
--=====================================================================================
-- g_GetCurrentOrders
--=====================================================================================
function g_GetCurrentOrders()
	if GameRules.RoundManager and GameRules.RoundManager:GetCurrentRound() then
		return GameRules.RoundManager:GetCurrentRound().vCurrentOrders
	end
end
--=====================================================================================
-- g_GetCurrentRound
--    return current Round instance
--=====================================================================================
function g_GetCurrentRound()
	return GameRules.RoundManager:GetCurrentRound()
end

--=====================================================================================
-- g_IsValidProduct
--    @param pszProductName string the product item name for validation
--=====================================================================================
function g_IsValidProduct(pszProductName)
	return g_GetCurrentRound() and g_GetCurrentRound():IsValidProduct(pszProductName) or false
end

--=====================================================================================
-- g_GetRoundTimeLeft
--    return round time left in seconds
--=====================================================================================
function g_GetRoundTimeLeft()
	local round = g_GetCurrentRound()
	if (round and round.nCountDownTimer) then
		return round.nCountDownTimer
	end
	return 0
end

--=====================================================================================
--=====================================================================================
-- the Round Class
--=====================================================================================
--=====================================================================================
if Round == nil then Round = class({}) end

LinkLuaModifier("modifier_preround_freeze","frostivus/modifiers/states.lua",LUA_MODIFIER_MOTION_NONE)

function Round:constructor(roundData)
	self.vRoundData = roundData
	
	self.vPendingOrders = {}
	for time, orderData in pairs(roundData.Orders) do
		self.vPendingOrders[tonumber(time)] = orderData
	end

	self.nTimeLimit = roundData.TimeLimit
	print("[Round] New round started, data shown below")
	print("===========================================")
	PrintTable(roundData)
	print("===========================================")

	self.vRoundScript =  {}
	if roundData.ScriptFile then
		self.vRoundScript = require(roundData.ScriptFile)
	end

	self.vFinishedOrders = {}
	self.vCurrentOrders = {}
	self:UpdateOrdersToClient() -- clear all orders of last round

	self.nPreRoundTime = 5
	self.nEndRoundDelay = 10
	
	if self.vRoundScript.OnInitialize then
		self.vRoundScript.OnInitialize(self)

		for k,v in pairs(HeroList:GetAllHeroes()) do
			if IsValidEntity(v) then
				EndAnimation(v)
				RemoveAnimationTranslate(v)

				AddAnimationTranslate(v, "level_3")

				if Frostivus:IsCarryingItem( v ) then
					Frostivus:GetCarryingItem( v ):RemoveSelf()
				end

				v:RemoveModifierByName("modifier_bench_interaction")

				v:Stop()
			end
		end
	end
end

function Round:OnTimer()
	-- count down pre round time
	if self.nPreRoundCountDownTimer == nil then
		self.nPreRoundCountDownTimer = self.nPreRoundTime

		LoopOverHeroes(function(hero)
			hero:AddNewModifier(hero,nil,"modifier_preround_freeze",{})
		end)

		-- on pre round start, show initial recipes
		if self.vPendingOrders[0] then
			local orders = self.vPendingOrders[0]
			for recipeName, orderCount in pairs(orders) do
				for i = 1, orderCount do
					table.insert(self.vCurrentOrders, {
						nTimeRemaining = g_DEFAULT_ORDER_TIME_LIMIT,
						pszItemName = recipeName,
						pszID = DoUniqueString("order"),
						nTimeLimit = g_DEFAULT_ORDER_TIME_LIMIT,
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
		
		CustomGameEventManager:Send_ServerToAllClients("set_round_name",{
			name = self.vRoundData.Name
		})

		CustomGameEventManager:Send_ServerToAllClients("pre_round_countdown",{
			value = self.nPreRoundCountDownTimer
		})
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

	-- time's up or there are no pending orders and no orders running
	-- this round is ended
	if self.nCountDownTimer <= 0 or (table.count(self.vPendingOrders) <= 0 and table.count(self.vCurrentOrders) <= 0) then
		self.nCountDownTime = 0
		self:EndRound()
	end

	-- time for more orders
	for t, orders in pairs(self.vPendingOrders) do
		if tonumber(t) <= self.nExpiredTime then
			for recipeName, orderCount in pairs(orders) do
				for i = 1, orderCount do
					table.insert(self.vCurrentOrders, {
						nTimeRemaining = g_DEFAULT_ORDER_TIME_LIMIT,
						pszItemName = recipeName,
						pszID = DoUniqueString("order"),
						nTimeLimit = g_DEFAULT_ORDER_TIME_LIMIT,
					})
				end
			end
			self.vPendingOrders[t] = nil -- remove from pending orders
		end
	end

	-- reduce all recipe time remaining
	for k, order in pairs(self.vCurrentOrders) do
		if order.pszFinishType == nil then 
			-- reduce unfinised orders only
			order.nTimeRemaining = order.nTimeRemaining - 1
		end
		if order.nTimeRemaining <= 0 then -- remove the un-finished orders
			-- @todo, punishment??
			
			-- tell client to show order finished message
			self.vCurrentOrders[k].pszFinishType = "Expired"
			Timers:CreateTimer(2, function()
				-- remove order after a short delay
				self.vCurrentOrders[k] = nil
			end)


			if self.vRoundScript.OnRecipeExpired then
				self.vRoundScript.OnRecipeExpired(self, order)
			end
		end
		self:UpdateOrdersToClient()
	end

	if self.vRoundScript.OnTimer then
		self.vRoundScript.OnTimer(self.nExpiredTime, self.nCountDownTimer)
	end

	-- update ui timer
	CustomGameEventManager:Send_ServerToAllClients("round_timer",{
		value = self.nCountDownTimer
	})
end

function Round:EndRound()

	-- show round end summary
	-- The score screen should last for about 10 seconds, gives stars, tell how many orders 
	-- they completed out of the max.
	-- Should teleport all players to the next level and start the ready set go graphic again.

	if self.bRoundEnded then return end
	self.bRoundEnded = true

	-- 1. calculate stars
	-- 
	local stars = 0
	local starCriterias = self.vRoundData.StarCriteria
	for _, criteria in pairs(starCriterias) do
		if criteria.Type == 'STAR_CRITERIA_FINISHED_RECIPES' then
			local values = string.split(criteria.values, ' ')
			for index, value in pairs(values) do
				if table.count(self.vFinishedOrders) >= tonumber(value) then
					stars = index
				end
			end
		end
		-- @todo other criterias
	end

	-- tell client to show round end summary
	CustomGameEventManager:Send_ServerToAllClients('show_round_end_summary',{
		Stars = stars,
		FinishedOrdersCount = table.count(self.vFinishedOrders),
		UnFinishedOrdersCount = table.count(self.vPendingOrders),
	})

	-- teleport particle
	Timers:CreateTimer(self.nEndRoundDelay - 2, function()
		LoopOverHeroes(function(hero)
			hero:AddNewModifier(hero,nil,"modifier_teleport_to_new_round",{})
		end)
	end)

	-- tell the round manager to start a new round after delay
	Timers:CreateTimer(self.nEndRoundDelay, function()
		GameRules.RoundManager:OnRoundEnd()
	end)
end

function Round:OnServe(itemEntity)
	-- the item entity should be CDOTA_Item, not a CDOTA_Item_Physical
	if not itemEntity.GetContainer then
		error(debug.traceback("The param 'itemEntity' should be an CDOTA_Item"))
	end

	if self:TryServe(itemEntity) then
		-- find the order with least time left
		local itemName = itemEntity:GetAbilityName()
		local orderIndex, theOrder = nil, nil
		local lowestTime = 999

		for k, order in pairs(self.vCurrentOrders) do
			if order.pszItemName == itemName and order.nTimeRemaining < lowestTime then
				orderIndex = k
				theOrder = order
				lowestTime = order.nTimeRemaining
			end
		end

		table.insert(self.vFinishedOrders, {pszItemName = itemName, nFinishTime = self.nCountDownTimer})
		-- tell client to show order finished message
		self.vCurrentOrders[orderIndex].pszFinishType = "Finished"

		Timers:CreateTimer(2, function()
			-- remove order after a short delay
			self.vCurrentOrders[orderIndex] = nil
		end)

		self:UpdateOrdersToClient()

		local itemPhysical = itemEntity:GetContainer()
		if itemPhysical then
			UTIL_Remove(itemPhysical)
		end
	end
end

function Round:TryServe(itemEntity)
	-- the item entity should be CDOTA_Item, not a CDOTA_Item_Physical
	if not itemEntity.GetContainer then
		error(debug.traceback("The param 'itemEntity' should be an CDOTA_Item"))
	end

	local itemName = itemEntity:GetAbilityName()
	for _, order in pairs(self.vCurrentOrders) do
		if order.pszItemName == itemName then
			return true
		end
	end

	return false
end

function Round:UpdateOrdersToClient()
	CustomNetTables:SetTableValue("orders","orders",self.vCurrentOrders)
end

function Round:_Debug_SetRoundTime(time)
	self.nCountDownTimer = time
end

function Round:GetCurrentOrders()
	return self.vCurrentOrders
end

function Round:IsValidProduct(pszProductName)
	for _, order in pairs(self.vCurrentOrders) do
		if order.pszItemName == pszProductName then
			return true
		end
	end
end
--=====================================================================================
--=====================================================================================
-- RoundManager
--=====================================================================================
--=====================================================================================
if RoundManager == nil then RoundManager = class({}) end


function RoundManager:constructor()
	print("RoundManager -> constructor")
	ListenToGameEvent("game_rules_state_change",Dynamic_Wrap(RoundManager, "OnGameRulesStateChanged"),self)
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("round_timer"),function()
		self:OnTimer()
		return 1
	end,1)
end

function RoundManager:OnGameRulesStateChanged()
	-- init round manager when pre game
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_PRE_GAME then
		Timers:CreateTimer(1, function()
			self:Init()
		end)
	end
end

function RoundManager:Init()
	self.nCurrentLevel = 1
	if self.bPlayTutorial then
		self.nCurrentLevel = 0
	end

	self:StartNewRound()
end

function RoundManager:OnRoundEnd()
	self.nCurrentLevel = self.nCurrentLevel + 1
	self.vCurrentRound = nil

	self:StartNewRound()
end

function RoundManager:SetPlayTutorial()
	self.bPlayTutorial = true
end

function RoundManager:StartNewRound(level) -- level is passed for test purpose
	level = level or self.nCurrentLevel

	local roundData = GameRules.vRoundDefinations[level]

	local teleport_target_entities = Entities:FindAllByName('level_' .. tostring(level) .. '_start')
	print("teleport target found", table.count(teleport_target_entities))
	local lastTeleportTarget = nil
	LoopOverHeroes(function(hero)
		-- teleport players to new round
		local teleportTarget
		if table.count(teleport_target_entities) > 0 then
			teleportTarget = table.remove(teleport_target_entities)
			teleportTarget = teleportTarget:GetOrigin()
		end

		if teleportTarget == nil then
			print("Not enough level start position entity!! moving hero to last teleport target pos")
			if lastTeleportTarget == nil then
				print("Not any level start entity found!! go check the map file")
			else
				teleportTarget = lastTeleportTarget
			end
		else
			lastTeleportTarget = teleportTarget
		end

		FindClearSpaceForUnit(hero,teleportTarget or hero:GetOrigin(),true)

		-- move all greevillings controlled by this player around the point
		local player = PlayerResource:GetPlayer(hero:GetPlayerID())
		if player.vExtraGreevillings and table.count(player.vExtraGreevillings) > 0 then
			for _, greevilling in pairs(player.vExtraGreevillings) do
				FindClearSpaceForUnit(greevilling, teleportTarget or hero:GetOrigin(), true)
			end
		end

		-- remove teleporting effect
		hero:RemoveModifierByName('modifier_teleport_to_new_round')
	end)

	-- if there is no new round, end this game
	if roundData == nil then
		-- @todo, end game!!!!
		print("there is no new round, ending game!")
		return
	end

	-- instantiation round
	self.vCurrentRound = Round(roundData)

	print("RoundManager -> New round started, level-", level)
	
	-- display round start message on clients
	CustomGameEventManager:Send_ServerToAllClients("round_start",{
		Level = level
	})
end

function RoundManager:OnTimer()
	-- this function called every second
	if self.vCurrentRound then
		self.vCurrentRound:OnTimer()
	end
end

function RoundManager:GetCurrentRound()
	return self.vCurrentRound
end

if GameRules.RoundManager == nil then GameRules.RoundManager = RoundManager() end

g_RoundManager = GameRules.RoundManager