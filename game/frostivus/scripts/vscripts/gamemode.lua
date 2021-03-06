-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
		DebugPrint( '[BAREBONES] creating barebones game mode' )
		_G.GameMode = class({})
end

require('libraries/timers')
require('libraries/animations')
require('libraries/playertables')
require('libraries/selection')

require('internal/gamemode')
require('internal/events')

require('settings')
require('events')

require("libraries/worldpanels")

require('frostivus/frostivus_objects')
require('frostivus/frostivus_bench_api')
require('frostivus/frostivus_event_listener')
require('frostivus/modules/move_controller')
require('frostivus/modules/hats_manager')
require('frostivus/modules/debug')
require('frostivus/modules/message_center')
require('frostivus/rounds/level_tutorial')

--[[
	This function should be used to set up Async precache calls at the beginning of the gameplay.

	In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.	These calls will be made
	after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
	be used to precache dynamically-added datadriven abilities instead of items.	PrecacheUnitByNameAsync will 
	precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
	defined on the unit.

	This function should only be called once.	If you want to/need to precache more items/abilities/units at a later
	time, you can call the functions individually (for example if you want to precache units in a new wave of
	holdout).

	This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
	DebugPrint("[BAREBONES] Performing Post-Load precache")		
	--PrecacheItemByNameAsync("item_example_item", function(...) end)
	--PrecacheItemByNameAsync("example_ability", function(...) end)

	--PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
	--PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
	This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
	It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
	DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
	This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
	It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
	DebugPrint("[BAREBONES] All Players have loaded into the game")
end

--[[
	This function is called once and only once for every player when they spawn into the game for the first time.	It is also called
	if the player's hero is replaced with a new hero for any reason.	This function is useful for initializing heroes, such as adding
	levels, changing the starting gold, removing/adding abilities, adding physics, etc.

	The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
	DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

	-- Attachments:AttachProp(hero, "attach_eye_r", "models/chefs_hat.vmdl", 0.05)
	
	table.insert(heroes, hero)

	Frostivus:InitHero(hero)
end

--[[
	This function is called once and only once when the game completely begins (about 0:00 on the clock).	At this point,
	gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.	This function
	is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
	DebugPrint("[BAREBONES] The game has officially begun")

	-- Timers:CreateTimer(30,
	-- 	function()
	-- 		DebugPrint("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
	-- 		return 30.0
	-- 	end)
end

heroes = {}

pickups = {}

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
	GameMode = self
	DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')

	Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "", FCVAR_CHEAT )
	Convars:RegisterCommand( "finish_game", Dynamic_Wrap(GameMode, 'FinishGame'), "", FCVAR_CHEAT )
	Convars:RegisterCommand( "lt", Dynamic_Wrap(GameMode, 'LastTry'), "", FCVAR_CHEAT )
	Convars:RegisterCommand( "tp", Dynamic_Wrap(GameMode, 'TestParticle'), "", FCVAR_CHEAT )

	require('frostivus/frostivus')
	require("frostivus/filters")
	require("frostivus/round_manager")

	GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( Frostivus, "FilterExecuteOrder" ), self )

	GameRules:SetCustomGameAllowHeroPickMusic( false )
	GameRules:SetCustomGameAllowBattleMusic( false )
	GameRules:SetCustomGameAllowMusicAtGameStart( false )
	GameRules:GetGameModeEntity():SetAnnouncerDisabled(true)
end

-- This is an example console command
function GameMode:ExampleConsoleCommand(item)
	print( '******* Example Console Command ***************' )
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerID = cmdPlayer:GetPlayerID()
		if playerID ~= nil and playerID ~= -1 then
			-- Do something here for the player who called this command
			CreateItemOnPositionSync(cmdPlayer:GetAssignedHero():GetAbsOrigin(),CreateItem(item or "item_refined_leaf",cmdPlayer:GetAssignedHero(),cmdPlayer:GetAssignedHero()))
		end
	end

	print( '*********************************************' )
end

function GameMode:FinishGame(team)
	print( '******* Example Console Command ***************' )
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerID = cmdPlayer:GetPlayerID()
		if playerID ~= nil and playerID ~= -1 then
			GameRules:SetGameWinner(tonumber(team))
		end
	end

	print( '*********************************************' )
end

function GameMode:LastTry()
	print( '******* Example Console Command ***************' )
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerID = cmdPlayer:GetPlayerID()
		if playerID ~= nil and playerID ~= -1 then
			GameRules.RoundManager:StartNewRound(g_RoundManager.nCurrentLevel, true)
		end
	end

	print( '*********************************************' )
end

function GameMode:TestParticle()
	print( '******* Example Console Command ***************' )
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerID = cmdPlayer:GetPlayerID()
		if playerID ~= nil and playerID ~= -1 then
			local hero = cmdPlayer:GetAssignedHero()

			if hero then
                local p = ParticleManager:CreateParticle("particles/frostivus_gameplay/fireworks.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
                ParticleManager:SetParticleControl(p, 3, hero:GetAbsOrigin() + Vector(0,0,320))
			end
		end
	end

	print( '*********************************************' )
end