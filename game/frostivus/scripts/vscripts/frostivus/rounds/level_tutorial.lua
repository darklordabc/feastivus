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

		local crates = {}
		for i=0,4 do
			crates[i] = Entities:FindAllByName("npc_crate_bench_tutorial_"..tostring(i))
		end

		for pID,crates in pairs(crates) do
			local i = 1
			for k,v in pairs(crates) do
				local item = Frostivus.StagesKVs["tutorial"].Initial[tostring(i)]
				Frostivus:L(item)
				if item then
					v:InitBench(1)
					v:SetCrateItem(item)
				else

				end
				i = i + 1
			end
		end
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