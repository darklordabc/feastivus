frostivus_cooking_pot = class({})

function frostivus_cooking_pot:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
        caster:InitBench(1, nil, nil, 0)
        caster:Set3DBench(true)
        caster:SetBenchHidden(true)

        caster:AddItemToBench("item_pot")
        caster:BindItem(CreatePot())
    end)
end

function frostivus_cooking_pot:GetIntrinsicModifierName()
    return "modifier_cooking_pot"
end

modifier_cooking_pot = class({})
LinkLuaModifier("modifier_cooking_pot", "frostivus/abilities/frostivus_cooking_pot.lua", 0)

function CreatePot()
    local pot = CreateItemOnPositionSync(Vector(0,0,0),CreateItem("item_pot",nil,nil))

    BenchAPI(pot)
    pot:InitBench( 3, CanPutItemInPot, nil, 0 )
    pot:SetRefineDuration(10.0)
    pot:SetOnItemAddedToBench(function ( bench, item )
        ParticleManager:CreateParticle("particles/frostivus_gameplay/pot_splash.vpcf",PATTACH_ABSORIGIN_FOLLOW,bench)
    end)

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
                    if not old_data.cooking_done and GetTableLength(temp_items) == 3 then
                        old_data.cooking_done = true

                        local new_items = {}
                        for k,v in pairs(items) do
                            table.insert(new_items, Frostivus.ItemsKVs[v].BoilTarget)
                        end

                        pot:SetFakeItem(new_items[1])
                        pot:SetItems(new_items)
                    end
                    old_data.overtime = old_data.overtime + delta
                else
                    old_data.overtime = 0
                    old_data.progress = math.min(old_data.progress + (delta * (100 / pot:GetRefineDuration())), 100)
                end

                old_data.hidden = false

                progress:SetData(old_data)

                pot.bubbles = pot.bubbles or ParticleManager:CreateParticle("particles/frostivus_gameplay/pot_bubbles.vpcf", PATTACH_ABSORIGIN_FOLLOW, pot)
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

function CanPutItemInPot( bench, item )
    local item_name = item:GetContainedItem():GetName()
    local first_item = bench:GetBenchItemBySlot(1)

    return Frostivus.ItemsKVs[item_name].CanBePutInPot and (not first_item or first_item == item_name)
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