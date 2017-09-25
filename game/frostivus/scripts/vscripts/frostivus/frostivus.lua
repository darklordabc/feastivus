if not Frostivus then
    Frostivus = class({})

    Frostivus.RecipesKVs = LoadKeyValues("scripts/kv/recipes.kv")
    Frostivus.ItemsKVs = LoadKeyValues("scripts/npc/npc_items_custom.txt")

    Frostivus.state = {}
    Frostivus.state[DOTA_TEAM_GOODGUYS] = {}
    Frostivus.state[DOTA_TEAM_GOODGUYS].raw_targets = Entities:FindAllByName("point_raw_*")
    Frostivus.state[DOTA_TEAM_GOODGUYS].tool_targets = Entities:FindAllByName("point_tool_*")
    Frostivus.state[DOTA_TEAM_GOODGUYS].transfer_target = Entities:FindByName(nil, "point_transfer")

    Frostivus.state[DOTA_TEAM_GOODGUYS].transfer_table = Entities:FindByName(nil, "unit_transfer_table")

    Frostivus.state[DOTA_TEAM_BADGUYS] = {}
    Frostivus.state[DOTA_TEAM_BADGUYS].raw_targets = Entities:FindAllByName("point_raw_*")
    Frostivus.state[DOTA_TEAM_BADGUYS].tool_targets = Entities:FindAllByName("point_tool_*")
    Frostivus.state[DOTA_TEAM_BADGUYS].transfer_target = Entities:FindByName(nil, "point_transfer")

    Frostivus.state[DOTA_TEAM_BADGUYS].transfer_table = Entities:FindByName(nil, "unit_transfer_table")

    Frostivus.ROLE_DELIVERY = 0
    Frostivus.ROLE_REFINERY = 1

	LinkLuaModifier("modifier_wearable_visuals", "frostivus/modifiers/wearables.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_wearable_visuals_status_fx", "frostivus/modifiers/wearables.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_wearable_visuals_activity", "frostivus/modifiers/wearables.lua", LUA_MODIFIER_MOTION_NONE)

	LinkLuaModifier("modifier_hide_health_bar", "frostivus/modifiers/heroes.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_carrying_item", "frostivus/modifiers/heroes.lua", LUA_MODIFIER_MOTION_NONE)

	Frostivus.state[DOTA_TEAM_GOODGUYS].transfer_table:AddNewModifier(nil,nil,"modifier_hide_health_bar",{})

	GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( Frostivus, "FilterExecuteOrder" ), self )

    Frostivus.DEBUG = true
end

require("frostivus/filters")

function Frostivus:InitHero(hero)
	hero:SetMaterialGroup(tostring(math.random(0,8)))
	AddAnimationTranslate(hero, "level_3")
	hero:AddNewModifier(hero,nil,"modifier_hide_health_bar",{})
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

function Frostivus:OnPickupItem( item, ply )
	local caster = ply:GetAssignedHero()

	local model = Frostivus.ItemsKVs[item:GetName()].Model
	local charges = item:GetCurrentCharges()

	Frostivus:L(model..":"..tostring(charges))

	if not Frostivus.ItemsKVs[item:GetName()].CantPickup then
		local item = CreateItemOnPositionSync(caster:GetAbsOrigin(),item)
		item:FollowEntity(caster,false)

		caster:AddNewModifier(caster,nil,"modifier_carrying_item",{}).item = item

		Timers:CreateTimer(function ()
			if not caster:HasModifier("modifier_carrying_item") or caster:FindModifierByName("modifier_carrying_item").item ~= item then
				item:RemoveSelf()
				return
			else
				item:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,128) + caster:GetForwardVector() * 32)
				return 0.03
			end
		end)

		-- item:RemoveSelf()

	    -- local item = CreateUnitByName("wearable_model", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_NOTEAM)
	    -- item:SetParent(caster,"follow_overhead")
	    -- item:SetModel(model)
	    -- item:SetOriginalModel(model)
	    -- item:AddNewModifier(item, nil, "modifier_wearable_visuals", {})

	    -- item:SetOrigin(Vector(0,0,200))

	    -- caster._wearables = caster._wearables or {}

	    -- if t then
	    --     caster._wearables[t] = caster._wearables[t] or {}
	    --     table.insert(caster._wearables[t], item)
	    -- else
	    --     caster._wearables["temporary_wearables"] = caster._wearables["temporary_wearables"] or {}
	    --     table.insert(caster._wearables["temporary_wearables"], item)
	    -- end
	end
end

function Frostivus:L(s)
	if Frostivus.DEBUG then
		print("[Frostivus] "..s)
	end
end