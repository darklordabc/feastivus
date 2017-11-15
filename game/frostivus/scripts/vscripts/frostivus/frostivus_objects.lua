function CreateBank(name, count, on_added_particle, on_cooking_particle, prop, GetTarget, CheckItem)
    local pot = CreateItemOnPositionSync(Vector(0,0,0),CreateItem(name,nil,nil))

    BenchAPI(pot)
    pot:InitBench( count, CheckItem, nil, 0 )
    pot:SetRefineDuration(10.0)

    pot.ClearBank = (function ( self )
        self:SetItems({})
        self:SetFakeItem(nil)
        if self.progress then
            self.progress:SetData({ progress = 0, overtime = 0 })
        end
        if IsValidEntity(self._prop) then
            self._prop:RemoveSelf()
            self._prop = nil
        end
    end)

    pot.IsDoneCooking = (function ( self )
        return self.progress and self.progress:GetData().cooking_done
    end)

    if on_added_particle then
        pot:SetOnItemAddedToBench(function ( bench, item )
            ParticleManager:CreateParticle(on_added_particle, PATTACH_ABSORIGIN_FOLLOW, bench)
        end)
    end

    local temp_items

    Timers:CreateTimer(function ()
        local holder = pot:GetHolder()
        local delta = 0.2
        local items = pot.wp:GetData().items

        local progress = pot.progress

        if holder and holder:IsBench() and holder:IsHotBench() then
            if pot:GetBenchItemBySlot(1) then
                if not progress or not progress:GetData().cooking_done then
                    StartCooking( pot )

                    pot:SetFakeItem(nil)

                    progress = pot.progress
                end
            else
                return delta
            end

            if progress then
                local old_data = progress:GetData()

                if prop and not pot._prop then
                    pot._prop = SpawnEntityFromTableSynchronous("prop_dynamic",{
                        model = Frostivus.ItemsKVs[GetTarget(items[1])].Model,
                    })
                    pot._prop:FollowEntity(pot, false)
                end

                if not deepcompare(temp_items,items) and not old_data.cooking_done then
                    old_data.progress = math.max(old_data.progress - ((100 / pot:GetRefineDuration()) * 4), 0)
                end

                if old_data.progress >= 100 then
                    if not old_data.cooking_done and GetTableLength(temp_items) == count then
                        old_data.cooking_done = true

                        local new_items = {}
                        for k,v in pairs(items) do 
                            table.insert(new_items, GetTarget(v))
                        end

                        pot:SetFakeItem(new_items[1])
                        pot:SetItems(new_items)
                    end
                    old_data.overtime = old_data.overtime + delta

                    if old_data.overtime >= 7 then
                        pot:SetItems({})
                        pot:SetFakeItem(nil)

                        old_data.progress = 0
                    end
                else
                    old_data.overtime = 0
                    old_data.progress = math.min(old_data.progress + (delta * (100 / pot:GetRefineDuration())), 100)
                end

                old_data.hidden = false

                progress:SetData(old_data)

                pot.bubbles = pot.bubbles or ParticleManager:CreateParticle(on_cooking_particle, PATTACH_ABSORIGIN_FOLLOW, pot)
            end
        else
            pot._cooking = false

            if pot.progress then
                local old_data = progress:GetData()

                if GetTableLength(items) == 0 then
                    old_data.progress = 0
                end

                old_data.overtime = 0
                old_data.progress = 0
                old_data.hidden = true

                progress:SetData(old_data)

                if pot.bubbles then
                    ParticleManager:DestroyParticle(pot.bubbles, false)
                    pot.bubbles = nil
                end
            end
        end

        temp_items = {}
        for k,v in pairs(items) do
            temp_items[k] = v
        end

        return delta
    end)

    return pot
end

function StartCooking( pot )
    pot.progress = pot.progress or WorldPanels:CreateWorldPanelForAll({
        layout = "file://{resources}/layout/custom_game/worldpanels/channeling.xml",
        data = { progress = 0 },
        entity = pot,
        entityHeight = 0
    })

    local old_data = pot.progress:GetData()
    old_data.hidden = false
    old_data.max_overtime = 7.0
    -- old_data.progress = 0
    pot.progress:SetData(old_data)

    -- pot._cooking = true
end

function AddPlateStack(caster, quantity)
    local stack = Frostivus:GetCarryingItem(caster)
    if stack and quantity then
        if stack:GetContainedItem():GetName() == "item_clean_plates" then
            stack._count = stack._count + quantity
            stack:SetModel("models/plates/clean_plate_"..tostring(stack._count)..".vmdl")
            return
        elseif stack:GetContainedItem():GetName() == "item_plate" then
            quantity = 1 + quantity
            caster:ClearBench()
        end
    end

    quantity = quantity or 3

    if quantity == 1 then
        local single_plate = CreatePlate(  )
        caster:AddItemToBench("item_plate")
        caster:BindItem(single_plate)
        return single_plate
    end

    caster:AddItemToBench("item_clean_plates")

    stack = CreateItemOnPositionSync(caster:GetAbsOrigin(), CreateItem("item_clean_plates", caster, caster))
    stack:SetModel("models/plates/clean_plate_"..tostring(quantity)..".vmdl")

    caster:BindItem(stack)

    BenchAPI(stack)
    stack:InitBench(1, (function()
        return false
    end), nil, nil, true)
    stack:SetBenchHidden(true)
    stack:AddItemToBench("item_plate")
    stack:SetBenchInfiniteItems(true)

    stack._count = quantity

    stack.PickItemFromBench = (function( self, user, item_name )
        stack._count = stack._count - 1

        local plate = CreatePlate()

        if stack._count == 1 then
            local bench = stack:GetHolder()

            Frostivus:DropItem( bench, stack )
            bench:PickItemFromBench(bench, stack):RemoveSelf()

            -- Replacing stack with last plate
            local last_plate = CreatePlate()

            bench:AddItemToBench(last_plate, user)
            bench:BindItem(last_plate)
        else
            stack:SetModel("models/plates/clean_plate_"..tostring(stack._count)..".vmdl")
        end

        if not self._bench_infinite_items then
            self:SetItems({})

            self:OnPickedFromBench(plate)
        end
        
        return plate
    end)

    return stack
end

function CreatePlate(  )
    local plate = CreateItemOnPositionSync(Vector(0,0,0),CreateItem("item_plate",nil,nil))

    BenchAPI(plate)
    plate:InitBench( 3, CanPutItemOnPlate, nil, 0 )
    plate:SetOnPickedFromBench(function ( picked_item )
        
    end)
    plate:SetOnBenchIsFull( function ( plate, items, user )
        local result

        for k,v in pairs(Frostivus.RecipesKVs["1"]) do
            if CheckRecipe(items, v.Assembly) then
                result = k
                break
            end
        end

        if result then
            local holder = plate._holder
            plate:RemoveSelf()
            local dish = CreateItemOnPositionSync(holder:GetAbsOrigin(),CreateItem(result,nil,nil))

            -- plate._holder:RemoveModifierByName("modifier_carrying_item")
            -- local item = 
            -- Timers:CreateTimer(function (  )
                
            -- end)

            if holder:IsBench() then
                holder:AddItemToBench(result, user)
                holder:BindItem(dish)
            else
                Timers:CreateTimer(function (  )
                    holder:BindItem(dish)
                end)
            end
        end
    end )

    return plate
end

function CheckRecipe(items, recipe)
    local function IDArray( a )
        local new = {}
        for k,v in pairs(a) do
            table.insert(new, Frostivus.ItemsKVs[v].ID)
        end
        table.sort(new)
        return new
    end

    local v1 = IDArray( items )
    local v2 = IDArray( recipe )

    return deepcompare(v1,v2,true)
end

function CanPutItemOnPlate( bench, item )
    local item_name = item:GetContainedItem():GetName()

    for k,v in pairs(Frostivus.RecipesKVs["1"]) do
        for k1,v1 in pairs(v.Assembly) do

            if v1 == item_name then
                return true
            end
        end
    end

    return false
end