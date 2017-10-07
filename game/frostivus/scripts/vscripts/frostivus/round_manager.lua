_G.g_DEFAULT_ORDER_TIME_LIMIT = 60

require 'frostivus/rounds/_loader'
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