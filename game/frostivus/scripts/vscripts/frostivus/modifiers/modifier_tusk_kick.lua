modifier_tusk_kick = class({})

function modifier_tusk_kick:IsHidden()
	return false
end

function modifier_tusk_kick:IsPurgable()
	return false
end

function modifier_tusk_kick:IsStunDebuff()
	return true
end

function modifier_tusk_kick:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

function modifier_tusk_kick:OnCreated(kv)
	if IsServer() then
        local jumper = self:GetParent()
		local dir = kv.Direction
		local targetPos
		if dir == "left" then
			targetPos = jumper:GetOrigin() + Vector(-900,0,0)
        	self.vDirection = Vector(-1, 0, 0)
		else
			targetPos = jumper:GetOrigin() + Vector(900,0,0)
        	self.vDirection = Vector( 1, 0, 0)
		end
        self.vStartPos = jumper:GetOrigin()
        self:GetParent():SetForwardVector(self.vDirection)
        self.flSpeed = 1000
        self.flHeight = 100
        self.flDistance = (targetPos - self.vStartPos):Length2D()
        if self:ApplyVerticalMotionController() == false then self:Destroy() end
        if self:ApplyHorizontalMotionController() == false then self:Destroy() end

        local pid = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruskick_txt_ult.vpcf", PATTACH_WORLDORIGIN, jumper)
        ParticleManager:SetParticleControl(pid, 0, jumper:GetOrigin())
        ParticleManager:SetParticleControl(pid, 2, jumper:GetOrigin())
        ParticleManager:ReleaseParticleIndex(pid)

        jumper:StartGesture(ACT_DOTA_FLAIL)

        EmitSoundOn("Hero_Tusk.WalrusKick.Target", jumper)
	end
end

function modifier_tusk_kick:UpdateHorizontalMotion(me, dt)
    if IsServer() then
        local vNewPos = self:GetParent():GetOrigin() + self.vDirection * self.flSpeed * dt
        vNewPos.z = 0
        me:SetOrigin(vNewPos)
    end
end

function modifier_tusk_kick:UpdateVerticalMotion(me, dt)
    if IsServer() then
        local origin = me:GetOrigin()
        local distance = (origin - self.vStartPos):Length2D()
        local z = -4 * self.flHeight / (self.flDistance * self.flDistance) * (distance * distance) + 4 * self.flHeight / self.flDistance * distance + self.vStartPos.z
        origin.z = z
        local groundHeight = GetGroundHeight(origin, self:GetParent())
        local landed = false
        if (origin.z < groundHeight and distance >= self.flDistance) then
            origin.z = groundHeight
            landed = true
        end

        me:SetOrigin(origin)

        if landed then
            self:GetParent():RemoveHorizontalMotionController(self)
            self:GetParent():RemoveVerticalMotionController(self)
            self:SetDuration(0.1, true)
        end
    end
end

function modifier_tusk_kick:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveHorizontalMotionController(self)
        self:GetParent():RemoveVerticalMotionController(self)
        self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_phased", {Duration = 0.2})
        self:GetParent():RemoveGesture(ACT_DOTA_FLAIL)
    end
end