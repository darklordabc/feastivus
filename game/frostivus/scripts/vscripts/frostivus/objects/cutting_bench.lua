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

function CheckItem( bench, item )
	return true -- Frostivus.ItemsKVs[item:GetContainedItem():GetName()].CanBeCutted
end