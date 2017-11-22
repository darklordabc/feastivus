local LEVEL_CAMERA_TARGET = Vector(-192, -2240, 1100)
local LICH_ROAM_POSITION_1 = Vector(576, -2432, -113.283)
local LICH_ROAM_POSITION_2 = Vector(576, -1920, -113.283)

local LICH_IDLE_TIME = 9.0

local lich
local lich_movement_timer
local lich_cast_timer

function CastChain(  )
	EmitAnnouncerSoundForTeam("lich_lich_ability_chain_09", 2)
	lich:Stop()
	lich_cast_timer = Timers:CreateTimer(1.0, function (  )
		local chain = lich:FindAbilityByName("frostivus_chain_frost")
		local target = GetRandomElement(HeroList:GetAllHeroes(), function ( v )
			return v:IsControllableByAnyPlayer()
		end)
		lich:CastAbilityOnTarget(target, chain, -1)

		Timers:CreateTimer(1.0, function (  )
			Roam()
		end)
	end)
end

function CastShards()
	EmitAnnouncerSoundForTeam("lich_lich_ability_chain_06", 2)
	lich:Stop()
	-- lich:MoveToPosition(GetShardsCastPosition())
	lich_cast_timer = Timers:CreateTimer(0.5, function (  )
		-- if lich:IsIdle() then
			local shards = lich:FindAbilityByName("frostivus_ice_shards")
			lich:CastAbilityOnPosition(lich:GetAbsOrigin() + Vector(-1400,0,0), shards, -1)

			Timers:CreateTimer(1.0, function (  )
				Return(LICH_ROAM_POSITION_2)
			end)
		-- else
		-- 	return 0.03
		-- end
	end)
end

function Return(pos)
	lich_cast_timer = nil

	lich:MoveToPosition(pos)

	lich_movement_timer = Timers:CreateTimer(function (  )
		if lich:IsIdle() then
			Roam(  )
		else
			return 0.03
		end
	end)
end

function Roam()
	local chain = lich:FindAbilityByName("frostivus_chain_frost")
	local shards = lich:FindAbilityByName("frostivus_ice_shards")

	AddFOWViewer(3, LEVEL_CAMERA_TARGET, 1800, 60, false)

	lich_cast_timer = nil

	lich_movement_timer = Timers:CreateTimer(function (  )
		if shards:IsCooldownReady() then
			local greevils = FindUnitsInLine(3, lich:GetAbsOrigin(), lich:GetAbsOrigin() + (Vector(-1,0,0) * 1500), nil, 64, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
			if #greevils <= 0 or (lich:GetAbsOrigin().y > -2304 and lich:GetAbsOrigin().y < -2048) then
				return 0.2
			end
			if math.random(1,5) == 5 and chain:IsCooldownReady() then
				CastChain()
			else
				CastShards()
			end
			lich_movement_timer = nil
		else
			lich:PatrolToPosition(LICH_ROAM_POSITION_1)
			return LICH_IDLE_TIME
		end
	end)
end

function GetShardsCastPosition(  )
	local row_height = 128

	local positions = {}
	table.insert(positions, LICH_ROAM_POSITION_2)
	table.insert(positions, LICH_ROAM_POSITION_1)
	table.insert(positions, LICH_ROAM_POSITION_2 + Vector(0,(row_height * -1),0))
	table.insert(positions, LICH_ROAM_POSITION_1 + Vector(0,(row_height * 1),0))

	return positions[math.random(1,4)]
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