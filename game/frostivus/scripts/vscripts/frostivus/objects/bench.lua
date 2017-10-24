local custom_item_pickup_sounds = {
	-- add item name here
	-- add custom pickup sound in custom_sounds.vsndevts as
	-- custom_sound.pickup_item_raw_leaf
	
	-- "item_raw_leaf",
}

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

	caster.PickItemFromBench = (function( self, user, item )
		if type(item) == 'string' then
			item = CreateItemOnPositionSync(user:GetAbsOrigin(),CreateItem(item,nil,nil))
		end

		-- item:StopAnimation()
		
		if not self._bench_infinite_items then
			local old_data = self.wp:GetData()
			old_data.items = {}
			self.wp:SetData(old_data)

			self:OnPickedFromBench(item)
		end

		-- play pickup sound
		local itemName = item:GetContainedItem():GetAbilityName()
		soundName = 'custom_sound.pickup'
		if table.contains(custom_item_pickup_sounds, itemName) then
			soundName = soundName .. "_" .. itemName
		end
		EmitSoundOn(soundName,user)

		return item
	end)

	caster.AddItemToBench = (function( self, item, user )
		local old_data = self.wp:GetData()

		if type(item) ~= 'string' then
			item = item:GetContainedItem():GetName()
		end
		
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

	caster.ContainsPlateStack = (function( self )
		local old_data = self.wp:GetData()

		return old_data.items[1] and old_data.items[1] == "item_clean_plates"
	end)

	caster.ContainsPlate = (function( self )
		local old_data = self.wp:GetData()

		return old_data.items[1] and old_data.items[1] == "item_plate"
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

	caster.IsRefining = (function( self )
		local old_data = self.wp:GetData()

		return old_data.passed or old_data.paused or (self.HasModifier and self:HasModifier("modifier_unselectable"))
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

	caster.BindItem = (function( self, item )
		if type(item) == 'string' then
			item = CreateItemOnPositionSync(self:GetAbsOrigin(),CreateItem(item,self,self))
		end

		Frostivus:BindItem(item, self, (function ()
			return self:GetAbsOrigin() + Vector(0,0,128)
		end),(function ()
			return Frostivus:IsCarryingItem( self, item )
		end), (function ()
			Frostivus:DropItem( self, item )
		end), true, false)
	end)

	caster.ClearBench = (function ( self )
		Frostivus:GetCarryingItem(self):RemoveSelf()
		self:RemoveModifierByName("modifier_carrying_item")
		local old_data = self.wp:GetData()
		old_data.items = {}
		self.wp:SetData(old_data)
	end)
end

function OnUse( bench, user )
	if user then
		if not user:FindModifierByName("modifier_carrying_item") and bench.wp:GetData().items[1] then
			-- bench:AddNewModifier(nil,nil,"modifier_bench_busy",{duration = 0.4})
			StartAnimation(user, {duration=0.3, activity=ACT_DOTA_GREEVIL_CAST, rate=2, translate="greevil_miniboss_black_nightmare"})

			user:EmitSound("WeaponImpact_Common.Wood")

			-- Picking a plate from a plate stack
			if bench:ContainsPlateStack() then
				bench = Frostivus:GetCarryingItem(bench)
			end

			local item_name = bench.wp:GetData().items[1]

			if (Frostivus.ItemsKVs[item_name].CanBePickedFromBench or bench:HasModifier("modifier_crate") or bench:HasModifier("modifier_transfer_bench")) and bench:GetBenchItemCount() == 1 and not bench:IsRefining() then
				-- Picking item from the bench
				local item = item_name
				if bench:Is3DBench() and Frostivus:IsCarryingItem( bench ) and not bench._bench_infinite_items then
					item = Frostivus:DropItem( bench, Frostivus:GetCarryingItem( bench ) )
					-- if item then
					-- 	item:RemoveSelf()
					-- end
				end

				-- If bench is 3D then it will return binded container, otherwise it will create one
				item = bench:PickItemFromBench(user, item)

				user:BindItem( item )
			elseif bench:IsBenchFull() and bench:IsRefineBench() then
				-- Use full bench (e.g. after interrupting channel)
				bench:OnBenchIsFull(bench.wp:GetData().items, user)
			end
		elseif not bench:IsBenchFull() or bench:HasModifier("modifier_bin") or bench:ContainsPlate() then
			-- bench:AddNewModifier(nil,nil,"modifier_bench_busy",{duration = 0.45})
			StartAnimation(user, {duration=0.3, activity=ACT_DOTA_GREEVIL_CAST, rate=2.5, translate="greevil_laguna_blade"})

			user:EmitSound("WeaponImpact_Common.Wood")

			-- Adding item to a plate
			if bench:ContainsPlate() then
				bench = Frostivus:GetCarryingItem( bench )
			end

			-- Adding item to the bench
			if user:FindModifierByName("modifier_carrying_item") then
				local item = user:FindModifierByName("modifier_carrying_item").item

				if item and bench:CheckItem(item) then
					bench:AddItemToBench(item, user)

					Frostivus:DropItem( user, item )

					if bench:Is3DBench() then
						bench:BindItem(item)
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

	if not target_item then
		return
	end

	bench:OnStartRefine(target_item)
	EmitSoundOn('custom_sound.chopping',bench)

	local duration = bench:GetRefineDuration()

	local ab = user:FindAbilityByName("frostivus_pointer")

	local old_data = bench.wp:GetData()

	if old_data.paused then
		duration = duration * (1 - old_data.paused)
	end

	old_data.duration = duration
	old_data.layout = 1
	bench.wp:SetData(old_data)

	user:AddNewModifier(user,ab,"modifier_bench_interaction",{duration = duration}):SetStackCount(duration * 100)
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

		else
			-- local old_data = bench.wp:GetData()
			-- old_data.items[1] = target_item
			-- bench.wp:SetData(old_data)

			if bench:Is3DBench() and bench:FindModifierByName("modifier_carrying_item") then
				local item = bench:FindModifierByName("modifier_carrying_item").item

				Frostivus:DropItem( bench, item )

				item:RemoveSelf()

				bench:BindItem(target_item)
			end
		end
	end)

	ab.bench = bench
	user:CastAbilityNoTarget(ab, user:GetPlayerOwnerID())

	bench:SetBenchHidden(false)
end