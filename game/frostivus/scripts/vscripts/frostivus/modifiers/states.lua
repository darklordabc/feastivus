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