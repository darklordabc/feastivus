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
    if units then
        unit = EntIndexToHScript(units["0"])
        if unit then
            if unit.skip then
                unit.skip = false
                return true
            end
        end
    end

    if order_type == DOTA_UNIT_ORDER_RADAR or order_type == DOTA_UNIT_ORDER_GLYPH then return end

    if unit.moving_timer then
        Timers:RemoveTimer(unit.moving_timer)
        unit.moving_timer = nil
        unit.moving_target = nil
    end

    if order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
        unit.moving_target = EntIndexToHScript(targetIndex)

        if (unit.moving_target:GetAbsOrigin() - unit:GetAbsOrigin()):Length() <= 128 then
            unit.moving_target:TriggerOnUse(unit)
            return true
        end
    	
        -- unit.moving_timer = Timers:CreateTimer(function() 
        --     if not (unit and IsValidEntity(unit) and unit:IsAlive()) then
        --         return
        --     end

        --     if unit.moving_target and unit.moving_timer then
        --         local distance = (unit.moving_target:GetAbsOrigin() - unit:GetAbsOrigin()):Length()
                
        --         if distance > 128 then
        --             unit:MoveToNPC(unit.moving_target)
        --             return 0.25
        --         else
        --         	unit.moving_target:TriggerOnUse(unit)

        --             Frostivus:L("Using Entity: "..unit.moving_target:GetUnitName()..":"..tostring(unit.moving_target:entindex()))

			     --    unit.moving_timer = nil
			     --    unit.moving_target = nil

        --             return
        --         end
        --     else
        --         return
        --     end
        -- end)

        return true
    end

    return true
end