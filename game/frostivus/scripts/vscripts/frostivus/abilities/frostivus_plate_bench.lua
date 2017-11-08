frostivus_plate_bench = class({})

function frostivus_plate_bench:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
		caster:InitBench(1, nil, nil, 0)
		caster:Set3DBench(true)
        caster:SetBenchHidden(true)

        caster:AddItemToBench("item_clean_plates")

        AddPlateStack(caster, 3 )
    end)
end

function frostivus_plate_bench:GetIntrinsicModifierName()
    return "modifier_plate_bench"
end

modifier_plate_bench = class({})
LinkLuaModifier("modifier_plate_bench", "frostivus/abilities/frostivus_plate_bench.lua", 0)