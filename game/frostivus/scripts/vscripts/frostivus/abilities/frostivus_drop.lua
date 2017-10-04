frostivus_drop = class({})

-- function frostivus_drop:IsActivated()
-- 	return Frostivus:IsCarryingItem( self:GetCaster() )
-- end

-- function frostivus_drop:OnAbilityPhaseStart()
-- 	StartAnimation(self:GetCaster(), {duration=0.75, activity=ACT_DOTA_GREEVIL_CAST, rate=1, translate="greevil_miniboss_purple_plague_ward"})
-- end

-- function frostivus_drop:OnAbilityPhaseInterrupted()
-- 	EndAnimation(self:GetCaster())
-- end

function frostivus_drop:OnSpellStart()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_carrying_item") then
		Frostivus:DropItem( caster, caster:FindModifierByName("modifier_carrying_item").item )
	end
end