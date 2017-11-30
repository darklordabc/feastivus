FROSTIVUS_CELL_SIZE = 128

function Frostivus:FilterExecuteOrder( filterTable )
    local units = filterTable["units"]
    local order_type = filterTable["order_type"]
    local issuer = filterTable["issuer_player_id_const"]
    local abilityIndex = filterTable["entindex_ability"]
    local targetIndex = filterTable["entindex_target"]
    local x = tonumber(filterTable["position_x"])
    local y = tonumber(filterTable["position_y"])
    local z = tonumber(filterTable["position_z"])
    local point = Vector(x,y,z)
    local queue = filterTable["queue"] == 1

    local unit
    local numUnits = 0
    local numBuildings = 0
    if units and units["0"] then
        unit = EntIndexToHScript(units["0"])
        if unit then
            if unit.skip then
                unit.skip = false
                return true
            end
        end
    end

    unit._vLastOrderFilterTable = filterTable

    if order_type == DOTA_UNIT_ORDER_RADAR or order_type == DOTA_UNIT_ORDER_GLYPH then return end

    if unit:HasModifier("modifier_frostivus_boost") then
        local targetPosition
        local targetEntity
        if order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
            targetEntity = EntIndexToHScript(targetIndex)
            targetPosition = targetEntity:GetAbsOrigin()
        end
        if order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
            targetPosition = Vector(x, y, z)
        end
        if targetEntity then
            unit._vBoostLastOrderTarget = targetEntity
        end
        if targetPosition then
            unit._vBoostLastOrderPosition = targetPosition
            return false
        end
    end

    if order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
        local moveTarget = EntIndexToHScript(targetIndex)

        local old_pos = unit:GetAbsOrigin()
        local position_target = moveTarget:GetAbsOrigin()
        local positions = {position_target + Vector(FROSTIVUS_CELL_SIZE,0,0), position_target + Vector(-FROSTIVUS_CELL_SIZE,0,0), position_target + Vector(0,FROSTIVUS_CELL_SIZE,0), position_target + Vector(0,-FROSTIVUS_CELL_SIZE,0)}
        local closest = nil

        local function MoveToPositionAndTriggerBench(pos)
            if unit.__flLastTriggerTime == nil then
                unit.__flLastTriggerTime = GameRules:GetGameTime()
            else
                local now = GameRules:GetGameTime()
                if now - unit.__flLastTriggerTime < .2 then
                    return
                end
                unit.__flLastTriggerTime = now
            end

            unit:MoveToPosition(pos)

            -- keep trying to move to the target position until this unit received another order
            Timers:CreateTimer(function()
                local o = unit:GetAbsOrigin()
                if not IsValidAlive(unit) then return nil end
                if not unit._vLastOrderFilterTable == filterTable then return nil end
                if (o-pos):Length2D() < 10 then
                    -- make the unit facing the bench
                    unit:AddNewModifier(unit, nil, "modifier_rooted", {Duration=0.06})
                    unit:MoveToPosition(o - (o - moveTarget:GetAbsOrigin()):Normalized())
                    Timers:CreateTimer(0.06, function()
                        moveTarget:TriggerOnUse(unit)
                    end)
                    return nil
                else
                    return 0.03
                end
            end)
        end

        -- special serve positions for serve table
        if moveTarget:GetUnitName() == "npc_serve_table" then
            -- change the order to move to position
            local fw = moveTarget:GetForwardVector()
            local bo = moveTarget:GetOrigin()
            if fw.x == 1 then
                table.insert(positions, bo + Vector(-FROSTIVUS_CELL_SIZE,-FROSTIVUS_CELL_SIZE,0))
                table.insert(positions, bo + Vector(FROSTIVUS_CELL_SIZE,-FROSTIVUS_CELL_SIZE,0))
                table.insert(positions, bo + Vector(-FROSTIVUS_CELL_SIZE,FROSTIVUS_CELL_SIZE,0))
                table.insert(positions, bo + Vector(FROSTIVUS_CELL_SIZE,FROSTIVUS_CELL_SIZE,0))
            end
            if fw.y == 1 then
                table.insert(positions, bo + Vector(-FROSTIVUS_CELL_SIZE,FROSTIVUS_CELL_SIZE,0))
                table.insert(positions, bo + Vector(FROSTIVUS_CELL_SIZE,-FROSTIVUS_CELL_SIZE,0))
                table.insert(positions, bo + Vector(-FROSTIVUS_CELL_SIZE,FROSTIVUS_CELL_SIZE,0))
                table.insert(positions, bo + Vector(FROSTIVUS_CELL_SIZE,-FROSTIVUS_CELL_SIZE,0))
            end
        end

        for k,v in pairs(positions) do
            if not GridNav:IsBlocked(v) then
                if not closest or (Distance(unit:GetAbsOrigin(), v) < Distance(unit:GetAbsOrigin(), closest)) then
                    closest = v
                end
            end
        end
        MoveToPositionAndTriggerBench(closest)
        return false
    end

    return true
end
