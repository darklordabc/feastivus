frostivus_conveyor = class({})

function frostivus_conveyor:OnUpgrade()
	local caster = self:GetCaster()

    caster.PrepareForRound = (function (  )
        caster:InitBench(1, nil, nil, 64)

        caster:Set3DBench(false)
        caster:SetBenchHidden(true)
        caster:SetFlexibleApproach(10)

        caster.items = {}

        caster:SetCustomInteract(function ( bench, user, item )
        	local item_name = item:GetContainedItem():GetName()

            local new_pos = Vector(item:GetAbsOrigin().x, bench:GetAbsOrigin().y, bench:GetAbsOrigin().z + 100)
            Frostivus:DropItem( user, item )
            item:FollowEntity(nil,false)

            item:SetAbsOrigin(new_pos)

            local id = #caster.items + 1
            caster.items[id] = item

            Timers:CreateTimer(function (  )
                new_pos = new_pos + (bench:GetForwardVector() * 3)
                item:SetAbsOrigin(new_pos)
                
                if math.abs(new_pos.x - bench:GetAbsOrigin().x) > 640 then
                    caster.items[id] = nil
                    item:RemoveSelf()
                    return nil
                else
                    return 0.03
                end
            end)
        end)
    end)
end

function frostivus_conveyor:GetIntrinsicModifierName()
    return "modifier_conveyor"
end

modifier_conveyor = class({})
LinkLuaModifier("modifier_conveyor", "frostivus/abilities/frostivus_conveyor.lua", 0)