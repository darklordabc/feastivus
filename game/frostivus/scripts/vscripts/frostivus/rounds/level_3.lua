local LEVEL_CAMERA_TARGET = Vector(4675.000000, -6100.000000, 1250)

return {
	OnInitialize = function(round)
		-- in initialize script, setup round parameters
		-- such as pre round time, time limit, etc.
		print("RoundScript -> OnInitialize")
	end,
	OnTimer = function(round)
		-- timer function, called every second
		-- if you want a higher frequency timer
		-- feel free to add anywhere

		-- print("RoundScript -> OnTimer")
	end,
	OnPreRoundStart = function(round)
		print("RoundScript -> OnPreRoundStart")

		Frostivus:ResetStage( LEVEL_CAMERA_TARGET )

		local i = 1
		for k,v in pairs(Frostivus.state.stages["lava"].crates) do
			local item = Frostivus.StagesKVs["lava"].Initial[tostring(i)]
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
	end,
	OnRoundStart = function(round)
		print("RoundScript -> OnRoundStart")
		StopMainThemeAtPosition(LEVEL_CAMERA_TARGET)
		StartMainThemeAtPosition(LEVEL_CAMERA_TARGET)

		local traps = Entities:FindAllByModel("models/props/traps/hooded_fang/hooded_fang.vmdl")

		local i = 0
		for k,v in pairs(traps) do
			Timers:CreateTimer(i * 5, function (  )
				local ab = v:FindAbilityByName("frostivus_fire_trap")

				v:AddNewModifier(v, ab, "modifier_fire_trap", {})
			end)

			i = i + 1
		end

	end,
	OnRoundEnd = function(round)
		-- if you do something special, clean them
		print("RoundScript -> OnRoundEnd")
		StopMainThemeAtPosition(LEVEL_CAMERA_TARGET)
	end,
	OnOrderExpired = function(round, order)
		-- @param order, table
		-- keys:
		--    nTimeRemaining
		--    pszItemName the name of the recipe
		print("RoundScript -> OnOrderExpired")
	end,
}