function OnEnterKcikAreaLeft(keys)
	if keys.activator:GetName() == "npc_dota_hero_axe" then
		GameRules.__vTuskKickAreaUnitsLeft__ = GameRules.__vTuskKickAreaUnitsLeft__ or {}
		GameRules.__vTuskKickAreaUnitsLeft__[keys.activator] = true
	end
end

function OnLeaveKickAreaLeft(keys)
	GameRules.__vTuskKickAreaUnitsLeft__ = GameRules.__vTuskKickAreaUnitsLeft__ or {}
	GameRules.__vTuskKickAreaUnitsLeft__[keys.activator] = nil
end

function OnEnterKickAreaRight(keys)
	print("enter right")
	if keys.activator:GetName() == "npc_dota_hero_axe" then
		GameRules.__vTuskKickAreaUnitsRight__ = GameRules.__vTuskKickAreaUnitsRight__ or {}
		GameRules.__vTuskKickAreaUnitsRight__[keys.activator] = true
		print(table.count(GameRules.__vTuskKickAreaUnitsRight__))
	end
end

function OnLeaveKickAreaRight(keys)
	print("left right")
	GameRules.__vTuskKickAreaUnitsRight__ = GameRules.__vTuskKickAreaUnitsRight__ or {}
	GameRules.__vTuskKickAreaUnitsRight__[keys.activator] = nil
end