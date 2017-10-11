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

modifier_bench_interaction = class({})
LinkLuaModifier("modifier_bench_interaction", "frostivus/abilities/frostivus_pointer.lua", 0)

if IsServer() then
	function modifier_bench_interaction:OnCreated()
		StartAnimation(self:GetParent(), {duration=-1, activity=ACT_DOTA_GREEVIL_CAST, rate=1, translate="greevil_magic_missile"})
		self:StartIntervalThink(1.0)
	end

	function modifier_bench_interaction:OnIntervalThink()
		StartAnimation(self:GetParent(), {duration=-1, activity=ACT_DOTA_GREEVIL_CAST, rate=1, translate="greevil_magic_missile"})
	end

	function modifier_bench_interaction:OnDestroy()
		EndAnimation(self:GetParent())
	end

	function modifier_bench_interaction:OnOrder()
		-- self:RemoveSelf()
		-- EndAnimation(self:GetParent())
	end
end

function modifier_bench_interaction:IsHidden()
	return true
end

function modifier_bench_interaction:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}
	return state
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

		if #units > 0 then
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