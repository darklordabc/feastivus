frostivus_cooking_pot = class({})

function frostivus_cooking_pot:OnUpgrade()
	local caster = self:GetCaster()

    local on_added_particle = "particles/frostivus_gameplay/pot_splash.vpcf"
    local on_cooking_particle = "particles/frostivus_gameplay/pot_bubbles.vpcf"

    ExecOnGameInProgress(function (  )
        caster:InitBench(1, nil, nil, 0)
        caster:Set3DBench(true)
        caster:SetBenchHidden(true)
        caster:SetBenchBindHeight(100)

        caster.ResetBench = (function ( self )
            self:AddItemToBench("item_pot")
            self:BindItem(CreateBank("item_pot", 3, on_added_particle, on_cooking_particle, "custom_sound.boiling", nil, GetBoilTarget, CanPutItemInPot))
        end)
    end)
end

function frostivus_cooking_pot:GetIntrinsicModifierName()
    return "modifier_cooking_pot"
end

modifier_cooking_pot = class({})
LinkLuaModifier("modifier_cooking_pot", "frostivus/abilities/frostivus_cooking_pot.lua", 0)

function GetBoilTarget(v)
    return Frostivus.ItemsKVs[v].BoilTarget
end

function CanPutItemInPot( bench, item )
    local item_name = item:GetContainedItem():GetName()
    local first_item = bench:GetBenchItemBySlot(1)

    return Frostivus.ItemsKVs[item_name].CanBePutInPot and (not first_item or first_item == item_name)
end