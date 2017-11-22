local LEVEL_CAMERA_TARGET = Vector(-4033.5, 6609.29, 1100)

LinkLuaModifier("modifier_kick_indicator", "frostivus/modifiers/modifier_kick_indicator.lua", LUA_MODIFIER_MOTION_NONE)

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

		-- create and collect units
		local tuskModelLeft = Entities:FindByName(nil, "tusk_left")
		tuskModelLeft:SetForwardVector(Vector(1, 0, 0))
		tuskModelLeft:AddItemByName("item_ultimate_scepter")
		tuskModelLeft:FindAbilityByName("tusk_walrus_punch"):UpgradeAbility(false)
		local leftKick = tuskModelLeft:FindAbilityByName("tusk_walrus_kick")
		tuskModelLeft:AddNewModifier(tuskModelLeft, nil, "modifier_disarmed", {})
		tuskModelLeft:AddNewModifier(tuskModelLeft, nil, "modifier_hide_health_bar", {})
		-- tuskModelLeft:AddNewModifier(tuskModelLeft, nil, "modifier_unselectable", {})

		local tuskModelRight = Entities:FindByName(nil, "tusk_right")
		tuskModelRight:SetForwardVector(Vector(-1, 0, 0))
		tuskModelRight:AddItemByName("item_ultimate_scepter")
		tuskModelRight:FindAbilityByName("tusk_walrus_punch"):UpgradeAbility(false)
		local rightKick = tuskModelRight:FindAbilityByName("tusk_walrus_kick")
		tuskModelRight:AddNewModifier(tuskModelRight, nil, "modifier_disarmed", {})
		tuskModelRight:AddNewModifier(tuskModelRight, nil, "modifier_hide_health_bar", {})
		-- tuskModelRight:AddNewModifier(tuskModelRight, nil, "modifier_unselectable", {})

		GameRules.__vTuskKickAreaUnitsLeft__ = GameRules.__vTuskKickAreaUnitsLeft__ or {}
		GameRules.__vTuskKickAreaUnitsRight__ = GameRules.__vTuskKickAreaUnitsRight__ or {}

		if not GameRules.vTuskLeftTimer then
			Timers:CreateTimer(function()
				if leftKick:IsCooldownReady() then
					if table.count(GameRules.__vTuskKickAreaUnitsLeft__) > 0 then
						for v in pairs(GameRules.__vTuskKickAreaUnitsLeft__) do
							target = v
						end
						tuskModelLeft:CastAbilityOnTarget(target, leftKick, -1)
						print("left want to kick!")
						return 5
					end
				end
				return 0.03
			end)
			GameRules.vTuskLeftTimer = true
		end

		if not GameRules.vTuskRightTimer then
			print("creating right timer")
			Timers:CreateTimer(function()
				if rightKick:IsCooldownReady() then
					print("cooldown ready")
					if table.count(GameRules.__vTuskKickAreaUnitsRight__) > 0 then
						for v in pairs(GameRules.__vTuskKickAreaUnitsRight__) do
							target = v
						end
						tuskModelRight:CastAbilityOnTarget(target, rightKick, -1)
						print("right want to kick!")
						return 5
					end
				end
				return 0.03
			end)
			GameRules.vTuskRightTimer = true
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