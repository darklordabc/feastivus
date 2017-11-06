LinkLuaModifier("modifier_target_tooltip","frostivus/modifiers/modifier_target_tooltip.lua",LUA_MODIFIER_MOTION_NONE)

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

		local leafCreates = {}
		local msgs = {}

		for pID,crates in pairs(crates) do
			local i = 1
			for k,v in pairs(crates) do
				local item = Frostivus.StagesKVs["tutorial"].Initial[tostring(i)]
				Frostivus:L(item)
				if item then
					v:InitBench(1)
					v:SetCrateItem(item)

					if item == "item_raw_leaf" then
						leafCreates[pID] = v
					end
				else

				end
				i = i + 1
			end
		end

		LoopOverPlayers(function(player)
			local playerID = player:GetPlayerID()
			msgs[playerID] = MessageCenter:ShowMessageOnClient(player, {item = "item_raw_leaf", text="#tutorial_text_pickup_tango"})
			leafCreates[playerID]:AddNewModifier(leafCreates[playerID],nil,'modifier_target_tooltip',{})
		end)


		-- register listener to handle tutorial progress
		GameRules.FrostivusEventListener:RegisterListener('frostivus_player_pickup', function(keys)
			if keys.ItemName == 'item_raw_leaf' then
				if keys.Unit.__bPickupTutorial then return end
				keys.Unit.__bPickupTutorial = true
				local playerID = keys.Unit:GetPlayerID()
				local player = PlayerResource:GetPlayer(playerID)
				MessageCenter:RemoveMessage(msgs[playerID])
				msgs[playerID] = MessageCenter:ShowMessageOnClient(player, {icon = "tutorial/cutting_bench.png", text = "#tutorial_text_cutting"})
				local units = FindUnitsInRadius(player:GetTeamNumber(),keys.Unit:GetOrigin(),nil,1200,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
				for _, unit in pairs(units) do
					if unit:GetUnitName() == 'npc_cutting_bench' then
						unit:AddNewModifier(unit,nil,"modifier_target_tooltip",{})
					else
						unit:RemoveModifierByName('modifier_target_tooltip')
					end
				end
			end
		end)

		GameRules.FrostivusEventListener:RegisterListener('frostivus_complete_refine', function(keys)
			local unit = keys.Unit
			if unit.__bRefineTutorial then return end
			unit.__bRefineTutorial = true

			local playerID = unit:GetPlayerID()
			local player = PlayerResource:GetPlayer(playerID)
			MessageCenter:RemoveMessage(msgs[playerID])
			msgs[playerID] = MessageCenter:ShowMessageOnClient(player, {icon = "tutorial/plate_bench.png", text = "#tutorial_collect_plate"})

			local units = FindUnitsInRadius(unit:GetTeamNumber(),unit:GetOrigin(),nil,1200,DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
			for _, unit in pairs(units) do
				if unit:GetUnitName() == 'npc_plate_bench' or unit:GetUnitName() == 'npc_serve_table' then
					unit:AddNewModifier(unit,nil,"modifier_target_tooltip",{})
				else
					unit:RemoveModifierByName('modifier_target_tooltip')
				end
			end
		end)

		GameRules.FrostivusEventListener:RegisterListener("frostivus_serve", function(keys)
			local unit = keys.Unit
			if unit.__bServeTutorial then return end
			unit.__bServeTutorial = true

			local playerID = unit:GetPlayerID()
			local player = PlayerResource:GetPlayer(playerID)

			MessageCenter:RemoveMessage(msgs[playerID])
			MessageCenter:ShowMessageOnClient(player, {icon = "tutorial/sink.png", text="#tutorial_clean_plates", duration=5})

			Timers:CreateTimer(5, function()
				MessageCenter:ShowMessageOnClient(player, {item = "item_mixed_tango_salad", text="#tutorial_finish_remaining_orders", duration=5})
			end)
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