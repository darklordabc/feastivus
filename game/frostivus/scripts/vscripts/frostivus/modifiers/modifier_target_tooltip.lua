modifier_target_tooltip = class({})

function modifier_target_tooltip:OnCreated(kv)
	if IsServer() then
		print("the target tooltip particle is create on unit", self:GetParent():GetUnitName())
		local pid = ParticleManager:CreateParticle("particles/frostivus/generic_gameplay/current_target_mark.vpcf",PATTACH_ABSORIGIN,self:GetParent())
		ParticleManager:SetParticleControl(pid,0,self:GetParent():GetOrigin()+Vector(0,0,150))
		ParticleManager:SetParticleControl(pid,1,Vector(7,247,7))
		self:AddParticle(pid,true,false,0,false,false)
	end
end