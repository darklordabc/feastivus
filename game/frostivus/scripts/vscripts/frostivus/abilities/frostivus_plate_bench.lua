frostivus_plate_bench = class({})

function frostivus_plate_bench:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
		caster:InitBench(1, nil, nil, 0)
		caster:Set3DBench(true)
        caster:SetBenchHidden(true)

        local count = 3
        if caster:GetName() == "tutorial_plate" then count = 1 end

        if count > 1 then
        	caster:AddItemToBench("item_clean_plates")
        end

        AddPlateStack(caster, count )
    end)
end

function frostivus_plate_bench:GetIntrinsicModifierName()
    return "modifier_plate_bench"
end

modifier_plate_bench = class({})
LinkLuaModifier("modifier_plate_bench", "frostivus/abilities/frostivus_plate_bench.lua", 0)