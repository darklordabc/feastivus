function AddPlateStack(caster, quantity)
	quantity = quantity or 3

	caster:AddItemToBench("item_clean_plates")

	local stack = CreateItemOnPositionSync(caster:GetAbsOrigin(), CreateItem("item_clean_plates", caster, caster))
	stack:SetModel("models/plates/dirty_plate_"..tostring(quantity)..".vmdl")

	caster:BindItem(stack)

	BenchAPI(stack)
	stack:InitBench(1, (function()
		return false
	end), nil, nil, true)
	stack:SetBenchHidden(true)
	stack:AddItemToBench("item_plate")
	stack:SetBenchInfiniteItems(true)

	stack._count = quantity

	stack.PickItemFromBench = (function( self, user, item_name )
		stack._count = stack._count - 1

		local plate = CreatePlate()

		if stack._count == 1 then
			local bench = stack._holder

			Frostivus:DropItem( bench, stack )
			bench:PickItemFromBench(bench, stack):RemoveSelf()

			-- Replacing stack with last plate
			local last_plate = CreatePlate()

			bench:AddItemToBench(last_plate, user)
			bench:BindItem(last_plate)
		else
			stack:SetModel("models/plates/dirty_plate_"..tostring(stack._count)..".vmdl")
		end

		if not self._bench_infinite_items then
			local old_data = self.wp:GetData()
			old_data.items = {}
			self.wp:SetData(old_data)

			self:OnPickedFromBench(plate)
		end
		
		return plate
	end)

	return stack
end

function CreatePlate(  )
	local plate = CreateItemOnPositionSync(Vector(0,0,0),CreateItem("item_plate",nil,nil))

	BenchAPI(plate)
	plate:InitBench( 3, CanPutItemOnPlate, nil, 0 )
	plate:SetOnPickedFromBench(function ( picked_item )
		
	end)
	plate:SetOnBenchIsFull( function ( bench, items, user )
		local result

		for k,v in pairs(Frostivus.RecipesKVs["1"]) do
			if CheckRecipe(items, v.Assembly) then
				result = k
				break
			end
		end

		if result then
			local dish = CreateItemOnPositionSync(bench:GetAbsOrigin(),CreateItem(result,nil,nil))

			bench._holder:RemoveModifierByName("modifier_carrying_item")
			bench._holder:PickItemFromBench(user, bench):RemoveSelf()

			bench._holder:AddItemToBench(result, user)
			bench._holder:BindItem(dish)
		end
	end )

	return plate
end

function CheckRecipe(items, recipe)
	local function IDArray( a )
		local new = {}
		for k,v in pairs(a) do
			table.insert(new, Frostivus.ItemsKVs[v].ID)
		end
		table.sort(new)
		return new
	end

	local v1 = IDArray( items )
	local v2 = IDArray( recipe )

	return deepcompare(v1,v2,true)
end

function CanPutItemOnPlate( bench, item )
	local item_name = item:GetContainedItem():GetName()

	for k,v in pairs(Frostivus.RecipesKVs["1"]) do
		for k1,v1 in pairs(v.Assembly) do

			if v1 == item_name then
				return true
			end
		end
	end

	return false
end