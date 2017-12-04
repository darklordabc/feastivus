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
		local item = caster:FindModifierByName("modifier_carrying_item").item
		Frostivus:DropItem( caster, item )
		item:FollowEntity( nil, false )

		local origin = caster:GetAbsOrigin()
		local pos = GetGroundPosition(origin + (caster:GetForwardVector() * 64), item)
		-- item:SetAbsOrigin(pos)

		-- ensure the target position is reachable
		-- 1, the target position must reachable
		-- 2, cannot put item somewhere height ~= caster 
		if not (GridNav:CanFindPath(origin, pos) and math.abs(GetGroundPosition(origin, caster).z - GetGroundPosition(pos, caster).z) < 32) then
			-- if it's not a valid position, put the item right under unit's feet
			item:SetAbsOrigin(origin)
		else
			FindClearSpaceForUnit(item, pos, true)
		end

		PlayDropSound( item, caster )
	end
end