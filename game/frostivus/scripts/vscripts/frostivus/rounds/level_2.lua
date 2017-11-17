local LEVEL_CAMERA_TARGET = Vector(4224.000000, -300.609528, 1250)

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
		for k,v in pairs(Frostivus.state.stages["bottleneck"].crates) do
			local item = Frostivus.StagesKVs["bottleneck"].Initial[tostring(i)]
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

		-- sound for first level
		Timers:CreateTimer(function()
			if round.nCountDownTimer > 0 then
				GameRules:GetGameModeEntity():EmitSound("custom_music.main_theme")
				return 138
			end
		end)
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