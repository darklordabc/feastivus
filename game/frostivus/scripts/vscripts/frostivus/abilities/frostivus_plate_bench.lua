frostivus_plate_bench = class({})

function frostivus_plate_bench:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
		caster:InitBench(3, (function( bench, item )
            local item_name = item:GetContainedItem():GetName()
            return item_name == "item_clean_plates" or item_name == "item_plate"
        end), nil, 0)
		caster:Set3DBench(true)
        caster:SetBenchHidden(true)

        local count = 3
        if caster:GetName() == "tutorial_plate" then count = 1 end

        if count > 1 then
        	caster:AddItemToBench("item_clean_plates")
        end

        AddPlateStack(caster, count )

        -- caster.AddItemToBench = (function( self, item, user )
        --     local old_data = self.wp:GetData()

        --     if type(item) ~= 'string' then
        --         count = item:GetContainedItem()._counter
        --         item = item:GetContainedItem():GetName()

        --         AddPlateStack(caster, count or 1)

        --         return
        --     end

        --     self:OnItemAddedToBench(item)
            
        --     if GetTableLength(old_data.items) < old_data.layout then
        --         table.insert(old_data.items, item)
        --         self.wp:SetData(old_data)

        --         if GetTableLength(old_data.items) == old_data.layout then
        --             self:OnBenchIsFull(old_data.items, user)
        --         end
        --     end
        -- end)
    end)
end

function frostivus_plate_bench:GetIntrinsicModifierName()
    return "modifier_plate_bench"
end

modifier_plate_bench = class({})
LinkLuaModifier("modifier_plate_bench", "frostivus/abilities/frostivus_plate_bench.lua", 0)