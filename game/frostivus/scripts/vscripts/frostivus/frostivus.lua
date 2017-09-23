if not Frostivus then
    Frostivus = class({})

    Frostivus.RecipesKVs = LoadKeyValues("scripts/kv/recipes.kv")

    Frostivus.state = {}
    Frostivus.state[DOTA_TEAM_GOODGUYS] = {}
    Frostivus.state[DOTA_TEAM_GOODGUYS].raw_targets = Entities:FindAllByName("point_raw_*")
    Frostivus.state[DOTA_TEAM_GOODGUYS].tool_targets = Entities:FindAllByName("point_tool_*")
    Frostivus.state[DOTA_TEAM_GOODGUYS].transer_target = Entities:FindByName(nil, "point_transfer")

    Frostivus.state[DOTA_TEAM_BADGUYS] = {}
    Frostivus.state[DOTA_TEAM_BADGUYS].raw_targets = Entities:FindAllByName("point_raw_*")
    Frostivus.state[DOTA_TEAM_BADGUYS].tool_targets = Entities:FindAllByName("point_tool_*")
    Frostivus.state[DOTA_TEAM_BADGUYS].transer_target = Entities:FindByName(nil, "point_transfer")

    Frostivus.ROLE_DELIVERY = 0
    Frostivus.ROLE_REFINERY = 1

    Frostivus.DEBUG = true
end

function Frostivus:StartNewRound(team, item, tier)
	tier = tier or 1
	Frostivus.state[team].current_item_table = item or Frostivus:GetRandomItemByTier(tier)

	local i = 1
	for k,v in pairs(Frostivus.state[team].raw_targets) do
		local item = Frostivus.state[team].current_item_table.initial[tostring(i)]
		Frostivus:L(item)
		if item then
			CreateItemOnPositionSync(v:GetAbsOrigin(),CreateItem(item,nil,nil))
		else

		end
		i = i + 1
	end

	CustomGameEventManager:Send_ServerToTeam(team,"frostivus_new_round",{recipe = Frostivus.state[team].current_item_table.assembly})

	Frostivus:L( Frostivus.state[team].current_item_table.item )
end

function Frostivus:GetRandomItemByTier(tier)
	local item = GetRandomElement(Frostivus.RecipesKVs[tostring(tier)], nil, true)

	return {item = item, assembly = Frostivus.RecipesKVs[tostring(tier)][item]["Assembly"], initial = Frostivus.RecipesKVs[tostring(tier)][item]["Initial"]}
end

function Frostivus:GetPlayerRole(pID)
	local ply = PlayerResource:GetPlayer(pID)
	if ply then
		return ply.role or 1
	end
	return -1
end

function Frostivus:L(s)
	if Frostivus.DEBUG then
		print("[Frostivus] "..s)
	end
end