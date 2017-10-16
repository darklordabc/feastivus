function InitBench( keys )
	local caster = keys.caster
	local ability = keys.ability

	ExecOnGameInProgress(function (  )
		caster:InitBench(1, CheckItem)
		caster:SetBenchHidden(true)
		
		caster:SetRefineTarget("item_empty_bottle")
		caster:SetRefineDuration(2)
		caster:SetDefaultRefineRoutine()
	end)
end