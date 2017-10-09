function InitBench( keys )
	local caster = keys.caster
	local ability = keys.ability

	ExecOnGameInProgress(function (  )
		caster:InitBench(1, CheckItem, StartCutting)
		caster:Set3DBench(true)
		caster:SetBenchHidden(true)
		caster:SetOnPickedFromBench(function ( item )
			caster:SetBenchHidden(true)
		end)
	end)
end

function CheckItem( bench, item )
	return Frostivus.ItemsKVs[item:GetContainedItem():GetName()].CanBeCutted
end

function StartCutting( bench, items, user )
	local original_item = items[1]
	local target_item = Frostivus.ItemsKVs[original_item].RefineTarget

	local duration = 3.5

	user:AddNewModifier(user,user:FindAbilityByName("frostivus_pointer"),"modifier_bench_interaction",{duration = duration})

	bench:SetBenchHidden(false)

	local old_data = bench.wp:GetData()
	old_data.duration = duration
	bench.wp:SetData(old_data)

	Timers:CreateTimer(duration, function (  )
		local old_data = bench.wp:GetData()
		old_data.items[1] = target_item
		old_data.duration = nil
		bench.wp:SetData(old_data)
	end)
end