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

    if unit._order_timer then
        local ab = EntIndexToHScript(abilityIndex)
        if not ab or not ab.GetBehavior or bit.band(ab:GetBehavior(), DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT) ~= DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT then
            if unit._order_timer then
                Timers:RemoveTimer(unit._order_timer)
                unit._order_timer = nil
            end
        end
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
        unit.moving_target = moveTarget

        local old_pos = unit:GetAbsOrigin()
        local position_target = unit.moving_target:GetAbsOrigin()
        local positions = {position_target + Vector(FROSTIVUS_CELL_SIZE,0,0), position_target + Vector(-FROSTIVUS_CELL_SIZE,0,0), position_target + Vector(0,FROSTIVUS_CELL_SIZE,0), position_target + Vector(0,-FROSTIVUS_CELL_SIZE,0)}
        local closest = nil

        local function TriggerBench()
            print("bench triggered!")
            -- player cannot trigger benches too quickly
            -- prevent auto repeat right click
            if unit.__flLastTriggerTime == nil then
                unit.__flLastTriggerTime = GameRules:GetGameTime()
            else
                local now = GameRules:GetGameTime()
                if now - unit.__flLastTriggerTime < .2 then
                    return
                end
                unit.__flLastTriggerTime = now
            end

            unit:AddNewModifier(unit,nil,"modifier_rooted",{duration = 0.06})
            unit:SetForwardVector(UnitLookAtPoint( unit, unit.moving_target:GetAbsOrigin() ))
            unit:MoveToPosition(unit:GetAbsOrigin() - (unit:GetAbsOrigin() - unit.moving_target:GetAbsOrigin()):Normalized())
            -- 
            Timers:CreateTimer(0.06, function (  )
                unit.moving_target:TriggerOnUse(unit)
            end)
        end

        -- if the order is to move to serve bench
        -- change it to move to one of the nearest valid positions instead
        -- 
        if moveTarget:GetUnitName() == "npc_serve_table" then
            print("ordering to move to serve t1able")
            -- change the order to move to position
            local fw = moveTarget:GetForwardVector()
            local bo = moveTarget:GetOrigin()
            -- collect free cells
            local freeCells = {}
            if fw.x == 1 then
                table.insert(freeCells, bo + Vector(-80,0,0))
                table.insert(freeCells, bo + Vector(80,0,0))
                table.insert(freeCells, bo + Vector(-80,-128,0))
                table.insert(freeCells, bo + Vector(80,-128,0))
                table.insert(freeCells, bo + Vector(-80,128,0))
                table.insert(freeCells, bo + Vector(80,128,0))
            end
            if fw.y == 1 then
                table.insert(freeCells, bo + Vector(0,80,0))
                table.insert(freeCells, bo + Vector(0,-80,0))
                table.insert(freeCells, bo + Vector(-128,80,0))
                table.insert(freeCells, bo + Vector(128,-80,0))
                table.insert(freeCells, bo + Vector(-128,80,0))
                table.insert(freeCells, bo + Vector(128,-80,0))
            end
            local nearest = 9999
            local o = unit:GetOrigin()
            local to
            for _, pos in pairs(freeCells) do
                -- DebugDrawCircle(pos + Vector(0,0,20), Vector(255,0,0), 128, 64, false, 3)
                local dis = (pos - o):Length2D()
                local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, pos, nil, 32, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
                if dis < nearest and GridNav:CanFindPath(pos, o) and #units <= 0 then
                    nearest = dis
                    to = pos
                end
            end
            if to then
                -- DebugDrawCircle(to + Vector(0,0,20), Vector(0,255,0), 255, 64, false, 3)
                unit:MoveToPosition(to)
                -- create checker
                Timers:CreateTimer(function()
                    if not IsValidAlive(unit) then
                        return nil
                    end
                    if unit._vLastOrderFilterTable ~= filterTable then
                        return nil
                    end
                    if IsBenchReachable(unit, moveTarget) then
                        TriggerBench()
                        return nil
                    end
                    return 0.03
                end)
                return false
            end

            
        end

        if IsBenchReachable(unit, unit.moving_target) then
            TriggerBench()
        else
            for k,v in pairs(positions) do
                -- DebugDrawSphere(v, Vector(200,0,0), 1.0, 64, true, 1.5)
                if not GridNav:IsBlocked(v) then
                    -- DebugDrawSphere(v, Vector(0,200,200), 1.0, 48, true, 3)
                    if not closest or (Distance(unit:GetAbsOrigin(), v) < Distance(unit:GetAbsOrigin(), closest)) then
                        closest = v
                    end
                end
            end

            if closest then
                -- DebugDrawSphere(closest, Vector(20,200,0), 1.0, 32, true, 3)
                unit:MoveToPosition(closest)
            end
            
            unit._order_timer = Timers:CreateTimer(function()
                if not (unit and IsValidEntity(unit) and unit:IsAlive()) then
                    return nil
                end
                -- if unit is issued to move to another target
                -- remove this position checking timer
                if unit._vLastOrderFilterTable ~= filterTable then
                    return nil
                end
                if IsBenchReachable(unit, unit.moving_target) then
                    TriggerBench()
                    return nil
                else
                    return 0.03
                end
            end)
        end

        return false
    end

    return true
end
