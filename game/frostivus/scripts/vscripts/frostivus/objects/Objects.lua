Objects = Objects or class({})

-- Do we need a class to manage objects?
-- Functions for that in here
require('frostivus/objects/treadmill')
require('frostivus/objects/garbage_bin')

function Objects:ManageObjectFunctions()
    Timers:CreateTimer(0,function()
    -- Treadmills
-- Name to be filled in!
        local ents = Entities:FindAllByModel("treadmill_model_name")
        for k,v in pairs(ents) do
            Objects:ManageTreadmill(v)
        end
-- Name to be filled in!
        local ents = Entities:FindAllByModel("garbage_bin_mode_name")
        for k,v in pairs(ents) do
        Objects:ManageGarbageBin(v)
        end

        -- Loop while the game is active
        if GameRules:State_Get() < DOTA_GAMERULES_STATE_POST_GAME then
            return FrameTime()
        end
    end)
end

function Objects:FindUnitsOnTop(object)
    local origin = object:GetAbsOrigin()

    object.flRadius = object.flRadius or object:GetBoundingMins().x - object:GetBoundingMaxs().x
    -- Find the distance between the diagonal and use that as radus, then filter what's outside
    -- Sqrt only used once
    object.flDiagonalLength = object.flDiagonalLength  or math.sqrt(2*(object.flRadius * object.flRadius) )
    local objectsInRadius = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,origin,nil,object.flDiagonalLength,DOTA_UNIT_TARGET_TEAM_BOTH,0,0,0,0,false)
    local min = origin - Vector(object.flRadius,object.flRadius,0)
    local max = origin + Vector(object.flRadius,object.flRadius,0)
    local ents = {}
    for k,v in pairs(objectsInRadius) do
        local abs = v:GetAbsOrigin()
        if abs.x > min.x or abs.x < max.x or abs.y > min.y or abs.y < max.y then
            table.insert(ents,v)
        end
    end
    return ents
end