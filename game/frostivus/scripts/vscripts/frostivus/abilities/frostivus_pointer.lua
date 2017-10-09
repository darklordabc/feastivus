frostivus_pointer = class({})

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
		self:StartIntervalThink(0.2)
	end

	function modifier_pointer:OnIntervalThink()
		local caster = self:GetParent()

		-- self._nFXIndex = ParticleManager:CreateParticle( "particles/ui_mouseactions/unit_highlight.vpcf", PATTACH_ABSORIGIN_FOLLOW, hAttacker )
		-- ParticleManager:SetParticleControl( self._nFXIndex, 1, Vector( 255, 125, 0 ) )
		-- ParticleManager:SetParticleControl( self._nFXIndex, 2, Vector( 820, 32, 820 ) )

		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 128, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

		if #units > 0 then
			for k,v in pairs(units) do
				if v:HasModifier("modifier_bench") then
					if self.particle and v ~= self.target then
						ParticleManager:DestroyParticle(self.particle, true)
						self.particle = nil
						self.target = nil
					end
					if not self.particle then
						self.particle = ParticleManager:CreateParticleForPlayer( "particles/frostivus_gameplay/bench_pointer.vpcf", PATTACH_OVERHEAD_FOLLOW, v, caster:GetPlayerOwner() )
						ParticleManager:SetParticleControlEnt( self.particle, 0, v, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", v:GetAbsOrigin(), true)
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