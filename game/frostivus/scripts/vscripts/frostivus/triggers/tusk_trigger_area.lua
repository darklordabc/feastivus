local flKickInterval = 5

function OnEnterKickAreaLeft(keys)
	local tusk = Entities:FindByName(nil, "tusk_left")
	
	if keys.activator:GetName() == "npc_dota_hero_axe" then
		GameRules.__vTuskKickAreaUnitsLeft__ = GameRules.__vTuskKickAreaUnitsLeft__ or {}
		GameRules.__vTuskKickAreaUnitsLeft__[keys.activator] = true
	end

	if GameRules.__vTuskLeftTimer == nil then
		GameRules.__vTuskLeftTimer = true

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
				Timers:CreateTimer(0.2, function()
					target:AddNewModifier(target, nil, "modifier_tusk_kick", {Direction = "right"})
				end)
				GameRules.__flLastTuskKickTime_Left = now
			end
			return 0.03
		end)
	end
end

function OnLeaveKickAreaLeft(keys)
	GameRules.__vTuskKickAreaUnitsLeft__ = GameRules.__vTuskKickAreaUnitsLeft__ or {}
	GameRules.__vTuskKickAreaUnitsLeft__[keys.activator] = nil
end

function OnEnterKickAreaRight(keys)
	local tusk = Entities:FindByName(nil, "tusk_right")

	if keys.activator:GetName() == "npc_dota_hero_axe" then
		GameRules.__vTuskKickAreaUnitsRight__ = GameRules.__vTuskKickAreaUnitsRight__ or {}
		GameRules.__vTuskKickAreaUnitsRight__[keys.activator] = true
	end

	if GameRules.__vTuskRightTimer == nil then
		GameRules.__vTuskRightTimer = true

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
				Timers:CreateTimer(0.2, function()
					target:AddNewModifier(target, nil, "modifier_tusk_kick", {Direction = "left"})
				end)
				GameRules.__flLastTuskKickTime_Right = now
			end
			return 0.03
		end)
	end
end

function OnLeaveKickAreaRight(keys)
	GameRules.__vTuskKickAreaUnitsRight__ = GameRules.__vTuskKickAreaUnitsRight__ or {}
	GameRules.__vTuskKickAreaUnitsRight__[keys.activator] = nil
end