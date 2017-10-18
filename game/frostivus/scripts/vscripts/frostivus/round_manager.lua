_G.g_DEFAULT_ORDER_TIME_LIMIT = 60

GameRules.vRoundDefinations = LoadKeyValues('scripts/kv/rounds.kv')
for level, data in pairs(GameRules.vRoundDefinations) do
	GameRules.vRoundDefinations[tonumber(level)] = data
end
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

	self.nPreRoundTime = 5
	self.nEndRoundDelay = 5
	
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
						pszItemName = recipeName,
						pszID = DoUniqueString("order")
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

	-- time's up
	if self.nCountDownTimer <= 0 then

		if self.vRoundScript.OnRoundEnd then
			self.vRoundScript.OnRoundEnd(self)
		end

		-- @todo clear everything created in this round
		-- I have to know what may happen in rounds 
		-- to finish this

		-- @todo show round end summary

		-- tell the round manager to start a new round after delay
		Timers:CreateTimer(self.nEndRoundDelay, function()
			GameRules.RoundManager:OnRoundEnd()
		end)

	end

	-- time for more orders
	for t, orders in pairs(self.vPendingOrders) do
		if tonumber(t) <= self.nExpiredTime then
			for recipeName, orderCount in pairs(orders) do
				for i = 1, orderCount do
					table.insert(self.vCurrentOrders, {
						nTimeRemaining = g_DEFAULT_ORDER_TIME_LIMIT,
						pszItemName = recipeName,
						pszID = DoUniqueString("order")
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
		self.vCurrentOrders[orderIndex] = nil
		self:UpdateOrdersToClient()

		local itemPhysical = itemEntity:GetContainer()
		if itemPhysical then
			UTIL_Remove(itemPhysical)
		end

		-- play sound
		EmitGlobalSound("ui.treasure_reveal")
	else
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


if IsInToolsMode() then
	Convars:RegisterCommand("debug_start_round",function(_, level)
		if level == nil then
			level = GameRules.RoundManager:GetCurrentLevel() + 1
		end
		GameRules.RoundManager:StartNewRound(tonumber(level))
	end,"jump to a certain round and start",FCVAR_CHEAT)
end