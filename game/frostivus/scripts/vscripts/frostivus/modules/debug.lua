if DebugModule == nil then DebugModule = class({}) end

function DebugModule:constructor()
	CustomGameEventManager:RegisterListener('debug_create_greevilling',function(_, keys) self:CreateExtraGreevilling(keys) end)
	CustomGameEventManager:RegisterListener('debug_set_round_time',function(_, keys) self:SetRoundTime(keys) end)
	CustomGameEventManager:RegisterListener('debug_jump_to_round',function(_, keys) self:JumpToRound(keys) end)
	CustomGameEventManager:RegisterListener('toggle_tracking_camera',function(_, keys) self:ToggleTrackingCamera(keys) end)
	CustomGameEventManager:RegisterListener('debug_update_current_unit',function(_, keys) self:UpdateCurrentUnit(keys) end)
	CustomGameEventManager:RegisterListener('debug_start_tutorial', function(_, keys) self:ForceStartTutorial(keys) end)
	CustomGameEventManager:RegisterListener('debug_lose', function(_, keys) self:Lose(keys) end)
	CustomGameEventManager:RegisterListener('debug_try_again', function(_, keys) self:TryAgain(keys) end)
end

function DebugModule:Lose(keys)
	GameRules:SetGameWinner(3)
end

function DebugModule:TryAgain(keys)
	GameRules.RoundManager:StartNewRound(g_RoundManager.nCurrentLevel, true)
end

function DebugModule:CreateExtraGreevilling(keys)
	local playerID = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerID)
	local hero = player:GetAssignedHero()

	-- create a greevilling for the player
	local greevilling = CreateUnitByName('npc_dota_hero_axe',hero:GetOrigin() + RandomVector(200),true,player,player,hero:GetTeamNumber())
	greevilling:SetControllableByPlayer(hero:GetPlayerID(),false)

	player.vExtraGreevillings = player.vExtraGreevillings or {}
	table.insert(player.vExtraGreevillings, greevilling)
end

function DebugModule:SetRoundTime(keys)
	local time = tonumber(keys.time) or 300
	GameRules.RoundManager:GetCurrentRound():_Debug_SetRoundTime(time)
end

function DebugModule:JumpToRound(keys)
	local roundNo = tonumber(keys.round) or 1
	GameRules.RoundManager:StartNewRound(roundNo)
end

function DebugModule:ToggleTrackingCamera(keys)
	local playerID = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerID)
	local hero = player:GetAssignedHero()
	local unit = EntIndexToHScript(keys.entindex)
	if not (unit and IsValidEntity(unit)) then unit = hero end
	if player._DebugCameraTarget == nil then player._DebugCameraTarget = hero end

	if player._DebugCameraTarget == "none" then
		PlayerResource:SetCameraTarget(playerID,unit)
		player._DebugCameraTarget = unit
	else
		PlayerResource:SetCameraTarget(playerID,nil)
		player._DebugCameraTarget = "none"
	end
end

function DebugModule:UpdateCurrentUnit(keys)
	local playerID = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerID)
	local hero = player:GetAssignedHero()
	local unit = EntIndexToHScript(keys.entindex)
	if not (unit and IsValidEntity(unit)) then unit = hero end
	if not unit then return end

	if not player.vExtraGreevillings or table.count(player.vExtraGreevillings) <= 0 then return end

	if player._DebugParticle == nil then
		player._DebugParticle = ParticleManager:CreateParticleForPlayer('particles/econ/items/juggernaut/bladekeeper_healing_ward/juggernaut_healing_ward_ring_dc.vpcf',PATTACH_ABSORIGIN_FOLLOW,hero,player)
	end
	ParticleManager:SetParticleControlEnt(player._DebugParticle,0,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",unit:GetOrigin(),true)
end

function DebugModule:ForceStartTutorial(keys)
	local playerID = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerID)
	if StartPlayTutorial == nil then require 'frostivus.rounds.level_tutorial' end
	StartPlayTutorial(player)
end

if IsInToolsMode() then
	-- the debug scripts and panels will be loaded only in tools mode.
	Convars:RegisterCommand("debug_start_round",function(_, level)
		if level == nil then
			level = GameRules.RoundManager:GetCurrentLevel() + 1
		end
		GameRules.RoundManager:StartNewRound(tonumber(level))
	end,"jump to a certain round and start",FCVAR_CHEAT)

	Convars:RegisterCommand("debug_set_round_time",function(_, time)
		if time == nil then time = 100 end
		GameRules.RoundManager:GetCurrentRound():_Debug_SetRoundTime(tonumber(time))
	end,"set round time",FCVAR_CHEAT)

	Convars:RegisterCommand("show_debug_panel",function()
		CustomGameEventManager:Send_ServerToAllClients("show_debug_panel",{})
	end,"show debug panel",FCVAR_CHEAT)
end

GameRules.DebugModule = DebugModule()
