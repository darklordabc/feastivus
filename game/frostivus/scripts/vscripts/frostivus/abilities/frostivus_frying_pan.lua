frostivus_frying_pan = class({})

function frostivus_frying_pan:OnUpgrade()
	local caster = self:GetCaster()

    local on_added_particle = "particles/frostivus_gameplay/pot_splash.vpcf"
    local on_cooking_particle = "particles/frostivus_gameplay/pot_bubbles.vpcf"

    ExecOnGameInProgress(function (  )
        caster:InitBench(1, nil, nil, 0)
        caster:Set3DBench(true)
        caster:SetBenchHidden(true)

        caster:AddItemToBench("item_frying_pan")
        caster:BindItem(CreateBank("item_frying_pan", 1, nil, nil, GetFryingTarget, CanPutItemInPan))
    end)
end

function frostivus_frying_pan:GetIntrinsicModifierName()
    return "modifier_frying_pan"
end

modifier_frying_pan = class({})
LinkLuaModifier("modifier_frying_pan", "frostivus/abilities/frostivus_frying_pan.lua", 0)

function GetFryingTarget(v)
    return Frostivus.ItemsKVs[v].FryingTarget
end

function CanPutItemInPan( bench, item )
    local item_name = item:GetContainedItem():GetName()
    local first_item = bench:GetBenchItemBySlot(1)

    return Frostivus.ItemsKVs[item_name].CanBePutInPan and (not first_item or first_item == item_name)
end