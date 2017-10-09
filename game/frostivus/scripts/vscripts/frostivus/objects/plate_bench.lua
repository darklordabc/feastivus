function InitBench( keys )
	local caster = keys.caster
	local ability = keys.ability

	ExecOnGameInProgress(function (  )
		caster:InitBench(3, CheckItem, StartAssembling)
	end)
end

function CheckItem( bench, item )
	local item_name = item:GetContainedItem():GetName()
	local allow = false

	if not bench.current_item then
		for k,v in pairs(g_GetCurrentOrders) do
			if allow then
				break
			end
			for k1,v1 in pairs(Frostivus.RecipesKVs["1"][v.pszItemName].Assembly) do

				if v1 == item_name then
					allow = true
					bench.current_item = v.pszItemName
					break
				end
			end
		end
	else
		-- TO DO: recipe checking
		for k1,v1 in pairs(Frostivus.RecipesKVs["1"][bench.current_item].Assembly) do
			if v1 == item_name then
				allow = true
				break
			end
		end
	end

	return allow
end

function StartAssembling( bench, items )
	local original_item = items[1]
	local target_item = bench.current_item

	local old_data = bench.wp:GetData()
	old_data.duration = 3.5
	bench.wp:SetData(old_data)

	Timers:CreateTimer(3.5, function (  )
		local old_data = bench.wp:GetData()
		old_data.items = {}
		old_data.items[1] = target_item
		old_data.duration = nil
		bench.wp:SetData(old_data)

		bench.current_item = nil
	end)
end