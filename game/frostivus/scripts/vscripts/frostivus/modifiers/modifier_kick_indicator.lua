modifier_kick_indicator = class({})

function modifier_kick_indicator:OnCreated()
	if IsServer() then
		local owner = self:GetParent()
		local pid = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruspunch_status.vpcf", PATTACH_POINT_FOLLOW, owner)
		ParticleManager:SetParticleControlEnt(pid, 0, owner, PATTACH_POINT_FOLLOW, "attach_attack2", owner:GetOrigin(), false)
		self:AddParticle(pid, true, false, 0, true, false)
		-- EmitSoundOn("Hero_Tusk.WalrusPunch.Cast", owner)
		AddAnimationTranslate(owner, "punch")
	end
end

function modifier_kick_indicator:OnDestroy()
	if IsServer() then
		RemoveAnimationTranslate(self:GetParent())
	end
end