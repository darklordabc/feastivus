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

if IsServer() then
    function modifier_cooking_pot:OnCreated(kv)
        self:StartIntervalThink(0.1)
    end

    function modifier_cooking_pot:OnIntervalThink()
        local caster = self:GetParent()

        if caster.GetBenchItemBySlot and caster:GetBenchItemBySlot(1) == "item_pot" then
            local pot = Frostivus:GetCarryingItem(caster)

            if not pot._cooking then
                if pot:GetBenchItemBySlot(1) then
                    StartCooking( pot )
                end
            else
                local old_data = pot.progress:GetData()

                if old_data.progress >= 100 then
                    
                else
                    old_data.progress = math.min(old_data.progress + (0.1 * (100 / pot:GetRefineDuration())), 100)

                    pot.progress:SetData(old_data)
                end
            end
        else

        end
    end
end

LinkLuaModifier("modifier_cooking_pot", "frostivus/abilities/frostivus_cooking_pot.lua", 0)

function CreatePot()
    local pot = CreateItemOnPositionSync(Vector(0,0,0),CreateItem("item_pot",nil,nil))

    BenchAPI(pot)
    pot:InitBench( 3, CanPutItemInPot, nil, 0 )
    pot:SetRefineDuration(7.0)

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

    pot.bubbles = pot.bubbles or ParticleManager:CreateParticle("particles/frostivus_gameplay/pot_bubbles.vpcf",PATTACH_ABSORIGIN_FOLLOW,pot)

    pot._cooking = true
end