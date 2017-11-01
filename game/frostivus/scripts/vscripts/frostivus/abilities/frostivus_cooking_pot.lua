frostivus_cooking_pot = class({})

function frostivus_cooking_pot:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
        caster:InitBench(1, nil, nil, 0)
        caster:Set3DBench(true)
        caster:SetBenchHidden(true)

        caster:AddItemToBench("item_pot")
        caster:BindItem(CreateBank("item_pot", 3, CanPutItemInPot))
    end)
end

function frostivus_cooking_pot:GetIntrinsicModifierName()
    return "modifier_cooking_pot"
end

modifier_cooking_pot = class({})
LinkLuaModifier("modifier_cooking_pot", "frostivus/abilities/frostivus_cooking_pot.lua", 0)

function CanPutItemInPot( bench, item )
    local item_name = item:GetContainedItem():GetName()
    local first_item = bench:GetBenchItemBySlot(1)

    return Frostivus.ItemsKVs[item_name].CanBePutInPot and (not first_item or first_item == item_name)
end