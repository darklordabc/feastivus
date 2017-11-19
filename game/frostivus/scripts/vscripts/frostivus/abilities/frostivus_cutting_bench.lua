frostivus_cutting_bench = class({})

function frostivus_cutting_bench:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
		caster:InitBench(1)
		caster:Set3DBench(true)
		caster:SetBenchHidden(true)
		caster:SetOnPickedFromBench(function ( item )
			caster:SetBenchHidden(true)
		end)
		caster:SetOnCompleteRefine(function ( item )
			caster:SetBenchHidden(true)
		end)
		
		caster:SetRefineTarget(function ( bench, items )
			local original_item = items[1]

			if Frostivus.ItemsKVs[original_item].CanBeCutted then
				local target_item = Frostivus.ItemsKVs[original_item].RefineTarget
				return target_item
			end
		end)
		caster:SetRefineSound(function ()
			if RollPercentage(20) then
				return "custom_sound.chop_special", true
			end
			return "custom_sound.chop", false
		end)
		caster:SetRefineDuration(2.2)
		caster:SetDefaultRefineRoutine()
    end)
end

function frostivus_cutting_bench:GetIntrinsicModifierName()
    return "modifier_cutting_bench"
end

modifier_cutting_bench = class({})
LinkLuaModifier("modifier_cutting_bench", "frostivus/abilities/frostivus_cutting_bench.lua", 0)