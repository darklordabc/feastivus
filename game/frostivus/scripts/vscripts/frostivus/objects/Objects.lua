function CreateBank(name, count, on_added_particle, on_cooking_particle, GetTarget, CheckItem)
    local pot = CreateItemOnPositionSync(Vector(0,0,0),CreateItem(name,nil,nil))

    BenchAPI(pot)
    pot:InitBench( count, CheckItem, nil, 0 )
    pot:SetRefineDuration(10.0)

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