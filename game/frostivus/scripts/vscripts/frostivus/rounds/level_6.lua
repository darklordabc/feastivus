local LEVEL_CAMERA_TARGET = Vector(-3970.5, 6609.29, 1100)

LinkLuaModifier("modifier_kick_indicator", "frostivus/modifiers/modifier_kick_indicator.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tusk_kick", "frostivus/modifiers/modifier_tusk_kick.lua", LUA_MODIFIER_MOTION_BOTH)

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

		local tusk = Entities:FindByName(nil, "tusk_left")
		tusk:AddNewModifier(tuskModelLeft, nil, "modifier_hide_health_bar", {})
		tusk:AddNewModifier(tuskModelLeft, nil, "modifier_unselectable", {})
		tusk = Entities:FindByName(nil, "tusk_right")
		tusk:AddNewModifier(tuskModelLeft, nil, "modifier_hide_health_bar", {})
		tusk:AddNewModifier(tuskModelLeft, nil, "modifier_unselectable", {})

		GameRules.__flLastTuskKickTime_Left = GameRules:GetGameTime()
		GameRules.__flLastTuskKickTime_Right = GameRules:GetGameTime()
		
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