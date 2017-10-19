modifier_teleport_to_new_round = class({})

if IsServer() then
	function modifier_teleport_to_new_round:OnCreated(kv)
		local caster = self:GetParent()
		-- create teleport particle
		local pid = ParticleManager:CreateParticle('particles/econ/events/winter_major_2017/teleport_start_wm07_lvl2.vpcf',PATTACH_ABSORIGIN,caster)
		ParticleManager:SetParticleControl(pid,0,caster:GetOrigin())
		self:AddParticle(pid,true,false,0,true,false)

		-- start play sound
		caster:EmitSound('Portal.Loop_Appear')
		caster:StartGesture(ACT_DOTA_FLAIL)
	end

	function modifier_teleport_to_new_round:CheckState()
		return {
			[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
		}
	end

	function modifier_teleport_to_new_round:OnDestroy()
		local caster = self:GetParent()

		caster:StopSound('Portal.Loop_Appear')

		caster:RemoveGesture(ACT_DOTA_FLAIL)
		EmitSoundOn('Portal.Hero_Disappear',caster)

		-- delayed teleported in sound
		Timers:CreateTimer(0.2, function()
			caster:EmitSound('Portal.Hero_Appear')
		end)
	end
end