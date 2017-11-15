frostivus_stone_bench = class({})

function frostivus_stone_bench:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
		caster:InitBench(1, nil, nil, 0, true)
		caster:Set3DBench(true)
		caster:SetBenchHidden(true)
    end)
end

function frostivus_stone_bench:GetIntrinsicModifierName()
    return "modifier_stone_bench"
end

modifier_stone_bench = class({})
LinkLuaModifier("modifier_stone_bench", "frostivus/abilities/frostivus_stone_bench.lua", 0)