local LEVEL_CAMERA_TARGET = Vector(-192, -2240, 1100)
local LICH_ROAM_POSITION_1 = Vector(646.906, -2459.08, -113.283)
local LICH_ROAM_POSITION_2 = Vector(646.906, -1961.44, -113.283)

local LICH_IDLE_TIME = 10.0

local lich
local lich_movement_timer
local lich_cast_timer

local function CastChain(  )
	EmitAnnouncerSoundForTeam("lich_lich_ability_chain_09", 2)
	lich_cast_timer = Timers:CreateTimer(1.0, function (  )
		local chain = lich:FindAbilityByName("frostivus_chain_frost")
		local target = GetRandomElement(HeroList:GetAllHeroes(), function ( v )
			return v:IsControllableByAnyPlayer()
		end)
		lich:CastAbilityOnTarget(target, chain, -1)
	end)
end

local function CastShards(  )
	EmitAnnouncerSoundForTeam("lich_lich_ability_chain_06", 2)
	lich_cast_timer = Timers:CreateTimer(2.0, function (  )
		local shards = lich:FindAbilityByName("frostivus_ice_shards")
		lich:CastAbilityOnPosition(lich:GetAbsOrigin() + Vector(-950,0,0), shards, -1)
	end)
end

local function Roam(  )
	local chain = lich:FindAbilityByName("frostivus_chain_frost")
	local shards = lich:FindAbilityByName("frostivus_ice_shards")

	lich_movement_timer = Timers:CreateTimer(function (  )
		lich:PatrolToPosition(LICH_ROAM_POSITION_1)

		if shards:IsCooldownReady() then
			if math.random(1,5) == 1 and chain:IsCooldownReady() then
				CastChain()
			else
				CastShards()
			end
			lich_movement_timer = nil
		else
			return LICH_IDLE_TIME
		end
	end)
end

return {
	OnInitialize = function(round)
		-- in initialize script, setup round parameters
		-- such as pre round time, time limit, etc.
		print("RoundScript -> OnInitialize")
	end,
	OnTimer = function(round)
	end,
	OnPreRoundStart = function(round)
		print("RoundScript -> OnPreRoundStart")

		StopMainTheme()
		
		Frostivus:ResetStage( LEVEL_CAMERA_TARGET )

		local i = 1
		for k,v in pairs(Frostivus.state.stages["palace"].crates) do
			local item = Frostivus.StagesKVs["palace"].Initial[tostring(i)]
			Frostivus:L(item)
			if item then
				v:InitBench(1)
				v:SetCrateItem(item)
			else

			end
			i = i + 1
		end

		lich = lich or CreateUnitByName("npc_lich", LICH_ROAM_POSITION_2, true, nil, nil, DOTA_TEAM_BADGUYS)
		lich:SetTeam(DOTA_TEAM_BADGUYS)
		FindClearSpaceForUnit(lich, LICH_ROAM_POSITION_2, true)
		lich:SetForwardVector(Vector(-1,0,0))

		lich:AddNewModifier(lich, nil, "modifier_hide_health_bar", {})
		lich:AddNewModifier(lich, nil, "modifier_unselectable", {})

		LoopOverHeroes(function(hero)
			hero:SetCameraTargetPosition(LEVEL_CAMERA_TARGET)
		end)
	end,
	OnRoundStart = function(round)
		print("RoundScript -> OnRoundStart")

		StartMainThemeAtPosition(LEVEL_CAMERA_TARGET)

		Timers:CreateTimer(67, function()
			if round.nCountDownTimer > 0 then
				StartMainThemeAtPosition(LEVEL_CAMERA_TARGET)
				return 67
			end
		end)

		local chain = lich:FindAbilityByName("frostivus_chain_frost")
		local shards = lich:FindAbilityByName("frostivus_ice_shards")

		chain:StartCooldown(LICH_IDLE_TIME-1)
		shards:StartCooldown(LICH_IDLE_TIME-1)

		Roam()
	end,
	OnRoundEnd = function(round)
		-- if you do something special, clean them
		print("RoundScript -> OnRoundEnd")

		Timers:RemoveTimer(lich_movement_timer)
		Timers:RemoveTimer(lich_cast_timer)
	end,
	OnOrderExpired = function(round, order)
		-- @param order, table
		-- keys:
		--    nTimeRemaining
		--    pszItemName the name of the recipe
		print("RoundScript -> OnOrderExpired")
	end,
}