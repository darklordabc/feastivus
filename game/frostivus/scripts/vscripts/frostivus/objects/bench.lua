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

	caster.SetBenchLayout = (function( self, l )
		local old_data = self.wp:GetData()
		old_data.layout = l
		self.wp:SetData(old_data)
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
		if caster._on_bench_is_full then
			caster._on_bench_is_full(self, items, user)
		else
			Frostivus:L("Triggered!")
		end
	end)

	caster.IsRefineBench = (function( self)
		return caster._on_bench_is_full ~= nil
	end)

	caster.SetCheckItem = (function( self, callback )
		caster._check_item = callback
	end)

	caster.CheckItem = (function( self, item )
		if not caster._check_item then return true end
		return caster._check_item(self, item)
	end)

	caster.GetBenchItemCount = (function( self )
		return GetTableLength(caster.wp:GetData().items)
	end)

	caster.SetRefineDuration = (function( self, d )
		self._refine_duration = d
	end)

	caster.GetRefineDuration = (function( self )
		return self._refine_duration or 3.5
	end)

	caster.SetRefineTarget = (function( self, t )
		if type(t) == 'function' then
			caster._get_refine_target = t
		else
			caster._get_refine_target = (function ()
				return t
			end)
		end
	end)

	caster.GetRefineTarget = (function( self )
		if caster._get_refine_target then
			return caster._get_refine_target(caster, caster.wp:GetData().items)
		else

		end
	end)

	caster.SetDefaultRefineRoutine = (function ( self )
		caster:SetOnBenchIsFull( RefineBase )
	end)

	caster.SetOnCompleteRefine = (function( self, callback )
		caster._on_complete_refine = callback
	end)

	caster.OnCompleteRefine = (function( self )
		if caster._on_complete_refine then
			caster._on_complete_refine(self)
		else
			Frostivus:L("Refine Complete!")
		end
	end)
end

function OnUse( bench, user )
	if user then
		if not user:FindModifierByName("modifier_carrying_item") and bench.wp:GetData().items[1] then
			local item_name = bench.wp:GetData().items[1]

			if (Frostivus.ItemsKVs[item_name].CanBePickedFromBench or bench:HasModifier("modifier_crate") or bench:HasModifier("modifier_transfer_bench")) and bench:GetBenchItemCount() == 1 then
				-- Picking item from the bench
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
			elseif bench:IsBenchFull() and bench:IsRefineBench() then
				-- Use full bench (e.g. after interrupting channel)
				bench:OnBenchIsFull(bench.wp:GetData().items, user)
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

function RefineBase( bench, items, user )
	local original_item = items[1]
	local target_item = bench:GetRefineTarget()

	local duration = bench:GetRefineDuration()

	local ab = user:FindAbilityByName("frostivus_pointer")
	
	user:AddNewModifier(user,ab,"modifier_bench_interaction",{duration = duration}):SetStackCount(duration * 100)

	local old_data = bench.wp:GetData()

	local temp_layout = old_data.layout

	old_data.duration = duration
	old_data.layout = 1
	bench.wp:SetData(old_data)

	local function ResetProgress()
		local old_data = bench.wp:GetData()
		old_data.duration = nil
		bench.wp:SetData(old_data)

		ab._interrupted = nil
		ab._finished = nil
		user:RemoveModifierByName("modifier_bench_interaction")
	end

	ab._interrupted = (function ()
		ResetProgress()
	end)

	ab._finished = (function ()
		ResetProgress()

		bench:OnCompleteRefine()

		local old_data = bench.wp:GetData()
		old_data.items[1] = target_item
		old_data.layout = temp_layout
		bench.wp:SetData(old_data)
	end)

	user:CastAbilityNoTarget(ab, user:GetPlayerOwnerID())

	bench:SetBenchHidden(false)
end