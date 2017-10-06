---------------------------------------------------------------------------------------
-- GLOBAL API
--=====================================================================================
-- g_TryServe(itemEntity) trying to serve an item, return true if it's a valid serve
-- this is a function for functions such as trying to put something on the serve window
-- do nothing real but validation
-- @param itemEntity CDOTA_Item
--=====================================================================================
function g_TryServe(itemEntity)
	local roundManager = GameRules._vRoundManager
	local round = roundManager:GetCurrentRound()
	if round then
		return round:TryServe(itemEntity)
	end
end

--=====================================================================================
-- g_Serve(itemEntity) trying to serve some item and make a progress
-- this function will remove the itemEntity and its container(if exists)
-- @param itemEntity CDOTA_Item
--=====================================================================================
function g_Serve(itemEntity)
	local roundManager = GameRules._vRoundManager
	local round = roundManager:GetCurrentRound()
	if round then
		local success = round:OnServe(itemEntity)
	end
end

--=====================================================================================
-- return the int level(round value), default by 0
--=====================================================================================
function g_GetLevelNumber()
	return GameRules._vRoundManager.nCurrentLevel or 0
end
---------------------------------------------------------------------------------------

if RoundManager == nil then RoundManager = class({}) end
if Round == nil then Round = class({}) end
if Order == nil then Order = class({}) end

GameRules.vRoundDefinations = LoadKeyValues('kv/rounds.kv')

function Round:constructor(roundData)
	self.vRoundData = roundData
	self.vPendingOrders = roundData.Orders
	self.nTimeLimit = roundData.TimeLImit
	self.vFinishedOrders = {}
	self.vCurrentOrders = {}
	self.nPreRoundTime = 10 -- time till next round starts
end

function Round:OnTimer()
	if self.nCountDownTimer == nil then -- initialize count down timer here so we can dynamic set pre round time
		self.nCountDownTimer = self.nTimeLimit + self.nPreRoundTime
	else
		self.nCountDownTimer = self.nCountDownTimer - 1
	end

	-- time's up
	if self.nCountDownTimer <= 0 then
		self:OnRoundEnd()
		GameRules._vRoundManager:OnRoundEnd()
	end

	-- time for more orders
	for time, orders in pairs(self.vPendingOrders) do
		-- @todo, temporary save, g2g
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
		-- not a valid serve
		-- show error?
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

function Round:SetPreRoundTime(time)
	self.nPreRoundTime = time
end

function RoundManager:constructor()
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
		self:Init()
	end
end

function RoundManager:Init()
	self.nCurrentLevel = 1
	if self.bPlayTutorial then
		self.nCurrentLevel = 0
	end
end

function RoundManager:SetPlayTutorial()
	self.bPlayTutorial = true
end

function RoundManager:StartNewRound(level) -- level is passed for test purpose
	level = level or self.nCurrentLevel
	local roundData = GameRules.vRoundDefinations[level]

	-- instantiation round
	self.vCurrentRound = Round(roundData)

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

if GameRules._vRoundManager == nil then GameRules._vRoundManager = RoundManager() end