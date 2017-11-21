-- tutorial is played during level 1
LinkLuaModifier("modifier_target_tooltip","frostivus/modifiers/modifier_target_tooltip.lua",LUA_MODIFIER_MOTION_NONE)

local TUTORIAL_CAMERA_TARGETS = {
	[0] = Vector(3573.28, 3458, 890),
	[1] = Vector(6069.28, 3378, 890),
	[2] = Vector(6069.28, 5426, 890),
	[3] = Vector(3381.28, 5426, 890),
	[4] = Vector(245.277, 5426, 890)
}

local LEVEL_CAMERA_TARGET = Vector(-1.579994, 56.258438, 940)

function StartPlayTutorial(player)
	local playerid = player:GetPlayerID()

	if IsInToolsMode() then
		playerid = table.random({0,1,2,3,4})
	end

	print("Tutorial room No.->", playerid)

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
				local currentLevel = g_RoundManager.nCurrentLevel
				local start = Entities:FindByName(nil, "level_" .. currentLevel .. "_start")
				if start then
					FindClearSpaceForUnit(hero, start:GetOrigin(), true)
				end
				hero:SetCameraTargetPosition(LEVEL_CAMERA_TARGET)
				hero.__bPlayingTutorial = false
				if not GameRules.bLevelOneStarted then
					GameRules.bLevelOneStarted = true
					g_RoundManager:GetCurrentRound().nCountDownTimer = g_RoundManager:GetCurrentRound().vRoundData.TimeLimit
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
		SendToServerConsole("stopsound")
		print("RoundScript -> OnPreRoundStart")

		Timers:CreateTimer(5, function()
			StartMainThemeAtPosition(LEVEL_CAMERA_TARGET)
		end)

		Frostivus:ResetStage( LEVEL_CAMERA_TARGET )

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

		-- ask server for players that didnt play tutorial yet
		LoopOverPlayers(function(player)
			Timers:CreateTimer(function ()

				local hero = player:GetAssignedHero()

				if not IsValidEntity(hero) then
					return 0.1
				else
					if not hero.__bPlayingTutorial then
						print("is player required to play tutorial?")
					
						-- we should not trust the server
						-- it may dead
						-- wait for 5 seconds, if the server have no response, make player to start level 1

						local function startLevel1()
							if not GameRules.bLevelOneStarted then
								GameRules.bLevelOneStarted = true
								round.nCountDownTimer = g_RoundManager:GetCurrentRound().vRoundData.TimeLimit
							end
							local hero = player:GetAssignedHero()
							local level1Start = Entities:FindByName(nil, "level_1_start"):GetOrigin()
							FindClearSpaceForUnit(hero, level1Start, true)
							hero:SetCameraTargetPosition(LEVEL_CAMERA_TARGET)
						end

						local serverHasResponsed = false

						local req = CreateHTTPRequest("POST", "http://18.216.43.117:10010/IsFinishedTutorial")
						req:SetHTTPRequestGetOrPostParameter("steamid", tostring(PlayerResource:GetSteamAccountID(player:GetPlayerID())))
						req:Send(function(result)
							serverHasResponsed  = true
							-- for k, v in pairs(result) do
							-- 	Say(nil, tostring(k) .. "->" .. tostring(v), true)
							-- end
							if result.StatusCode == 200 then
								local r = result.Body
								if tonumber(r) == 1 then
									-- player dont need to play tutorial
									startLevel1()
								else
									-- ask player to start play tutorial
									StartPlayTutorial(player)
								end
							end
						end)

						Timers:CreateTimer(5, function()
							if not serverHasResponsed then
								startLevel1()
							end
						end)
					end
				end
			end)
		end)
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