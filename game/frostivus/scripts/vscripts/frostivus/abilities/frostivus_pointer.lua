frostivus_pointer = class({})

function frostivus_pointer:OnSpellStart()
	local caster = self:GetCaster()

	local modifier = caster:FindModifierByName("modifier_pointer")
	if modifier.target and modifier.target.TriggerOnUse then
		modifier.target:TriggerOnUse(caster)
	end
end

function frostivus_pointer:OnUpgrade()
	local caster = self:GetCaster()
end

function frostivus_pointer:GetIntrinsicModifierName()
    return "modifier_pointer"
end

modifier_pointer = class({})
LinkLuaModifier("modifier_pointer", "frostivus/abilities/frostivus_pointer.lua", 0)

if IsServer() then
	function modifier_pointer:OnCreated(keys)
		self:StartIntervalThink(0.1)
	end

	function modifier_pointer:OnIntervalThink()
		local caster = self:GetParent()

		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 128, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

		for k,v in pairs(units) do
			if not IsInFront(caster:GetAbsOrigin(),v:GetAbsOrigin(),caster:GetForwardVector(), 40) then
				units[k] = nil
			end
		end

		if #units > 0 and caster:IsIdle() then
			for k,v in pairs(units) do
				if v:HasModifier("modifier_bench") then
					if self.particle and v ~= self.target then
						ParticleManager:DestroyParticle(self.particle, true)
						self.particle = nil
						self.target = nil
					end
					if not self.particle then
						self.particle = ParticleManager:CreateParticleForPlayer( "particles/frostivus_gameplay/bench_highlight.vpcf", PATTACH_OVERHEAD_FOLLOW, v, caster:GetPlayerOwner() )
						-- ParticleManager:SetParticleControl( self.particle, 1, Vector( 255, 125, 0 ) )
						-- ParticleManager:SetParticleControl( self.particle, 2, Vector( 820, 32, 820 ) )
						self.target = v
					end

					break
				end
			end
		elseif self.particle then
			ParticleManager:DestroyParticle(self.particle, true)
			self.particle = nil
			self.target = nil
		end
	end
end