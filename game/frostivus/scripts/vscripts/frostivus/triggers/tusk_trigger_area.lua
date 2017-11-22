function OnEnterKickAreaLeft(keys)
	local tusk = Entities:FindByName(nil, "tusk_left")
	
	if keys.activator and keys.activator:GetName() == "npc_dota_hero_axe" then
		GameRules.__vTuskKickAreaUnitsLeft__ = GameRules.__vTuskKickAreaUnitsLeft__ or {}
		GameRules.__vTuskKickAreaUnitsLeft__[keys.activator] = true
	end
end

function OnLeaveKickAreaLeft(keys)
	GameRules.__vTuskKickAreaUnitsLeft__ = GameRules.__vTuskKickAreaUnitsLeft__ or {}
	GameRules.__vTuskKickAreaUnitsLeft__[keys.activator] = nil
end

function OnEnterKickAreaRight(keys)
	local tusk = Entities:FindByName(nil, "tusk_right")

	if keys.activator and keys.activator:GetName() == "npc_dota_hero_axe" then
		GameRules.__vTuskKickAreaUnitsRight__ = GameRules.__vTuskKickAreaUnitsRight__ or {}
		GameRules.__vTuskKickAreaUnitsRight__[keys.activator] = true
	end
end

function OnLeaveKickAreaRight(keys)
	GameRules.__vTuskKickAreaUnitsRight__ = GameRules.__vTuskKickAreaUnitsRight__ or {}
	GameRules.__vTuskKickAreaUnitsRight__[keys.activator] = nil
end