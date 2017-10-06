function InitBench( keys )
	local caster = keys.caster
	local ability = keys.ability

	ExecOnGameInProgress(function (  )
		caster:InitBench(3, CheckItem, StartAssembling)
	end)
end

function CheckItem( item )
	return Frostivus.ItemsKVs[item:GetContainedItem():GetName()].CanBeCutted
end

function StartAssembling( bench, items )
	local original_item = items[1]
	local target_item = Frostivus.ItemsKVs[original_item].RefineTarget

	local old_data = bench.wp:GetData()
	old_data.duration = 3.5
	bench.wp:SetData(old_data)

	Timers:CreateTimer(3.5, function (  )
		local old_data = bench.wp:GetData()
		old_data.items[1] = target_item
		old_data.duration = nil
		bench.wp:SetData(old_data)
	end)
end