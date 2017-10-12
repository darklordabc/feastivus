function InitBench( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster.InitBench = (function( self, layout, check_item_callback, on_full_callback, height )
		if not caster.wp then
			caster.wp = WorldPanels:CreateWorldPanelForAll({
				layout = "file://{resources}/layout/custom_game/worldpanels/bench.xml",
				data = {layout = layout, items = {}},
				entity = caster,
				entityHeight = height or 64,
			})
			caster:SetCheckItem( check_item_callback )
			caster:SetOnBenchIsFull( on_full_callback )
			caster:SetOnUse( OnUse )

			-- local pos = caster:GetAbsOrigin()

			-- caster._blocker = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = pos, block_fow = false})
			
			-- Timers:CreateTimer(function (  )
			-- 	caster:SetAbsOrigin(pos)
			-- 	return 0.03
			-- end)
		end
	end)

	caster.SetBenchHidden = (function( self, b )
		self._bench_hidden = b

		local old_data = self.wp:GetData()
		old_data.hidden = self._bench_hidden
		self.wp:SetData(old_data)
	end)

	caster.IsBenchBench = (function( self )
		return self._bench_hidden
	end)

	caster.Set3DBench = (function( self, b )
		self._3d_bench = b
	end)

	caster.Is3DBench = (function( self )
		return self._3d_bench and GetTableLength(self.wp:GetData().items) == 1
	end)

	caster.IsBenchFull = (function( self )
		local old_data = self.wp:GetData()

		return GetTableLength(old_data.items) == old_data.layout
	end)

	caster.SetBenchInfiniteItems = (function( self, b )
		self._bench_infinite_items = b
	end)

	caster.PickItemFromBench = (function( self, user, item_name )
		local item = CreateItemOnPositionSync(user:GetAbsOrigin(),CreateItem(item_name,nil,nil))
		-- item:StopAnimation()
		
		if not self._bench_infinite_items then
			local old_data = self.wp:GetData()
			old_data.items = {}
			self.wp:SetData(old_data)

			self:OnPickedFromBench(item_name)
		end

		return item
	end)

	caster.AddItemToBench = (function( self, item, user )
		local old_data = self.wp:GetData()
		
		if GetTableLength(old_data.items) < old_data.layout then
			table.insert(old_data.items, item)
			self.wp:SetData(old_data)

			if GetTableLength(old_data.items) == old_data.layout then
				self:OnBenchIsFull(old_data.items, user)
			end
		end
	end)

	caster.SetOnPickedFromBench = (function( self, callback )
		caster._on_picked_from_bench = callback
	end)

	caster.OnPickedFromBench = (function( self, item )
		caster._on_picked_from_bench = caster._on_picked_from_bench or (function( ) Frostivus:L("Triggered!") end)
		caster._on_picked_from_bench(self, item)
	end)

	caster.SetOnBenchIsFull = (function( self, callback )
		caster._on_bench_is_full = callback
	end)

	caster.OnBenchIsFull = (function( self, items, user )
		caster._on_bench_is_full = caster._on_bench_is_full or (function( ) Frostivus:L("Triggered!") end)
		caster._on_bench_is_full(self, items, user)
	end)

	caster.SetCheckItem = (function( self, callback )
		caster._check_item = callback
	end)

	caster.CheckItem = (function( self, item )
		if not caster._check_item then return true end
		return caster._check_item(self, item)
	end)
end

function OnUse( bench, user )
	if user then
		if not user:FindModifierByName("modifier_carrying_item") and bench.wp:GetData().items[1] then
			-- Picking item from the bench
			local item_name = bench.wp:GetData().items[1]

			if (Frostivus.ItemsKVs[item_name].CanBePickedFromBench or bench:HasModifier("modifier_crate") or bench:HasModifier("modifier_transfer_bench")) and GetTableLength(bench.wp:GetData().items) == 1 then
				if bench:Is3DBench() and Frostivus:IsCarryingItem( bench ) then
					local item = Frostivus:DropItem( bench, Frostivus:GetCarryingItem( bench ) )
					if item then
						item:RemoveSelf()
					end
				end

				local item = bench:PickItemFromBench(user, item_name)

				Frostivus:BindItem(item, user, (function ()
					return user:GetAbsOrigin() + Vector(0,0,128) + user:GetForwardVector() * 32
				end),(function ()
					return Frostivus:IsCarryingItem( user, item )
				end), nil, true, false)
			end
		elseif not bench:IsBenchFull() or bench:HasModifier("modifier_bin") then
			-- Adding item to the bench
			if user:FindModifierByName("modifier_carrying_item") then
				local item = user:FindModifierByName("modifier_carrying_item").item

				if item and bench:CheckItem(item) then
					bench:AddItemToBench(item:GetContainedItem():GetName(), user)

					Frostivus:DropItem( user, item )

					if bench:Is3DBench() then
						Frostivus:BindItem(item, bench, (function ()
							return bench:GetAbsOrigin() + Vector(0,0,128)
						end),(function ()
							return Frostivus:IsCarryingItem( bench, item )
						end), (function ()
							Frostivus:DropItem( bench, item )
						end), true, false)
					else
						item:RemoveSelf()
					end
				end
			end
		end
	end
end