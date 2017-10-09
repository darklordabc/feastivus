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

    unit.__filters_vOrderTable = filterTable

    if order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
        unit.moving_target = EntIndexToHScript(targetIndex)

        if (unit.moving_target:GetAbsOrigin() - unit:GetAbsOrigin()):Length() <= 128 then
            unit.moving_target:TriggerOnUse(unit)
            return true
        end
        
        Timers:CreateTimer(function()
            if not (unit and IsValidEntity(unit) and unit:IsAlive()) then
                return nil
            end
            if unit.__filters_vOrderTable ~= filterTable then -- if another order issued
                return nil
            end
            local distance = (unit.moving_target:GetOrigin() - unit:GetOrigin()):Length2D()
            if distance <= 128 then
                unit.moving_target:TriggerOnUse(unit)
                return nil
            else
                return 0.03
            end
        end)

        return true
    end

    return true
end