frostivus_sink = class({})

function frostivus_sink:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
        caster:InitBench(1, (function( bench, item )
            return item:GetContainedItem():GetName() == "item_dirty_plates"
        end))
        caster:Set3DBench(true)
        caster:SetBenchHidden(true)
        caster:SetOnPickedFromBench(function ( item )
            caster:SetBenchHidden(true)
        end)
        caster:SetOnCompleteRefine(function (  )
            caster:SetBenchHidden(true)
            caster:ClearBench()
            return AddPlateStack(caster, caster._temp_counter)
        end)
        
        caster:SetRefineTarget("item_clean_plates")
        caster:SetRefineDuration(4.0)
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
    end)
end

function frostivus_sink:GetIntrinsicModifierName()
    return "modifier_sink"
end

modifier_sink = class({})
LinkLuaModifier("modifier_sink", "frostivus/abilities/frostivus_sink.lua", 0)