frostivus_boost = class({})

function frostivus_boost:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_frostivus_boost", {})
	EmitSoundOn("DOTA_Item.ForceStaff.Activate", caster)
end

modifier_frostivus_boost = class({})
LinkLuaModifier("modifier_frostivus_boost", "frostivus/abilities/frostivus_boost.lua", 0)

if IsServer() then
	function modifier_frostivus_boost:OnCreated()
		self.vDir = self:GetParent():GetForwardVector() * Vector(1,1,0)
		self.speed = self:GetAbility():GetSpecialValueFor("speed")
		self.distance = self:GetAbility():GetSpecialValueFor("distance")
		self.dist_travelled = 0
		self:StartIntervalThink(0)
	end
	
	function modifier_frostivus_boost:OnIntervalThink()
		local caster = self:GetCaster()
		local position = caster:GetAbsOrigin()
		local hullRadius = caster:GetHullRadius() + caster:GetCollisionPadding() + 50
		GridNav:DestroyTreesAroundPoint(position, hullRadius, true)
		if self.dist_travelled < self.distance then
			local allies = FindUnitsInRadius(caster:GetTeamNumber(), position, nil, hullRadius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			caster:SetForwardVector(self.vDir)
			for _, ally in ipairs(allies) do
				if ally ~= caster and ally:HasModifier("modifier_frostivus_boost") then
					local boost = ally:FindModifierByName("modifier_frostivus_boost")
					local velocityC = caster:GetForwardVector() * self.speed
					local velocityA = ally:GetForwardVector() * boost.speed
					local newVel = Vector(-velocityC.x, -velocityC.y)
					local intersectLength = CalculateDistance(caster, ally) - caster:GetHullRadius() + caster:GetCollisionPadding()
					
					self.vDir = newVel:Normalized() * Vector(1,1,0)
					self.speed = newVel:Length2D()
					position = position + self.vDir * intersectLength
					caster:SetAbsOrigin(GetGroundPosition(position, caster))
					self.dist_travelled = 0
					self.distance = 200
				end
			end
			caster:SetAbsOrigin(GetGroundPosition(position, caster) + self.vDir * self.speed * FrameTime() )
			self.dist_travelled = self.dist_travelled + self.speed * FrameTime()
		else
			ResolveNPCPositions(position, hullRadius)
			self:Destroy()
		end
	end
	
	function modifier_frostivus_boost:OnDestroy()
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_frostivus_boost_ms", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	end
	
end

function modifier_frostivus_boost:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

function modifier_frostivus_boost:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_frostivus_boost:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_frostivus_boost:GetEffectName()
	return "particles/abilities/frostivus_boost.vpcf"
end

function modifier_frostivus_boost:GetStatusEffectName()
	return "particles/status_fx/status_effect_forcestaff.vpcf"
end
function modifier_frostivus_boost:StatusEffectPriority()
	return 15
end

modifier_frostivus_boost_ms = class({})
LinkLuaModifier("modifier_frostivus_boost_ms", "frostivus/abilities/frostivus_boost.lua", 0)

function modifier_frostivus_boost_ms:OnCreated(args)
	self.ms = self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_frostivus_boost_ms:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_frostivus_boost_ms:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_frostivus_boost_ms:GetEffectName()
	return "particles/abilities/frostivus_boost_buff.vpcf"
end

function RotateVector2D(vector, theta)
    local xp = vector.x*math.cos(theta)-vector.y*math.sin(theta)
    local yp = vector.x*math.sin(theta)+vector.y*math.cos(theta)
    return Vector(xp,yp,vector.z):Normalized()
end

function ToRadians(degrees)
	return degrees * math.pi / 180
end

function GetPerpendicularVector(vector)
	return Vector(vector.y, -vector.x)
end

function CalculateDistance(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local distance = (pos1 - pos2):Length2D()
	return distance
end

function CalculateDirection(ent1, ent2)
	local pos1 = ent1
	local pos2 = ent2
	if ent1.GetAbsOrigin then pos1 = ent1:GetAbsOrigin() end
	if ent2.GetAbsOrigin then pos2 = ent2:GetAbsOrigin() end
	local direction = (pos1 - pos2):Normalized()
	return direction
end