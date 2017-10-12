frostivus_channeling = class({})

function frostivus_channeling:GetBehavior() 
	local behav = DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_HIDDEN
	return behav
end

function frostivus_channeling:GetChannelTime()
	return 3.5
end

function frostivus_channeling:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster,self,"modifier_bench_interaction",{duration = self:GetChannelTime()})
end

function frostivus_channeling:OnChannelThink(flInterval)
	if IsServer() then

	end
end

function frostivus_channeling:OnChannelFinish(bInterrupted)
	if IsServer() then
		if bInterrupted then

		else

		end
	end
end

function frostivus_channeling:IsChanneling()
	return true
end

modifier_bench_interaction = class({})
LinkLuaModifier("modifier_bench_interaction", "frostivus/abilities/frostivus_channeling.lua", 0)

if IsServer() then
	function modifier_bench_interaction:OnCreated()
		StartAnimation(self:GetParent(), {duration=-1, activity=ACT_DOTA_GREEVIL_CAST, rate=1, translate="greevil_magic_missile"})
		self:StartIntervalThink(1.0)
	end

	function modifier_bench_interaction:OnIntervalThink()
		StartAnimation(self:GetParent(), {duration=-1, activity=ACT_DOTA_GREEVIL_CAST, rate=1, translate="greevil_magic_missile"})
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

function modifier_bench_interaction:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}
	return state
end