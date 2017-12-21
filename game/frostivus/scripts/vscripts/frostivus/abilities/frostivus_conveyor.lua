frostivus_conveyor = class({})

function frostivus_conveyor:OnUpgrade()
	local caster = self:GetCaster()

    caster.PrepareForRound = (function (  )
        caster:InitBench(1, nil, nil, 64)

        caster:Set3DBench(false)
        caster:SetBenchHidden(true)
        -- caster:SetFlexibleApproach(10)

        caster.items = {}

        caster:SetCustomInteract(function ( bench, user, item )
            if not bench:IsEmpty() then
                return false
            end

        	local item_name = item:GetContainedItem():GetName()

            local is_old_holder_a_conveyor = false
            is_old_holder_a_conveyor = item._holder:GetUnitName() == "npc_conveyor"

            local old_forward

            if is_old_holder_a_conveyor and bench:GetForwardVector() ~= item._holder:GetForwardVector() then
                old_forward = item._holder:GetForwardVector()
            end

            local new_pos

            -- Player put the item to the conveyor
            if user then
                Frostivus:DropItem( user, item )
                new_pos = Vector(bench:GetAbsOrigin().x, bench:GetAbsOrigin().y, bench:GetAbsOrigin().z + 100)
            else
                new_pos = Vector(item:GetAbsOrigin().x, item:GetAbsOrigin().y, bench:GetAbsOrigin().z + 100)
            end

            item._conveyor_pos = new_pos

            item:FollowEntity(nil,false)

            item:SetAbsOrigin(new_pos)

            local id = #bench.items + 1
            bench.items[id] = item

            bench:AddItemToBench(item, user)
            item._holder = bench

            DebugDrawSphere(bench:GetAbsOrigin() + Vector(0,0,100), Vector(255,0,0), 255, 50, false, 1.06)

            Frostivus:BindItem(item, bench, (function ()
                if not IsValidEntity(item) then
                    return nil
                end

                local threshold = 64
                if is_old_holder_a_conveyor then
                    threshold = 128
                end

                if old_forward and (bench:GetAbsOrigin() - item:GetAbsOrigin()):Length2D() <= 1 then
                    old_forward = nil
                    threshold = 64
                    item._conveyor_pos = Vector(bench:GetAbsOrigin().x, bench:GetAbsOrigin().y, bench:GetAbsOrigin().z + 100)
                    is_old_holder_a_conveyor = false
                end

                if old_forward then
                    new_pos = new_pos + (old_forward * 4)

                    if old_forward.x == 0 then
                        new_pos.x = bench:GetAbsOrigin().x
                    elseif old_forward.y == 0 then
                        new_pos.y = bench:GetAbsOrigin().y
                    end

                    threshold = 128
                else
                    new_pos = new_pos + (bench:GetForwardVector() * 4)

                    if bench:GetForwardVector().x == 0 then
                        new_pos.x = bench:GetAbsOrigin().x
                    elseif bench:GetForwardVector().y == 0 then
                        new_pos.y = bench:GetAbsOrigin().y
                    end
                end



                if (new_pos - item._conveyor_pos):Length2D() > threshold then
                    local units = FindUnitsInRadius(2, new_pos, nil, 128, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE , FIND_CLOSEST, false)
                    local possible_bench
                    local bin

                    for _,v in pairs(units) do
                        if v:GetUnitName() == "npc_bin_bench" then
                            bin = v
                            break
                        elseif v:GetUnitName() == "npc_conveyor" and (v ~= bench) then
                            possible_bench = v
                            break
                        end
                    end

                    if bin then
                        bench.items[id] = nil
                        item:RemoveSelf()
                    elseif possible_bench then
                        Frostivus:DropItem(bench, item)
                        possible_bench._custom_interact(possible_bench, nil, item)
                    else
                        bench.items[id] = nil
                        item:RemoveSelf()
                    end
                    bench:SetItems()
                end

                return new_pos
            end), (function ()
                return Frostivus:IsCarryingItem( bench, item )
            end), (function ()
                -- Frostivus:DropItem( self, item )
            end), true, true)

            -- Timers:CreateTimer(function (  )

            -- end)
        end)
    end)
end

function frostivus_conveyor:GetIntrinsicModifierName()
    return "modifier_conveyor"
end

modifier_conveyor = class({})
LinkLuaModifier("modifier_conveyor", "frostivus/abilities/frostivus_conveyor.lua", 0)