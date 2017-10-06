frostivus_crate = class({})

function frostivus_crate:OnUpgrade()
	local caster = self:GetCaster()
	caster.SetCrateItem = (function( self, item )
		self:AddItemToBench(item)
        self:SetBenchInfiniteItems(true)
	end)
end

function frostivus_crate:GetIntrinsicModifierName()
    return "modifier_crate"
end

modifier_crate = class({})
LinkLuaModifier("modifier_crate", "frostivus/abilities/frostivus_crate.lua", 0)

modifier_crate_open = class({})
LinkLuaModifier("modifier_crate_open", "frostivus/abilities/frostivus_crate.lua", 0)

function modifier_crate_open:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MODEL_CHANGE,
    }

    return funcs
end

function modifier_crate_open:GetPriority()
    return MODIFIER_PRIORITY_ULTRA
end

function modifier_crate_open:GetModifierModelChange()
    return "models/crate/ingredient_crate_02.vmdl"
end

function modifier_crate_open:IsPurgable()
    return false
end

function modifier_crate_open:IsHidden()
    return true
end