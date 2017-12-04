-- Based on @Wouterz90 code from https://github.com/ModDota/AbilityLuaSpellLibrary

LinkLuaModifier("modifier_tusk_snowball_dummy","frostivus/abilities/frostivus_snowball.lua",LUA_MODIFIER_MOTION_NONE)

frostivus_snowball = class({})

function frostivus_snowball:OnSpellStart()
    local caster = self:GetCaster()
    local target = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin() - Vector(0,2200,0), false, nil, nil, DOTA_TEAM_GOODGUYS)

    self.target = target
    local windup_time = self:GetSpecialValueFor("snowball_windup")
    local snowball_duration = self:GetSpecialValueFor("snowball_duration")
    local radius = self:GetSpecialValueFor("snowball_radius") /2
    local snowball_speed = self:GetSpecialValueFor("snowball_speed")

    target:AddNewModifier(caster,self,"modifier_tusk_snowball_target_vision",{duration = windup_time + snowball_duration})
    caster:AddNewModifier(caster,self,"modifier_tusk_snowball_auto_launch_controller",{duration = windup_time})
    caster:AddNewModifier(caster,self,"modifier_tusk_snowball_host",{duration = windup_time+snowball_duration})

    caster:EmitSound("Hero_Tusk.Snowball.Cast")

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_snowball_form.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 4, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    caster:AddNewModifier(caster,self,"modifier_tusk_snowball_dummy",{})

    particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_snowball.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) --Target
    ParticleManager:SetParticleControl(particle, 2, Vector(snowball_speed,snowball_speed,snowball_speed))
    ParticleManager:SetParticleControl(particle, 3, Vector(radius,radius,radius))

    self.particle = particle
    self.unitsHit = {}
    self.unitInSnowball = {}
    self.unitInSnowball[caster] = true

    self:ReleaseSnowball()
end

function frostivus_snowball:ReleaseSnowball()
    local caster = self:GetCaster()
    local target = self.target
    local snowball_speed = self:GetSpecialValueFor("snowball_speed")

    if not _G.SNOWBALL_SOUND then
        _G.SNOWBALL_SOUND = caster
        caster:EmitSound("Hero_Tusk.Snowball.Loop")
    end
    
    local projectile_table =
    {
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = "particles/dev/empty_particle.vpcf",
        iMoveSpeed = snowball_speed,
        vSourceLoc= caster:GetAbsOrigin(),
        bDrawsOnMinimap = false,
        bDodgeable = false,
        bIsAttack = false,
        bVisibleToEnemies = true,
        flExpireTime = GameRules:GetGameTime() + 10,
        bProvidesVision = false,
    }
    ProjectileManager:CreateTrackingProjectile(projectile_table)
end

function frostivus_snowball:OnProjectileThink(vLocation)
    local caster = self:GetCaster()
    local stun_duration = self:GetSpecialValueFor("stun_duration")

    for unit,_ in pairs(self.unitInSnowball) do
        unit:SetAbsOrigin(vLocation)
    end

    local units = FindUnitsInRadius(caster:GetTeamNumber(),vLocation,nil,self.radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
    for _,unit in pairs(units) do
        if not self.unitsHit[unit] then
            if unit:GetUnitName() == "npc_dota_hero_axe" then
                self.unitsHit[unit] = true
                local knockbackModifierTable =
                {
                    should_stun = 1,
                    knockback_duration = stun_duration,
                    duration = stun_duration,
                    knockback_distance = 10,
                    knockback_height = 80,
                    center_x = unit:GetAbsOrigin().x,
                    center_y = unit:GetAbsOrigin().y,
                    center_z = unit:GetAbsOrigin().z
                }
                unit:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )
                caster:EmitSound("Hero_Tusk.Snowball.ProjectileHit")
            end
        end
    end
end

function frostivus_snowball:OnProjectileHit(hTarget, vLocation)
    self:GetCaster():FindModifierByName("modifier_tusk_snowball_dummy")
    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)

    if _G.SNOWBALL_SOUND == self:GetCaster() then
        _G.SNOWBALL_SOUND = nil
        self:GetCaster():StopSound("Hero_Tusk.Snowball.Loop")
    end

    self:GetCaster():AddNoDraw()
    self.target:RemoveSelf()
end

modifier_tusk_snowball_dummy = class({})

function modifier_tusk_snowball_dummy:IsPermanent() return true end

function modifier_tusk_snowball_dummy:CheckState()
    return {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
end

function modifier_tusk_snowball_dummy:OnCreated()
    if IsServer() then
        local ability = self:GetAbility()
        ability.radius = ability:GetSpecialValueFor("snowball_radius")/2
        self:StartIntervalThink(1)
    end
end

function modifier_tusk_snowball_dummy:OnIntervalThink()
    local ability = self:GetAbility()
    local snowball_grow_rate = ability:GetSpecialValueFor("snowball_grow_rate")
    ability.radius = ability.radius + snowball_grow_rate
    ParticleManager:SetParticleControl(ability.particle, 3, Vector(ability.radius,ability.radius,ability.radius)) --Radius
end