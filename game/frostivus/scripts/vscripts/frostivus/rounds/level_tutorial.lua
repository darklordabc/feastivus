-- tutorial is played during level 1
LinkLuaModifier("modifier_target_tooltip","frostivus/modifiers/modifier_target_tooltip.lua",LUA_MODIFIER_MOTION_NONE)

local TUTORIAL_CAMERA_TARGETS = {
	[0] = Vector(3573.28, 3458, 890),
	[1] = Vector(6069.28, 3378, 890),
	[2] = Vector(6069.28, 5426, 890),
	[3] = Vector(3381.28, 5426, 890),
	[4] = Vector(245.277, 5426, 890)
}

function StartPlayTutorial(player)
	local playerid = player:GetPlayerID()

	if IsInToolsMode() then
		playerid = table.random({0,1,2,3,4})
	end

	local hero = player:GetAssignedHero()

	hero.__bPlayingTutorial = true

	-- teleport player to tutorial area
	local ent_teleport_target = Entities:FindByName(nil, 'level_0_start_' .. tostring(playerid))
	if ent_teleport_target then
		FindClearSpaceForUnit(hero, ent_teleport_target:GetAbsOrigin(), true)
	end

	hero:SetCameraTargetPosition(TUTORIAL_CAMERA_TARGETS[playerid])

	CustomGameEventManager:Send_ServerToPlayer(player, "player_start_playing_tutorial", {})

	-- init crates
	local leafCrate
	local plateBench = Entities:FindByName(nil, "npc_plate_bench_" .. tostring(playerid))
	local serveBench = Entities:FindByName(nil,  "npc_serve_table_" .. tostring(playerid))
	local cuttingBenches = Entities:FindAllByName("npc_cutting_bench_" .. tostring(playerid))
	local tooltip_step1, tooltip_step2, tooltip_step3

	local crates = Entities:FindAllByName("npc_crate_bench_tutorial_" .. tostring(playerid))
	for k, v in pairs(crates) do
		local item = Frostivus.StagesKVs["tutorial"].Initial[tostring(k)]
		if item then
			v:InitBench(1)
			v:SetCrateItem(item)

			if item == "item_raw_leaf" then
				leafCrate = v
			end
		end
	end
	local tutorialOrders = {
		{
			pszID = "tutorial_order_1_" .. playerid,
			pszItemName = "item_tango_salad",
			nTimeRemaining = 60,
			nTimeLimit = 60,
			pszFinishType = nil,
		},
		{
			pszID = "tutorial_order_2_" .. playerid,
			pszItemName = "item_mango_salad",
			nTimeRemaining = 60,
			nTimeLimit = 60,
			pszFinishType = nil,
		}
	}

	CustomNetTables:SetTableValue("orders", "tutorial_orders_" .. hero:GetPlayerID(), tutorialOrders)

	-- show tooltip message
	hero.pszTooltipMessage = MessageCenter:ShowMessageOnClient(player, {item = "item_raw_leaf", text="#tutorial_text_pickup_tango"})
	leafCrate:AddNewModifier(leafCrate, nil, 'modifier_target_tooltip',{})

	GameRules.FrostivusEventListener:RegisterListener('frostivus_player_pickup', function(keys)
		if keys.ItemName == 'item_raw_leaf' then
			if keys.Unit ~= hero then return end
			if tooltip_step1 then return end
			tooltip_step1 = true
			MessageCenter:RemoveMessage(hero.pszTooltipMessage)
			hero.pszTooltipMessage = MessageCenter:ShowMessageOnClient(player, {icon = "tutorial/cutting_bench.png", text = "#tutorial_text_cutting"})
			for _, bench in pairs(cuttingBenches) do
				bench:AddNewModifier(bench, nil, "modifier_target_tooltip", {})
			end
			leafCrate:RemoveModifierByName("modifier_target_tooltip")
		end
	end)

	GameRules.FrostivusEventListener:RegisterListener('frostivus_complete_refine', function(keys)
		if keys.Unit ~= hero then return end
		if tooltip_step2 then return end
		tooltip_step2 = true
		MessageCenter:RemoveMessage(hero.pszTooltipMessage)
		hero.pszTooltipMessage = MessageCenter:ShowMessageOnClient(player, {icon = "tutorial/plate_bench.png", text = "#tutorial_collect_plate"})
		for _, bench in pairs(cuttingBenches) do
			bench:RemoveModifierByName("modifier_target_tooltip")
		end
		plateBench:AddNewModifier(plateBench, nil, "modifier_target_tooltip", {})
		serveBench:AddNewModifier(serveBench, nil, "modifier_target_tooltip", {})
	end)

	function hero:OnDoTutorialServe(item)

		local function _checkTutorialEnd()
			if tutorialOrders[1] == nil and tutorialOrders[2] == nil then
				hero.__bPlayingTutorial = false
				if not GameRules.bMainRoundStarted then
					-- first player finished tutorial
					GameRules.RoundManager:StartNewRound()
				else
					-- join the main game
					hero:SetCameraTargetPosition("last_camera_target")
					local start = Entities:FindByName(nil, "level_" .. currentLevel .. "_start")
					if start then
						FindClearSpaceForUnit(hero, start:GetOrigin(), true)
					end
				end

				local req = CreateHTTPRequest("POST", "http://18.216.43.117:10010/SetFinishedTutorial")
				req:SetHTTPRequestGetOrPostParameter("steamid", tostring(PlayerResource:GetSteamAccountID(player:GetPlayerID())))
				req:Send(function(result)
					print("Save tutorial finished state->", result.StatusCode, result.Body)
				end)

				EndAnimation(hero)
				RemoveAnimationTranslate(hero)
				AddAnimationTranslate(hero, "level_3")
				if Frostivus:IsCarryingItem( hero ) then
					Frostivus:GetCarryingItem( hero ):RemoveSelf()
					Frostivus:DropItem( hero )
				end
				hero:RemoveModifierByName("modifier_bench_interaction")
				hero:Stop()
			end
		end

		local name = item:GetAbilityName()
		if name == "item_tango_salad" then
			tutorialOrders[1].pszFinishType = "Finished"
			Timers:CreateTimer(2, function()
				tutorialOrders[1] = nil
				CustomNetTables:SetTableValue("orders", "tutorial_orders_" .. hero:GetPlayerID(), tutorialOrders)
				_checkTutorialEnd()
			end)
		elseif name == "item_mango_salad" then
			tutorialOrders[2].pszFinishType = "Finished"
			Timers:CreateTimer(2, function()
				tutorialOrders[2] = nil
				CustomNetTables:SetTableValue("orders", "tutorial_orders_" .. hero:GetPlayerID(), tutorialOrders)
				_checkTutorialEnd()
			end)
		end

		if tooltip_step3 then return end
		tooltip_step3 = true

		plateBench:RemoveModifierByName("modifier_target_tooltip")
		serveBench:RemoveModifierByName("modifier_target_tooltip")

		MessageCenter:RemoveMessage(hero.pszTooltipMessage)
		MessageCenter:ShowMessageOnClient(player, {icon = "tutorial/sink.png", text="#tutorial_clean_plates", duration=5})
		Timers:CreateTimer(5, function()
			MessageCenter:ShowMessageOnClient(player, {item = "item_mixed_tango_salad", text="#tutorial_finish_remaining_orders", duration=5})
		end)
	end
end