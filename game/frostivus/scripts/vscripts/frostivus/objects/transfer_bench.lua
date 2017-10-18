function InitBench( keys )
	local caster = keys.caster
	local ability = keys.ability

	ExecOnGameInProgress(function (  )
		caster:InitBench(1, nil, nil, 0, true)
		caster:Set3DBench(true)
		caster:SetBenchHidden(true)
	end)
end