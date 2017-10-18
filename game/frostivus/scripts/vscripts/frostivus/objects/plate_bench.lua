function InitBench( keys )
	local caster = keys.caster
	local ability = keys.ability

	ExecOnGameInProgress(function (  )
		caster:InitBench(1, nil, nil, 0)
		caster:Set3DBench(true)
        caster:SetBenchInfiniteItems(true)
        caster:SetBenchHidden(true)

        caster:AddItemToBench("item_plate")

		-- local item = CreateItemOnPositionSync(caster:GetAbsOrigin(), CreateItem("item_plate", caster, caster))

		-- Frostivus:BindItem(item, caster, (function ()
		-- 	return caster:GetAbsOrigin() + Vector(0,0,128)
		-- end),(function ()
		-- 	return Frostivus:IsCarryingItem( caster, item )
		-- end), (function ()
		-- 	Frostivus:DropItem( caster, item )
		-- end), true, false)

		caster.PickItemFromBench = (function( self, user, item_name )
			local plate = CreateItemOnPositionSync(user:GetAbsOrigin(),CreateItem(item_name,nil,nil))

			BenchAPI(plate)
			plate:InitBench( 3, CheckItem )
			plate:SetOnPickedFromBench(function ( picked_item )
				
			end)
			plate:SetOnBenchIsFull( function ( bench, items, user )
				local dish = CreateItemOnPositionSync(plate:GetAbsOrigin(),CreateItem(bench.current_item,nil,nil))

				bench._holder:RemoveModifierByName("modifier_carrying_item")
				bench._holder:PickItemFromBench(user, plate):RemoveSelf()

				bench._holder:AddItemToBench(bench.current_item, user)
				bench._holder:BindItem(dish)
			end )
			
			if not self._bench_infinite_items then
				local old_data = self.wp:GetData()
				old_data.items = {}
				self.wp:SetData(old_data)

				self:OnPickedFromBench(plate)
			end

			return plate
		end)
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