local LEVEL_CAMERA_TARGET = Vector(-3970.5, 6609.29, 1100)

LinkLuaModifier("modifier_kick_indicator", "frostivus/modifiers/modifier_kick_indicator.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tusk_kick", "frostivus/modifiers/modifier_tusk_kick.lua", LUA_MODIFIER_MOTION_BOTH)

local flKickInterval = 15

return {
	OnInitialize = function(round)
		-- in initialize script, setup round parameters
		-- such as pre round time, time limit, etc.
		print("RoundScript -> OnInitialize")
	end,
	OnTimer = function(round)
	end,
	OnPreRoundStart = function(round)
		print("RoundScript -> OnPreRoundStart")

		StopMainTheme()
		
		Frostivus:ResetStage( LEVEL_CAMERA_TARGET )

		LoopOverHeroes(function(hero)
			hero:SetCameraTargetPosition(LEVEL_CAMERA_TARGET)
		end)

		local i = 1
		for k,v in pairs(Frostivus.state.stages["tusk"].crates) do
			local item = Frostivus.StagesKVs["tusk"].Initial[tostring(i)]
			Frostivus:L(item)
			if item then
				v:InitBench(1)
				v:SetCrateItem(item)
			else

			end
			i = i + 1
		end

		GameRules.__flLastTuskKickTime_Left = GameRules:GetGameTime() - 100
		GameRules.__flLastTuskKickTime_Right = GameRules:GetGameTime() - 100
		GameRules.__vTuskKickAreaUnitsLeft__ = GameRules.__vTuskKickAreaUnitsLeft__ or {}
		GameRules.__vTuskKickAreaUnitsRight__ = GameRules.__vTuskKickAreaUnitsRight__ or {}
		if GameRules.__vTuskLeftTimer == nil then
			GameRules.__vTuskLeftTimer = true

			local tusk = Entities:FindByName(nil, "tusk_left")
			tusk:AddNewModifier(tuskModelLeft, nil, "modifier_hide_health_bar", {})
			tusk:AddNewModifier(tuskModelLeft, nil, "modifier_unselectable", {})

			Timers:CreateTimer(function()
				local now = GameRules:GetGameTime()
				if now - GameRules.__flLastTuskKickTime_Left >= flKickInterval then
					if not tusk:HasModifier("modifier_kick_indicator") then
						tusk:AddNewModifier(tusk, nil, "modifier_kick_indicator", {})
					end
				end

				if tusk:HasModifier("modifier_kick_indicator") and table.count(GameRules.__vTuskKickAreaUnitsLeft__) > 0 then
					local target
					for v in pairs(GameRules.__vTuskKickAreaUnitsLeft__) do
						target = v
					end
					tusk:RemoveModifierByName("modifier_kick_indicator")
					tusk:ForcePlayActivityOnce(ACT_DOTA_CAST_ABILITY_5)

					if target:HasModifier("modifier_frostivus_boost") then
						target:RemoveModifierByName("modifier_frostivus_boost")
					end

					Timers:CreateTimer(0.2, function()
						target:AddNewModifier(target, nil, "modifier_tusk_kick", {Direction = "right"})
					end)
					EmitAnnouncerSound("announcer_dlc_tusk_tusk_ann_evil_greevils_appear_05")
					GameRules.__flLastTuskKickTime_Left = now
				end
				return 0.03
			end)
		end

		if GameRules.__vTuskRightTimer == nil then
			GameRules.__vTuskRightTimer = true

			local tusk = Entities:FindByName(nil, "tusk_right")
			tusk:AddNewModifier(tuskModelLeft, nil, "modifier_hide_health_bar", {})
			tusk:AddNewModifier(tuskModelLeft, nil, "modifier_unselectable", {})

			Timers:CreateTimer(function()
				local now = GameRules:GetGameTime()
				if now - GameRules.__flLastTuskKickTime_Right >= flKickInterval then
					if not tusk:HasModifier("modifier_kick_indicator") then
						tusk:AddNewModifier(tusk, nil, "modifier_kick_indicator", {})
					end
				end

				if tusk:HasModifier("modifier_kick_indicator") and table.count(GameRules.__vTuskKickAreaUnitsRight__) > 0 then
					local target
					for v in pairs(GameRules.__vTuskKickAreaUnitsRight__) do
						target = v
					end
					tusk:RemoveModifierByName("modifier_kick_indicator")
					tusk:ForcePlayActivityOnce(ACT_DOTA_CAST_ABILITY_5)

					if target:HasModifier("modifier_frostivus_boost") then
						target:RemoveModifierByName("modifier_frostivus_boost")
					end

					Timers:CreateTimer(0.2, function()
						target:AddNewModifier(target, nil, "modifier_tusk_kick", {Direction = "left"})
					end)
					EmitAnnouncerSound("announcer_dlc_tusk_tusk_ann_evil_greevils_appear_05")
					GameRules.__flLastTuskKickTime_Right = now
				end
				return 0.03
			end)
		end
	end,
	OnRoundStart = function(round)
		print("RoundScript -> OnRoundStart")
		StartMainThemeAtPosition(LEVEL_CAMERA_TARGET)
		Timers:CreateTimer(67, function()
			if round.nCountDownTimer > 0 then
				StartMainThemeAtPosition(LEVEL_CAMERA_TARGET)
				return 67
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