function deepcompare(t1,t2,ignore_mt)
	local ty1 = type(t1)
	local ty2 = type(t2)
	if ty1 ~= ty2 then return false end
	-- non-table types can be directly compared
	if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1)
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end
	for k1,v1 in pairs(t1) do
		local v2 = t2[k1]
		if v2 == nil or not deepcompare(v1,v2) then return false end
	end
	for k2,v2 in pairs(t2) do
		local v1 = t1[k2]
		if v1 == nil or not deepcompare(v1,v2) then return false end
	end
	return true
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
				local result

				for k,v in pairs(Frostivus.RecipesKVs["1"]) do
					if CheckRecipe(items, v.Assembly) then
						result = k
						break
					end
				end

				if result then
					local dish = CreateItemOnPositionSync(plate:GetAbsOrigin(),CreateItem(result,nil,nil))

					bench._holder:RemoveModifierByName("modifier_carrying_item")
					bench._holder:PickItemFromBench(user, plate):RemoveSelf()

					bench._holder:AddItemToBench(result, user)
					bench._holder:BindItem(dish)
				end
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

	for k,v in pairs(Frostivus.RecipesKVs["1"]) do
		for k1,v1 in pairs(v.Assembly) do

			if v1 == item_name then
				return true
			end
		end
	end

	return false
end