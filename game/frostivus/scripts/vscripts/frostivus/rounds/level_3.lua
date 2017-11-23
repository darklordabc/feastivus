local spawnPos1 = Vector(-4350, 2200, 128)
local spawnPos2 = Vector(-4000, 2200, 128)
local randomScrollIntervalMin = 10
local randomScrollIntervalMax = 15
local wavesCount = 6

return {
	CameraTargetPosition = Vector(-4200, 1088, 1100),
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
			-- start a pangolier run
			-- GameRules.__hPangolier1:CastAbilityNoTarget(GameRules.__hPangolier1.scrollAbility, -1)
			-- Timers:CreateTimer(1, function()
			-- 	GameRules.__hPangolier2:CastAbilityNoTarget(GameRules.__hPangolier2.scrollAbility, -1)
			-- end)
			for i = 1, wavesCount do
				local pangolier = GameRules.__vPangoliers[i]
				if i % 2 == 0 then
					pangolier:SetOrigin(spawnPos1)
				else
					pangolier:SetOrigin(spawnPos2)
				end
				Timers:CreateTimer(0.8 * (i -1), function()
					pangolier:CastAbilityNoTarget(pangolier.scrollAbility, -1)
				end)
			end

			Timers:CreateTimer(0.8 * wavesCount + 6, function()
				--GridNav:RegrowAllTrees()
				for i = 1, wavesCount do
					GameRules.__vPangoliers[i]:SetOrigin(spawnPos1)
				end
			end)

			GameRules.__flNextPangolierScrollTime = now + RandomFloat(randomScrollIntervalMin, randomScrollIntervalMax)
		end
	end,
	OnPreRoundStart = function(round)
		print("RoundScript -> OnPreRoundStart")

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

		if GameRules.__vPangoliers == nil then
			GameRules.__vPangoliers = {}
			PrecacheUnitByNameAsync("npc_dota_hero_pangolier", function()
				local function CreatePangolierOnPosition(pos)
					local pangolier = CreateUnitByName("npc_dota_hero_pangolier", pos, false, nil, nil, DOTA_TEAM_BADGUYS)
					pangolier:AddNewModifier(pangolier, nil, "modifier_disarmed", {})
					pangolier:AddNewModifier(pangolier, nil, "modifier_hide_health_bar", {})
					pangolier:AddNewModifier(pangolier, nil, "modifier_unselectable", {})
					pangolier.scrollAbility = pangolier:FindAbilityByName("pangolier_gyroshell")
					pangolier.scrollAbility:UpgradeAbility(false)
					pangolier.jumpAbility = pangolier:FindAbilityByName("pangolier_shield_crash")
					pangolier.jumpAbility:UpgradeAbility(false)
					pangolier.vTargetPosition = pos + Vector(0, -1500, 0)
					pangolier.vSpawnPosition = pos
					pangolier:SetForwardVector(Vector(0, -1, 0))
					return pangolier
				end

				for i = 1, wavesCount do
					table.insert(GameRules.__vPangoliers, CreatePangolierOnPosition(spawnPos1))
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