function BenchAPI( keys )
	local caster = keys.caster or keys

	caster.InitBench = (function( self, layout, check_item_callback, on_full_callback, height, no_wp )
		if not caster.wp then
			caster.wp = WorldPanels:CreateWorldPanelForAll({
				layout = "file://{resources}/layout/custom_game/worldpanels/bench.xml",
				data = {layout = layout, items = {}},
				entity = caster,
				entityHeight = height or 64,
				noWP = no_wp
			})

			caster:SetCheckItem( check_item_callback )
			caster:SetOnBenchIsFull( on_full_callback )
			caster:SetOnUse( OnUse )
			caster:SetBenchLayout(layout)
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

	caster.IsForwardOnUseToItem = (function( self )
		local old_data = self.wp:GetData()

		return old_data.items[1] and Frostivus.ItemsKVs[old_data.items[1]].ForwardOnUse
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
		self._initial_layout = l

		local old_data = self.wp:GetData()
		old_data.layout = l
		self.wp:SetData(old_data)
	end)

	caster.SetBenchInfiniteItems = (function( self, b )
		self._bench_infinite_items = b
	end)

	caster.IsBenchInfiniteItems = (function( self )
		return self._bench_infinite_items
	end)

	caster.PickItemFromBench = (function( self, user, item )
		if type(item) == 'string' then
			item = CreateItemOnPositionSync(user:GetAbsOrigin(),CreateItem(item,nil,nil))
		end

		GameRules.FrostivusEventListener:Trigger("frostivus_player_pickup", {
			Unit = user,
			ItemName = item:GetContainedItem():GetAbilityName()
		})

		-- item:StopAnimation()
		
		if not self._bench_infinite_items then
			self:SetItems()
		end

		self:OnPickedFromBench(item)
		
		return item
	end)

	caster.AddItemToBench = (function( self, item, user )
		local old_data = self.wp:GetData()

		if type(item) ~= 'string' then
			item = item:GetContainedItem():GetName()
		end

		self:OnItemAddedToBench(item)
		
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

	caster.SetOnItemAddedToBench = (function( self, callback )
		caster._on_item_added_to_bench = callback
	end)

	caster.OnItemAddedToBench = (function( self, item )
		caster._on_item_added_to_bench = caster._on_item_added_to_bench or (function( ) Frostivus:L("Triggered!") end)
		caster._on_item_added_to_bench(self, item)
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

	caster.ContainsPlateStack = (function( self )
		local old_data = self.wp:GetData()

		return old_data.items[1] and old_data.items[1] == "item_clean_plates"
	end)

	caster.ContainsPlate = (function( self )
		local old_data = self.wp:GetData()

		return old_data.items[1] and old_data.items[1] == "item_plate"
	end)

	caster.SetItems = (function( self, items )
		local old_data = self.wp:GetData()

		old_data.items = items or {}

		self.wp:SetData(old_data)
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
		end
	end)

	caster.SetRefineSound = (function( self, t )
		if type(t) == 'function' then
			caster._get_refine_sound = t
		else
			caster._get_refine_sound = (function ()
				return t
			end)
		end
	end)

	caster.GetRefineSound = (function( self )
		if caster._get_refine_sound then
			return caster._get_refine_sound(caster)
		end
	end)

	caster.IsRefining = (function( self )
		local old_data = self.wp:GetData()

		return old_data.passed or old_data.paused or (self.HasModifier and self:HasModifier("modifier_unselectable"))
	end)

	caster.SetDefaultRefineRoutine = (function ( self )
		caster:SetOnBenchIsFull( RefineBase )
	end)

	caster.SetOnCompleteRefine = (function( self, callback )
		caster._on_complete_refine = callback
	end)

	caster.OnCompleteRefine = (function( self )
		if caster._on_complete_refine then
			return caster._on_complete_refine(self)
		else
			Frostivus:L("Refine Complete!")
		end

	end)

	caster.SetOnStartRefine = (function( self, callback )
		caster._on_start_refine = callback
	end)

	caster.OnStartRefine = (function( self, target_item )
		if caster._on_start_refine then
			caster._on_start_refine(self, target_item)
		else
			Frostivus:L("Refine Started!")
		end
	end)

	caster.SetCustomInteract = (function( self, callback )
		caster._custom_interact = callback
	end)

	caster.CustomInteract = (function( self, user, item )
		if caster._custom_interact then
			caster._custom_interact(self, user, item)
		end
	end)

	caster.BindItem = (function( self, item )
		if type(item) == 'string' then
			item = CreateItemOnPositionSync(self:GetAbsOrigin(),CreateItem(item,self,self))
		end

		Frostivus:BindItem(item, self, (function ()
			return self:GetAbsOrigin() + Vector(0,0,84)
		end),(function ()
			return Frostivus:IsCarryingItem( self, item )
		end), (function ()
			-- Frostivus:DropItem( self, item )
		end), true, false)
	end)

	caster.ClearBench = (function ( self )
		local item = Frostivus:GetCarryingItem(self)
		if IsValidEntity(item) then
			item:RemoveSelf()
		end
		self:RemoveModifierByName("modifier_carrying_item")
		self:SetItems({})
	end)

    caster.GetBenchItemBySlot = (function ( self, slot )
    	if self.wp then
        	return self.wp:GetData().items[slot]
        end
    end)

    caster.IsHotBench = (function ( self )
    	return caster.GetModelName and caster:GetModelName() == "models/lava_bench/lava_bench.vmdl"
    end)

    caster.SetFakeItem = (function ( self, item )
		local old_data = self.wp:GetData()

		old_data.fake = item

		self.wp:SetData(old_data)
    end)
end

function OnUse( bench, user )
	if user then
		if not Frostivus:IsCarryingItem(user) and bench.wp:GetData().items[1] then
			-- Picking a plate from a plate stack
			if bench:ContainsPlateStack() then
				bench = Frostivus:GetCarryingItem(bench)
			end

			local item_name = bench:GetBenchItemBySlot(1)

			if (Frostivus.ItemsKVs[item_name].CanBePickedFromBench or bench:HasModifier("modifier_crate") or bench:HasModifier("modifier_transfer_bench")) and bench:GetBenchItemCount() == 1 and not bench:IsRefining() then
				-- Play user animation and sound
				StartAnimation(user, {duration=0.3, activity=ACT_DOTA_GREEVIL_CAST, rate=2, translate="greevil_miniboss_black_nightmare"})
				PlayPickupSound( item_name, user )

				-- Picking item from the bench
				local item = item_name
				if bench:Is3DBench() and Frostivus:IsCarryingItem( bench ) and not bench:IsBenchInfiniteItems() then
					item = Frostivus:DropItem( bench, Frostivus:GetCarryingItem( bench ) )
				end

				-- If bench is 3D then it will return binded container, otherwise it will create one
				item = bench:PickItemFromBench(user, item)

				user:BindItem( item )
			elseif bench:IsBenchFull() and bench:IsRefineBench() then
				-- Use full bench (e.g. after interrupting channel)
				bench:OnBenchIsFull(bench.wp:GetData().items, user)
			end
		elseif not bench:IsBenchFull() or Frostivus:GetCarryingItem(user).CheckItem or bench:IsForwardOnUseToItem() then
			if Frostivus:IsCarryingItem(user) then
				-- Adding item to the bench
				local item = Frostivus:GetCarryingItem(user)
				local item_name = item:GetContainedItem():GetName()

				-- Some benches have custom interact handler (trash bin)
				if bench._custom_interact then
					bench:CustomInteract(user, item)
					return
				end

				-- Play user animation and sound
				StartAnimation(user, {duration=0.3, activity=ACT_DOTA_GREEVIL_CAST, rate=2.5, translate="greevil_laguna_blade"})
				PlayDropSound( item, user )

				-- Swap plate with item
				if Frostivus:IsCarryingItem(bench) and item_name == "item_plate" then
					local bench_item = Frostivus:GetCarryingItem(bench)
					local bench_item_name = bench_item:GetContainedItem():GetName()

					local is_bank = bench_item_name == "item_pot" or bench_item_name == "item_frying_pan"

					if item:CheckItem(bench_item) then
						item:AddItemToBench(bench_item, user)
						bench:ClearBench()
					elseif is_bank then
						local bank = bench_item
						local old_data = bank.wp:GetData()

						if bank.progress:GetData().cooking_done then
							for k,v in pairs(old_data.items) do
								item:AddItemToBench(v, user)
							end

							bank:SetItems({})
							bank:SetFakeItem(nil)

							bank.progress:SetData({ progress = 0 })
						end
					end

					return
				end

				-- Adding item to a plate or some other container
				if bench:IsForwardOnUseToItem() then
					bench = Frostivus:GetCarryingItem( bench )
				end

				if item then
					if bench.CheckItem and bench:CheckItem(item) then
						bench:AddItemToBench(item, user)

						Frostivus:DropItem( user, item )

						if bench:Is3DBench() then
							bench:BindItem(item)
						else
							Timers:CreateTimer(function (  )
								item:RemoveSelf()
							end)
						end
					end
				end
			end
		end
	end
end

function RefineBase( bench, items, user )
	local original_item = items[1]
	local target_item = bench:GetRefineTarget()

	if not target_item then
		return
	end

	bench:OnStartRefine(target_item)

	local duration = bench:GetRefineDuration()

	local ab = user:FindAbilityByName("frostivus_pointer")

	local old_data = bench.wp:GetData()

	if old_data.paused then
		duration = duration * (1 - old_data.paused)
	end

	old_data.duration = duration
	old_data.layout = 1
	bench.wp:SetData(old_data)

	local soundName, dontRepeat = bench:GetRefineSound()

	user:AddNewModifier(user,ab,"modifier_bench_interaction",{
		duration = duration,
		cutting_bench = 1,
		sound = soundName,
		dont_repeat_sound = dontRepeat,
	}):SetStackCount(duration * 100)
	user:AddNewModifier(user,ab,"modifier_command_restricted",{duration = 0.03})
	bench:AddNewModifier(user,ab,"modifier_unselectable",{})

	local function ResetProgress()
		local old_data = bench.wp:GetData()
		old_data.duration = nil
		old_data.paused = nil
		bench.wp:SetData(old_data)

		ab._interrupted = nil
		ab._finished = nil

		user:RemoveModifierByName("modifier_bench_interaction")
		bench:RemoveModifierByName("modifier_unselectable")
	end

	ab._interrupted = (function ( time )
		ResetProgress()
		StopSoundOn('custom_sound.chopping',bench)
		local old_data = bench.wp:GetData()
		old_data.passed = (old_data.passed or 0.0) + time
		old_data.paused = old_data.passed / bench:GetRefineDuration()
		bench.wp:SetData(old_data)
	end)

	ab._finished = (function ()
		ResetProgress()
		StopSoundOn('custom_sound.chopping',bench)

		local custom_refine = bench:OnCompleteRefine()

		local old_data = bench.wp:GetData()
		old_data.layout = bench._initial_layout
		old_data.items[1] = target_item
		old_data.passed = nil
		old_data.paused = nil
		bench.wp:SetData(old_data)

		if custom_refine then
			local old_data = bench.wp:GetData()
			old_data.items[1] = custom_refine:GetContainedItem():GetName()
			bench.wp:SetData(old_data)
		else
			if bench:Is3DBench() and bench:FindModifierByName("modifier_carrying_item") then
				local item = bench:FindModifierByName("modifier_carrying_item").item

				Frostivus:DropItem( bench, item )

				item:RemoveSelf()

				bench:BindItem(target_item)
			end
		end

		GameRules.FrostivusEventListener:Trigger("frostivus_complete_refine", {
			Unit = user
		})

	end)

	ab.bench = bench
	user:CastAbilityNoTarget(ab, user:GetPlayerOwnerID())

	bench:SetBenchHidden(false)
end