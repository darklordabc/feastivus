function InitBench( keys )
	local caster = keys.caster
	local ability = keys.ability

	ExecOnGameInProgress(function (  )
		caster:InitBench(3, CheckItem, StartAssembling)
		
		caster:SetRefineTarget(function ( bench, items )
			return bench.current_item
		end)
		caster:SetOnCompleteRefine(function ( bench )
			local old_data = bench.wp:GetData()
			old_data.items = {}
			bench.wp:SetData(old_data)

			bench.current_item = nil
		end)
		caster:SetRefineDuration(3)
		caster:SetDefaultRefineRoutine()
	end)
end

function CheckItem( bench, item )
	local item_name = item:GetContainedItem():GetName()
	local allow = false

	if not bench.current_item then
		for k,v in pairs(g_GetCurrentOrders()) do
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