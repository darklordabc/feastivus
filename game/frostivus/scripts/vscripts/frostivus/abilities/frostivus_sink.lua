frostivus_sink = class({})

function frostivus_sink:OnUpgrade()
	local caster = self:GetCaster()

    caster.PrepareForRound = (function (  )
        local plate_bench
        local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 128, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE , FIND_ANY_ORDER, false)

        for _,v in pairs(units) do
            if v:GetUnitName() == "npc_plate_bench" then
                plate_bench = v
                break
            end
        end

        caster:InitBench(1, (function( bench, item )
            return item:GetContainedItem():GetName() == "item_dirty_plates"
        end))
        caster:Set3DBench(true)
        caster:SetBenchHidden(true)
        caster:SetOnPickedFromBench(function ( item )
            caster:SetBenchHidden(true)
        end)
        caster:SetOnCompleteRefine(function ( self, user )
            local item = Frostivus:GetCarryingItem(plate_bench)
            if item then
                local item_name = item:GetContainedItem():GetName()
                local is_plate = item_name == "item_plate" and GetTableLength(item:GetItems()) > 0
                if is_plate or (item_name ~= "item_plate" and item_name ~= "item_clean_plates") then
                    Frostivus:DropItem( plate_bench, item )
                    plate_bench:ClearBench()
                    Timers:CreateTimer(function (  )
                        user:BindItem( item )
                    end)
                end
            end
            caster:SetBenchHidden(true)
            caster:ClearBench()
            local stack = AddPlateStack(plate_bench, caster._temp_counter)
            ParticleManager:CreateParticle("particles/frostivus_gameplay/clean_plates.vpcf",PATTACH_ABSORIGIN,stack)
            EmitSoundOn("custom_sound.washing_plate_done", stack)
            return stack
        end)
        
        caster:SetRefineTarget("item_clean_plates")
        caster:SetRefineDuration(4.0)
        caster:SetRefineSound(function ()
            return "custom_sound.washing_plate", true
        end)
        caster:SetDefaultRefineRoutine()

        caster.AddItemToBench = (function( self, item, user )
            local old_data = self.wp:GetData()

            if type(item) ~= 'string' then
                if item:GetContainedItem()._counter then
                    caster._temp_counter = item:GetContainedItem()._counter
                end

                item = item:GetContainedItem():GetName()
            end
            
            if GetTableLength(old_data.items) < old_data.layout then
                table.insert(old_data.items, item)
                self.wp:SetData(old_data)

                if GetTableLength(old_data.items) == old_data.layout and old_data.items[1] == "item_dirty_plates" then
                    self:OnBenchIsFull(old_data.items, user)
                end
            end
        end)

        caster.ResetBench = (function ( self )
            local old_data = self.wp:GetData()
            old_data.layout = 1
            old_data.passed = nil
            old_data.paused = nil
            old_data.duration = nil
            self.wp:SetData(old_data)
            self:SetBenchHidden(true)
        end)
    end)
end

function frostivus_sink:GetIntrinsicModifierName()
    return "modifier_sink"
end

modifier_sink = class({})
LinkLuaModifier("modifier_sink", "frostivus/abilities/frostivus_sink.lua", 0)