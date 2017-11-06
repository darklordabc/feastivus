frostivus_pointer = class({})

function frostivus_pointer:GetChannelTime()
	return self._channel or (self:GetCaster():GetModifierStackCount("modifier_bench_interaction", self:GetCaster()) / 100) or 0.0
end

function frostivus_pointer:OnSpellStart()
	local caster = self:GetCaster()

	local modifier = caster:FindModifierByName("modifier_pointer")
	if modifier.target and modifier.target.TriggerOnUse and not caster:HasModifier("modifier_bench_interaction") then
		-- modifier.target:TriggerOnUse(caster)
		local order_table = {
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
			TargetIndex = modifier.target:entindex()
		}

		ExecuteOrderFromTable(order_table)
	end

	self._time = 0.0
end

function frostivus_pointer:OnChannelThink(flInterval)
	if IsServer() then
		self._time = self._time + flInterval
	end
end

function frostivus_pointer:OnChannelFinish(bInterrupted)
	if IsServer() then
		if bInterrupted then
			if self._interrupted then
				self._interrupted(self._time)
			end
		else
			if self._finished then
				self._finished()
			end
		end
		self.bench = nil
		EndAnimation(self:GetCaster())
	end
end

function frostivus_pointer:OnUpgrade()
	local caster = self:GetCaster()
end

function frostivus_pointer:GetIntrinsicModifierName()
    return "modifier_pointer"
end

modifier_bench_interaction = class({})
LinkLuaModifier("modifier_bench_interaction", "frostivus/abilities/frostivus_pointer.lua", 0)

if IsServer() then
	function modifier_bench_interaction:OnCreated(kv)
		StartAnimation(self:GetParent(), {duration=-1, activity=ACT_DOTA_GREEVIL_CAST, rate=1, translate="greevil_magic_missile"})

		if kv.sound then
			self._sound = kv.sound
			self._dont_repeat_sound = kv.dont_repeat_sound
			EmitSoundOn(self._sound, self:GetParent())
		end

		self:StartIntervalThink(1.0)
	end

	function modifier_bench_interaction:OnIntervalThink()
		StartAnimation(self:GetParent(), {duration=-1, activity=ACT_DOTA_GREEVIL_CAST, rate=1, translate="greevil_magic_missile"})

		if self._sound and not self._dont_repeat_sound then
			EmitSoundOn(self._sound, self:GetParent())
		end
	end

	function modifier_bench_interaction:OnDestroy()
		EndAnimation(self:GetParent())
	end

	function modifier_bench_interaction:OnOrder()
		self:RemoveSelf()
		EndAnimation(self:GetParent())
	end
end

function modifier_bench_interaction:IsHidden()
	return true
end

modifier_pointer = class({})
LinkLuaModifier("modifier_pointer", "frostivus/abilities/frostivus_pointer.lua", 0)

if IsServer() then
	function modifier_pointer:OnCreated(keys)
		self:StartIntervalThink(0.1)
	end

	function modifier_pointer:OnIntervalThink()
		local caster = self:GetParent()

		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

		-- for k,v in pairs(units) do
		-- 	if not IsInFront(caster:GetAbsOrigin(),v:GetAbsOrigin(),caster:GetForwardVector(), 40) then
		-- 		units[k] = nil
		-- 	end
		-- end

		if #units > 0 then
			for k,v in pairs(units) do
				if v:HasModifier("modifier_bench") then
					self.target = v
					break
				end
			end
		else
			self.target = nil
		end
	end
end