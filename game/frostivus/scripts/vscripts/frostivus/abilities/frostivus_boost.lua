frostivus_boost = class({})

function frostivus_boost:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_frostivus_boost", {})
	EmitSoundOn("DOTA_Item.ForceStaff.Activate", caster)

	-- clear the last boost target position
	caster._vBoostLastOrderPosition = nil
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
			
			-- make the direction slightly changed to the ordered direction
			local w, cw
			if caster._vBoostLastOrderPosition then
				local orderDir = (caster._vBoostLastOrderPosition - caster:GetOrigin()):Normalized()
				local crossProduct = self.vDir:Cross(orderDir)
				if crossProduct.z > 0 then
					w = true
				end
				if crossProduct.z < 0 then
					cw = true
				end
			end
			if w then
				self.vDir = RotatePosition(Vector(0,0,0),QAngle(0,8 * 400 / self.speed,0),self.vDir)
			end
			if cw then
				self.vDir = RotatePosition(Vector(0,0,0),QAngle(0,-8 * 400 / self.speed,0),self.vDir)
			end

			caster:SetForwardVector(self.vDir)

			self.speed = self.speed - 150 * FrameTime()

			for _, ally in ipairs(allies) do
				if ally ~= caster then
					if ally:HasModifier('modifier_frostivus_boost') then
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
							self.distance = math.min(200, self.distance - 25)
					else
						if not ally:HasModifier('modifier_knockback') then
							-- just kock back
							local distance = 64
							local speed = 800
							local duration = 0.4
							local center = caster:GetOrigin()

							local knockback =	{
								should_stun = false,
								knockback_duration = distance / speed,
								duration = distance / speed,
								knockback_distance = distance,
								knockback_height = distance * 0.2,
								center_x = center.x,
								center_y = center.y,
								center_z = center.z
							}

							ally:AddNewModifier(caster, ability, "modifier_knockback", knockback)
						end
					end
				end
			end

			local newPos = GetGroundPosition(position, caster) + self.vDir * self.speed * FrameTime()

			if GridNav:CanFindPath(caster:GetAbsOrigin(), newPos) then
				caster:SetAbsOrigin( newPos )
				self.dist_travelled = self.dist_travelled + self.speed * FrameTime()
			else
				local velocityC = caster:GetForwardVector() * self.speed
				local newVel = Vector(-velocityC.x, -velocityC.y)
				
				self.vDir = newVel:Normalized() * Vector(1,1,0)
				self.speed = newVel:Length2D()
				position = position + self.vDir * CalculateDistance(caster:GetAbsOrigin(), newPos)
				caster:SetAbsOrigin(GetGroundPosition(position, caster))
				self.dist_travelled = 0
				self.distance = math.min(125, self.distance - 25)
			end
		else
			if not GridNav:CanFindPath(caster:GetAbsOrigin(), caster:GetAbsOrigin()) then FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true) end
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