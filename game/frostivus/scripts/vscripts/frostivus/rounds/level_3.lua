local spawnPos1 = Vector(-4288, 2400, 128)
local spawnPos2 = Vector(-4032, 2400, 128)
local randomScrollIntervalMin = 20
local randomScrollIntervalMax = 25
local wavesCount = 6

return {
	CameraTargetPosition = Vector(-4200, 1110, 1100),
	OnInitialize = function(round)
		-- in initialize script, setup round parameters
		-- such as pre round time, time limit, etc.
		print("RoundScript -> OnInitialize")
		GridNav:RegrowAllTrees()
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
			-- StartSoundEvent("Hero_Tusk.Snowball.Loop", GameRules.__vPangoliers[1])
			for i = 1, wavesCount do
				local pangolier = GameRules.__vPangoliers[i]
				local target
				local pos
				if i % 2 == 0 then
					pos = spawnPos1
				else
					pos = spawnPos2
				end
				pangolier:SetAbsOrigin(pos)
				AddFOWViewer(2, pos, 350, 20, false)
				Timers:CreateTimer(2.0 * (i -1), function()
					pangolier:RemoveNoDraw()
					pangolier:CastAbilityNoTarget(pangolier.ability, -1)
				end)
			end

            Timers:CreateTimer(2 * wavesCount + 6, function()
                --GridNav:RegrowAllTrees()
                for i = 1, wavesCount do
					if i % 2 == 0 then
						GameRules.__vPangoliers[i]:SetAbsOrigin(spawnPos1)
					else
						GameRules.__vPangoliers[i]:SetAbsOrigin(spawnPos2)
					end
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
			PrecacheUnitByNameAsync("npc_snowball", function()
				local function CreatePangolierOnPosition(pos)
					local pangolier = CreateUnitByName("npc_snowball", pos, false, nil, nil, DOTA_TEAM_BADGUYS)
					pangolier:AddNewModifier(pangolier, nil, "modifier_disarmed", {})
					pangolier:AddNewModifier(pangolier, nil, "modifier_hide_health_bar", {})
					pangolier:AddNewModifier(pangolier, nil, "modifier_unselectable", {})
					pangolier.ability = pangolier:FindAbilityByName("frostivus_snowball")
					pangolier.ability:UpgradeAbility(false)
					-- pangolier.jumpAbility = pangolier:FindAbilityByName("pangolier_shield_crash")
					-- pangolier.jumpAbility:UpgradeAbility(false)
					pangolier.vSpawnPosition = pos
					pangolier:SetForwardVector(Vector(0, -1, 0))

					pangolier:SetContextThink(DoUniqueString("tree_cutter"), function()
						if IsValidAlive(pangolier) then
							GridNav:DestroyTreesAroundPoint(pangolier:GetOrigin(), 140, true)
							return .1
						end
					end, 0)
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