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
		Frostivus.state[DOTA_TEAM_GOODGUYS].current_item_table = item or Frostivus:GetRandomItemByTier(1)

		local i = 1
		for k,v in pairs(Frostivus.state[DOTA_TEAM_GOODGUYS].crates) do
			local item = Frostivus.state[DOTA_TEAM_GOODGUYS].current_item_table.initial[tostring(i)]
			Frostivus:L(item)
			if item then
				v:InitBench(1)
				v:SetCrateItem(item)
			else

			end
			i = i + 1
		end

		CustomGameEventManager:Send_ServerToTeam(DOTA_TEAM_GOODGUYS,"frostivus_new_round",{recipe = Frostivus.state[DOTA_TEAM_GOODGUYS].current_item_table.assembly})

		Frostivus:L( Frostivus.state[DOTA_TEAM_GOODGUYS].current_item_table.item )
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