-- round scripts
-- all keys are optional
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
	end,
	OnRoundStart = function(round)
		print("RoundScript -> OnRoundStart")

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