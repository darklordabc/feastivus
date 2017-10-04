function InitBench( keys )
	local caster = keys.caster
	local ability = keys.ability

	ExecOnGameInProgress(function (  )
		caster:InitBench(3)
	end)
end