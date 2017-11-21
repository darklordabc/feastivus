local LEVEL_CAMERA_TARGET = Vector(-4200, 1088, 1100)
local pangolierSpawnPositions = {
	Vector(-4288, 1536, 128),
	Vector(-4032, 1536, 128),
}

local randomScrollIntervalMin = 15
local randomScrollIntervalMax = 20

return {
	OnInitialize = function(round)
		-- in initialize script, setup round parameters
		-- such as pre round time, time limit, etc.
		print("RoundScript -> OnInitialize")
	end,
	OnTimer = function(round)
		if round.bRoundEnded then return nil end
		if round.nCountDownTimer < 20 then return nil end -- dont cast when round is about to end

		local now = GameRules:GetGameTime()
		if GameRules.__flNextPangolierScrollTime == nil then
			GameRules.__flNextPangolierScrollTime = now + RandomFloat(randomScrollIntervalMin, randomScrollIntervalMax)
		end

		if now >= GameRules.__flNextPangolierScrollTime then
			for _, pangolier in pairs(GameRules.__vPangoliers) do
				pangolier:CastAbilityNoTarget(pangolier.scrollAbility, -1)
			end
			Timers:CreateTimer(0, function()
				for _, pangolier in pairs(GameRules.__vPangoliers) do
					pangolier:CastAbilityOnPosition(pangolier:GetOrigin() + Vector(0, -400, 0), pangolier.jumpAbility, -1)
				end
			end)
			Timers:CreateTimer(2.1, function()
				for _, pangolier in pairs(GameRules.__vPangoliers) do
					pangolier:SetOrigin(pangolier.vSpawnPosition)
					pangolier:SetForwardVector(Vector(0, -1, 0))
					pangolier:StartGesture(ACT_DOTA_IDLE)
				end
			end)
			GameRules.__flNextPangolierScrollTime = now + RandomFloat(randomScrollIntervalMin, randomScrollIntervalMax)
		end
	end,
	OnPreRoundStart = function(round)
		print("RoundScript -> OnPreRoundStart")

		Frostivus:ResetStage( LEVEL_CAMERA_TARGET )

		local i = 1
		for k,v in pairs(Frostivus.state.stages["pangolier"].crates) do
			local item = Frostivus.StagesKVs["pangolier"].Initial[tostring(i)]
			Frostivus:L(item)
			if item then
				v:InitBench(1)
				v:SetCrateItem(item)
			else

			end
			i = i + 1
		end

		LoopOverHeroes(function(hero)
			hero:SetCameraTargetPosition(LEVEL_CAMERA_TARGET)
		end)

		if GameRules.__vPangoliers == nil then
			GameRules.__vPangoliers = {}
			PrecacheUnitByNameAsync("npc_dota_hero_pangolier", function()
				for _, pos in pairs(pangolierSpawnPositions) do
					local pangolier = CreateUnitByName("npc_dota_hero_pangolier", pos, false, nil, nil, DOTA_TEAM_BADGUYS)
					pangolier:AddNewModifier(pangolier, nil, "modifier_disarmed", {})
					pangolier:AddNewModifier(pangolier, nil, "modifier_hide_health_bar", {})
					pangolier.scrollAbility = pangolier:FindAbilityByName("pangolier_gyroshell")
					pangolier.scrollAbility:UpgradeAbility(false)
					pangolier.jumpAbility = pangolier:FindAbilityByName("pangolier_shield_crash")
					pangolier.jumpAbility:UpgradeAbility(false)
					pangolier.vTargetPosition = pos + Vector(0, -1500, 0)
					pangolier.vSpawnPosition = pos
					pangolier:SetForwardVector(Vector(0, -1, 0))
					table.insert(GameRules.__vPangoliers, pangolier)
				end
			end, -1)
		end
	end,
	OnRoundStart = function(round)
		print("RoundScript -> OnRoundStart")
	end,
	OnRoundEnd = function(round)
		-- if you do something special, clean them
		print("RoundScript -> OnRoundEnd")
	end,
	OnOrderExpired = function(round, order)
		-- @param order, table
		-- keys:
		--    nTimeRemaining
		--    pszItemName the name of the recipe
		print("RoundScript -> OnOrderExpired")
	end,
}