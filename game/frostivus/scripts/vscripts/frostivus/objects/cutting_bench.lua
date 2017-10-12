function InitBench( keys )
	local caster = keys.caster
	local ability = keys.ability

	ExecOnGameInProgress(function (  )
		caster:InitBench(1, CheckItem)
		caster:Set3DBench(true)
		caster:SetBenchHidden(true)
		caster:SetOnPickedFromBench(function ( item )
			caster:SetBenchHidden(true)
		end)
		
		caster:SetRefineTarget(function ( bench, items )
			local original_item = items[1]
			local target_item = Frostivus.ItemsKVs[original_item].RefineTarget

			return target_item
		end)
		caster:SetRefineDuration(4)
		caster:SetDefaultRefineRoutine()
	end)
end

function CheckItem( bench, item )
	return Frostivus.ItemsKVs[item:GetContainedItem():GetName()].CanBeCutted
end