frostivus_transfer_bench = class({})

function frostivus_transfer_bench:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
		caster:InitBench(1, nil, nil, 0, true)
		caster:Set3DBench(true)
		caster:SetBenchHidden(true)
    end)
end

function frostivus_transfer_bench:GetIntrinsicModifierName()
    return "modifier_transfer_bench"
end

modifier_transfer_bench = class({})
LinkLuaModifier("modifier_transfer_bench", "frostivus/abilities/frostivus_transfer_bench.lua", 0)