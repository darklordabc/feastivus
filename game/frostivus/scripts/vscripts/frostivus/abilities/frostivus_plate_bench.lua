frostivus_plate_bench = class({})

function frostivus_plate_bench:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
		caster:InitBench(1, (function( bench, item )
            local item_name = item:GetContainedItem():GetName()
            return item_name == "item_clean_plates" or item_name == "item_plate"
        end), nil, 0)
		caster:Set3DBench(true)
        caster:SetBenchHidden(true)

        caster.ResetBench = (function ( self )
            self:ClearBench()

            local count = 3
            if string.match(self:GetName(), "npc_plate_bench") then count = 1 end

            if count > 1 then
                self:AddItemToBench("item_clean_plates")
            end

            AddPlateStack(self, count )
        end)

        caster:ResetBench()
    end)
end

function frostivus_plate_bench:GetIntrinsicModifierName()
    return "modifier_plate_bench"
end

modifier_plate_bench = class({})
LinkLuaModifier("modifier_plate_bench", "frostivus/abilities/frostivus_plate_bench.lua", 0)