local particle_name = "particles/units/heroes/hero_lich/lich_chain_frost.vpcf"

function LaunchProjectile( u1, u2, ability )
	local info = {
		Target = u2,
		Source = u1,
		Ability = ability,
		EffectName = particle_name,
		bDodgeable = false,
		bProvidesVision = true,
		iMoveSpeed = 500,
		iVisionRadius = 800,
		iVisionTeamNumber = 3,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
	}
	ProjectileManager:CreateTrackingProjectile( info )
end

function OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	StartAnimation(caster, {duration=0.4, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.0})
	caster:SetForwardVector(UnitLookAtPoint( caster, target:GetAbsOrigin() ))
	caster:Stop()

	Timers:CreateTimer(0.3, function (  )
		ability.counter = 1
		LaunchProjectile( caster, target, ability )
	end)
end

function OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local unit = keys.target
	local targets = keys.target_entities
	local target_to_jump

	unit:EmitSound("Hero_Lich.ChainFrostImpact.Hero")

	for _,target in pairs(targets) do
		if target ~= unit and not target_to_jump then
			target_to_jump = target
		end
	end

	ability.counter = ability.counter + 1

	if ability.counter < keys.jumps then
		LaunchProjectile(unit, target_to_jump, ability)
	end
end