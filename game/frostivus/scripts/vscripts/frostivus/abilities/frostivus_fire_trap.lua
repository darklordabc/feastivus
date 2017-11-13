frostivus_fire_trap = class({})

function frostivus_fire_trap:OnUpgrade()
	local caster = self:GetCaster()


end

-- function frostivus_fire_trap:GetIntrinsicModifierName()
--     return "modifier_fire_trap"
-- end

modifier_fire_trap = class({})
LinkLuaModifier("modifier_fire_trap", "frostivus/abilities/frostivus_fire_trap.lua", 0)

if IsServer() then
    function modifier_fire_trap:OnCreated()
        local caster = self:GetParent()
        local fire = true
        local particle

        local walls = {}

        local time = 10.0

        Timers:CreateTimer(function()
            if fire then
                particle = ParticleManager:CreateParticle("particles/frostivus_gameplay/trap_fire.vpcf", PATTACH_CUSTOMORIGIN, caster)
                ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT, "nozzle", caster:GetAbsOrigin(), false)
                ParticleManager:SetParticleControlForward(particle, 0, caster:GetForwardVector())

                for i=1,6 do
                    table.insert(walls, SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = caster:GetAbsOrigin() + (Vector(128 * i, 0) * caster:GetForwardVector()), block_fow = false}))
                end

                EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_DragonKnight.BreathFire", caster)
            else
                ParticleManager:DestroyParticle(particle, false)

                for k,v in pairs(walls) do
                    v:RemoveSelf()
                end
                walls = {}
            end

            fire = not fire

            return time
        end)
    end
end

function modifier_fire_trap:IsHidden()
    return true
end

function modifier_fire_trap:CheckState()
    local state = {
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end