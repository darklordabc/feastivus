return {
	CameraTargetPosition = Vector(-1.579994, 56.258438, 940),
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

		local i = 1
		for k,v in pairs(Frostivus.state.stages["tavern"].crates) do
			local item = Frostivus.StagesKVs["tavern"].Initial[tostring(i)]
			Frostivus:L(item)
			if item then
				v:InitBench(1)
				v:SetCrateItem(item)
			else

			end
			i = i + 1
		end

		-- if it's single player, and not extra greevil created, create extra greevil
		local playerCount = 0
		local theOnlyPlayer
		LoopOverPlayers(function(player)
			playerCount = playerCount + 1
			theOnlyPlayer = player
		end)
		if playerCount == 1 and not GameRules.__bExtraGreevilCreated__ then
			GameRules.__bExtraGreevilCreated__ = true
			LoopOverPlayers(function(player)
				Timers:CreateTimer(0, function()
					local hero = player:GetAssignedHero()
					if not hero then return 0.03 end
					CreateExtraGreevilForHero(hero)
				end)
			end)
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