modifier_hide_health_bar = class({})

function modifier_hide_health_bar:CheckState()
    local state = {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }

    return state
end

function modifier_hide_health_bar:IsHidden()
    return true
end

modifier_carrying_item = class({})

function modifier_carrying_item:IsHidden()
    return true
end

modifier_unselectable = class({})

function modifier_unselectable:CheckState()
    local state = {
        [MODIFIER_STATE_UNSELECTABLE] = true
    }

    return state
end

function modifier_unselectable:IsHidden()
    return true
end

modifier_preround_freeze = class({})

function modifier_preround_freeze:CheckState()
    return {
        [MODIFIER_STATE_FROZEN] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_SILENCED] = true
    }
end

function modifier_preround_freeze:IsHidden()
    return true
end

function modifier_preround_freeze:IsPurgable()
    return false
end

modifier_rooted = class({})

function modifier_rooted:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true,
    }
end

function modifier_rooted:IsHidden()
    return true
end

function modifier_rooted:IsPurgable()
    return false
end

modifier_bench_busy = class({})

function modifier_bench_busy:IsHidden()
    return true
end

modifier_fake_casting = class({})

if IsServer() then
    function modifier_fake_casting:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ORDER
        }

        return funcs
    end

    function modifier_fake_casting:IsHidden()
        return true
    end

    function modifier_fake_casting:OnOrder()
        EndAnimation(self:GetParent())
        self:Destroy()
    end
end

modifier_command_restricted = class({})

function modifier_command_restricted:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
    }
end

function modifier_command_restricted:IsHidden()
    return true
end

function modifier_command_restricted:IsPurgable()
    return false
end