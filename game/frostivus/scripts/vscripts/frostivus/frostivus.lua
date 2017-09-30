if not Frostivus then
    Frostivus = class({})

    Frostivus.RecipesKVs = LoadKeyValues("scripts/kv/recipes.kv")
    Frostivus.ItemsKVs = LoadKeyValues("scripts/npc/npc_items_custom.txt")

    Frostivus.state = {}
    Frostivus.state[DOTA_TEAM_GOODGUYS] = {}
    Frostivus.state[DOTA_TEAM_GOODGUYS].raw_targets = Entities:FindAllByName("point_raw_*")
    Frostivus.state[DOTA_TEAM_GOODGUYS].tool_targets = Entities:FindAllByName("point_tool_*")
    Frostivus.state[DOTA_TEAM_GOODGUYS].transfer_target = Entities:FindByTarget(nil,"npc_transfer_table")

    Frostivus.state[DOTA_TEAM_GOODGUYS].transfer_table = Entities:FindByName(nil, "unit_transfer_table")

    Frostivus.state[DOTA_TEAM_BADGUYS] = {}
    Frostivus.state[DOTA_TEAM_BADGUYS].raw_targets = Entities:FindAllByName("point_raw_*")
    Frostivus.state[DOTA_TEAM_BADGUYS].tool_targets = Entities:FindAllByName("point_tool_*")
    Frostivus.state[DOTA_TEAM_BADGUYS].transfer_target = Entities:FindByTarget(nil,"npc_transfer_table")

    Frostivus.state[DOTA_TEAM_BADGUYS].transfer_table = Entities:FindByName(nil, "unit_transfer_table")

    Frostivus.ROLE_DELIVERY = 0
    Frostivus.ROLE_REFINERY = 1

	LinkLuaModifier("modifier_wearable_visuals", "frostivus/modifiers/wearables.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_wearable_visuals_status_fx", "frostivus/modifiers/wearables.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_wearable_visuals_activity", "frostivus/modifiers/wearables.lua", LUA_MODIFIER_MOTION_NONE)

	LinkLuaModifier("modifier_hide_health_bar", "frostivus/modifiers/states.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_unselectable", "frostivus/modifiers/states.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_carrying_item", "frostivus/modifiers/states.lua", LUA_MODIFIER_MOTION_NONE)

	GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( Frostivus, "FilterExecuteOrder" ), self )

    Frostivus.DEBUG = true
end

require("frostivus/filters")

function Frostivus:InitHero(hero)
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

function Frostivus:GetCarryingItem( unit )
	if Frostivus:IsCarryingItem( unit ) then
		return unit:FindModifierByName("modifier_carrying_item").item
	end
end

function Frostivus:IsCarryingItem( unit, item )
	return unit:HasModifier("modifier_carrying_item") and (not item or unit:FindModifierByName("modifier_carrying_item").item == item)
end

function Frostivus:BindItem( item, unit, position_callback, condition_callback, drop_callback, add_modifier, dont_hide )
	Timers:CreateTimer(function ()
		if not condition_callback() or not IsValidEntity(item) then
			if drop_callback then
				drop_callback()
			end
			return
		else
			item:SetAbsOrigin(position_callback())
			return 0.03
		end
	end)

	-- Frostivus:WipeInventory( unit )

	if not dont_hide then
		item:FollowEntity(unit,false)
	end

	if unit and add_modifier then
		unit:AddNewModifier(unit,nil,"modifier_carrying_item",{}).item = item
	end
end

function Frostivus:DropItem( unit, item )
	if IsValidEntity(unit) then
		unit:RemoveModifierByName("modifier_carrying_item")
	end

	if IsValidEntity(item) then
		item:FollowEntity(nil,false)
		item:SetAbsOrigin(GetGroundPosition(unit:GetAbsOrigin(), unit))
	end
end

function Frostivus:OnPickupItem( item, ply )
	local caster = ply:GetAssignedHero()

	local model = Frostivus.ItemsKVs[item:GetName()].Model
	local charges = item:GetCurrentCharges()

	Frostivus:L(item:GetName()..":"..tostring(charges))

	caster:DropItemAtPositionImmediate(item, caster:GetAbsOrigin())

	if not Frostivus.ItemsKVs[item:GetName()].CantPickup then
		if Frostivus:IsCarryingItem( caster ) then
			Frostivus:L("Swapping Items...")
			Frostivus:DropItem( caster, Frostivus:GetCarryingItem( caster ) )
		end
		
		local item = item:GetContainer()

		Frostivus:BindItem(item, caster, (function ()
			return caster:GetAbsOrigin() + Vector(0,0,128) + caster:GetForwardVector() * 32
		end),(function ()
			return Frostivus:IsCarryingItem( caster, item )
		end), nil, true, false)
	end
end

function Frostivus:WipeInventory( unit )
	for i=0,14 do
		local item = unit:GetItemInSlot(i)
		if item then
			item:RemoveSelf()
		end
	end
end

function Frostivus:L(s)
	if Frostivus.DEBUG then
		print("[Frostivus] "..s)
	end
end