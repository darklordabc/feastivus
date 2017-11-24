if not Frostivus then
    Frostivus = class({})

    Frostivus.RecipesKVs = LoadKeyValues("scripts/kv/recipes.kv")
    Frostivus.ItemsKVs = LoadKeyValues("scripts/npc/npc_items_custom.txt")
    Frostivus.StagesKVs = LoadKeyValues("scripts/kv/stages.kv")
    Frostivus.RoundsKVs = LoadKeyValues("scripts/kv/rounds.kv")

    Frostivus.state = {}
    Frostivus.state.stages = {}
    Frostivus.state.rounds = {}

    for k,v in pairs(Frostivus.RoundsKVs) do
    	Frostivus.state.rounds[tonumber(k)] = {}
    	if tonumber(k) == 0 then
    		Frostivus.state.rounds[tonumber(k)].camera_target = {}
    		for i=0,4 do
    			Frostivus.state.rounds[tonumber(k)].camera_target[i] = Entities:FindByName(nil, "level_"..k.."_camera_target_"..tostring(i))
    		end
    	else
    		Frostivus.state.rounds[tonumber(k)].camera_target = Entities:FindByName(nil, "level_"..k.."_camera_target")

    	end
    end

    for k,v in pairs(Frostivus.StagesKVs) do
    	Frostivus.state.stages[k] = {}
    	Frostivus.state.stages[k].crates = Entities:FindAllByName("npc_crate_bench_"..k)
    end

    Frostivus.state.tutorials = {}

    for i=0,4 do
    	Frostivus.state.tutorials[i] = Entities:FindByName(nil, "frostivus_tutorial_"..tostring(i))
    end

    Frostivus.ROLE_DELIVERY = 0
    Frostivus.ROLE_REFINERY = 1

	LinkLuaModifier("modifier_wearable_visuals", "frostivus/modifiers/wearables.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_wearable_visuals_status_fx", "frostivus/modifiers/wearables.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_wearable_visuals_activity", "frostivus/modifiers/wearables.lua", LUA_MODIFIER_MOTION_NONE)

	LinkLuaModifier("modifier_hide_health_bar", "frostivus/modifiers/states.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_unselectable", "frostivus/modifiers/states.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_carrying_item", "frostivus/modifiers/states.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_rooted", "frostivus/modifiers/states.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_fake_casting", "frostivus/modifiers/states.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_bench_busy", "frostivus/modifiers/states.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_command_restricted", "frostivus/modifiers/states.lua", LUA_MODIFIER_MOTION_NONE)

    Frostivus.DEBUG = true

	local recipes = {}
	for _, _data in pairs(Frostivus.RecipesKVs) do
		for product, data in pairs(_data) do
			local assemblies = data.Assembly
			-- for _, assembly in pairs(data.Assembly) do
			-- 	table.insert(assemblies, assembly)
			-- end
			CustomNetTables:SetTableValue("recipes", product, assemblies)
		end
	end
end

function Frostivus:InitHero(hero)
	
	if hero:GetUnitName() ~= "npc_dota_hero_axe" then return end

	hero:SetCameraTargetPosition(Vector(-1.579994, 56.258438, 940))
	InitAbilities( hero )
	AddAnimationTranslate(hero, "level_3")
	hero:AddNewModifier(hero,nil,"modifier_hide_health_bar",{})
	hero:AddNewModifier(hero,nil,"modifier_unselectable",{})

	-- create overhead name label
	hero.overheadNamePanel = WorldPanels:CreateWorldPanelForAll(
	  {layout = "file://{resources}/layout/custom_game/worldpanels/overhead.xml",
	    entity = hero:GetEntityIndex(),
	    entityHeight = 180,
	  })
	hero.overheadNamePanel:SetData({PlayerID = hero:GetPlayerID()})
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
	return unit.HasModifier and unit:HasModifier("modifier_carrying_item") and (not item or unit:FindModifierByName("modifier_carrying_item").item == item)
end

function Frostivus:BindItem( item, unit, position_callback, condition_callback, drop_callback, add_modifier, dont_hide )
	item:SetAbsOrigin(position_callback())
	item:AddEffects(EF_NODRAW )
	Timers:CreateTimer(0.05, function (  )
		if IsValidEntity(item) then
			item:RemoveEffects(EF_NODRAW )
		end
	end)
	Timers:CreateTimer(function ()
		if not IsValidEntity(item) or not IsValidEntity(unit) then
			return
		end
		if not condition_callback() then
			if drop_callback then
				drop_callback()
			end
			return
		else
			item:SetAbsOrigin(position_callback())
			return 0.03
		end
	end)

	item._holder = unit

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
		-- item:FollowEntity(nil,false)
		-- item:SetAbsOrigin(GetGroundPosition(unit:GetAbsOrigin(), unit))
	end

	return item
end

function Frostivus:OnPickupItem( item, caster )
	-- local caster = PlayerResource:GetSelectedHeroEntity(ply:GetPlayerID())

	local old_container = item:GetContainer()

	local model = Frostivus.ItemsKVs[item:GetName()].Model
	local charges = item:GetCurrentCharges()
	local counter = item._counter
	local prop = item._prop

	Frostivus:L(item:GetName()..":"..tostring(charges))

	caster:DropItemAtPositionImmediate(item, caster:GetAbsOrigin())

	if not Frostivus.ItemsKVs[item:GetName()].CantPickup then
		if Frostivus:IsCarryingItem( caster ) then
			Frostivus:L("Swapping Items...")
			local item = Frostivus:DropItem( caster, Frostivus:GetCarryingItem( caster ) )
			item:FollowEntity( nil, false )
			item:SetAbsOrigin(old_container:GetAbsOrigin())
		end

		local item = item:GetContainer()

		-- Move bench API to new container
		if old_container.wp then
			old_container.wp:SetEntity(item:entindex())

			if old_container.progress then
				old_container.progress:SetEntity(item:entindex())
			end

			for k,v in pairs(old_container) do
				if k ~= "__self" then
					item[k] = v
				end
			end
		end

		-- Plate stack
		if counter then
			item._counter = counter
			item:SetModel("models/plates/dirty_plate_"..tostring(counter)..".vmdl")
		end

		-- Prop
		if prop then
			item._prop = prop
			item._prop:FollowEntity(item, false)
		end
		
		caster:BindItem( item )
	end
end

function Frostivus:ResetStage( origin )
	local entities = Entities:FindAllInSphere(origin, 4000)
	for k,v in pairs(entities) do
		if IsValidEntity(v) then
			if v.GetContainedItem then -- items
				local item_name = v:GetContainedItem():GetName()
				if v:IsBench() then
					local is_bank = item_name == "item_pot" or item_name == "item_frying_pan"

					if string.match(item_name, "plate") then
						v:RemoveSelf()
					elseif is_bank then
						v:ClearBank()
					else
						v:ClearBench()
					end
				else
					v:RemoveSelf()
				end
			elseif v.GetUnitName then
				if not v._no_init and v.PrepareForRound then
					v:PrepareForRound()
					v._no_init = true

					if v.ResetBench then
						v:ResetBench()
					end
				elseif v:IsBench() then
					if not string.match(v:GetUnitName(), "crate") then
						v:ClearBench()
					end
					if v.ResetBench then
						v:ResetBench()
					end
				end
			end
		end
	end
end

function Frostivus:ClearStage( origin )
	local entities = Entities:FindAllInSphere(origin, 1500)
	for k,v in pairs(entities) do
		if IsValidEntity(v) then
			if v.GetContainedItem then
				v:RemoveSelf()
			elseif v.GetUnitName and v:IsBench() then
				v:RemoveSelf()
				if v.wp then
					v.wp:Delete()
				end
			end
		end
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
	if Frostivus.DEBUG and s then
		print("[Frostivus] "..s)
	end
end