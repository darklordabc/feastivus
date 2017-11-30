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

    if issuer ~= -1 then
        unit._vLastOrderFilterTable = filterTable
    end

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
        local positions = {
            position_target + Vector(FROSTIVUS_CELL_SIZE,0,0),
            position_target + Vector(-FROSTIVUS_CELL_SIZE,0,0), 
            position_target + Vector(0,FROSTIVUS_CELL_SIZE,0), 
            position_target + Vector(0,-FROSTIVUS_CELL_SIZE,0)
        }
        local closest = nil

        local function TriggerBench(unit, bench)
            if unit.__flLastTriggerTime == nil then
                unit.__flLastTriggerTime = GameRules:GetGameTime()
            else
                local now = GameRules:GetGameTime()
                if now - unit.__flLastTriggerTime < .2 then
                    return
                end
                unit.__flLastTriggerTime = now
            end

            bench:TriggerOnUse(unit)
        end

        local function MoveToPositionAndTriggerBench(pos)
            Timers:CreateTimer(function()
                local o = unit:GetAbsOrigin()
                if not IsValidAlive(unit) then return nil end
                if (o-pos):Length2D() < 10 or IsBenchReachable(unit, moveTarget) then
                    unit:AddNewModifier(unit, nil, "modifier_phased", {})
                    unit:MoveToPosition(o - (o-moveTarget:GetOrigin()):Normalized())
                    Timers:CreateTimer(function()
                        unit:RemoveModifierByName("modifier_rooted")
                    end)
                    TriggerBench(unit, moveTarget)
                    return nil
                else
                    -- print("Order To Move To Position", pos)
                    -- DebugDrawCircle(pos + Vector(0,0,20), Vector(255,0,0), 200, 64, false, 0.5)
                    ExecuteOrderFromTable({
                        UnitIndex = unit:entindex(),
                        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                        Position = pos,
                    })
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

            -- remove the positions have been taken
            for k, pos in pairs(positions) do
                local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, pos, nil, 32, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
                if #units > 0 then
                    positions[k] = nil
                end
            end
        end

        for k,v in pairs(positions) do
            if v and not GridNav:IsBlocked(v) then
                if not closest or (Distance(unit:GetAbsOrigin(), v) < Distance(unit:GetAbsOrigin(), closest)) then
                    closest = v
                end
            end
        end
        if closest then
            MoveToPositionAndTriggerBench(closest)
        end
        return false
    end

    return true
end
