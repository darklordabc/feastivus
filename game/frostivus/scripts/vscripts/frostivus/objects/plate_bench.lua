function InitBench( keys )
	local caster = keys.caster
	local ability = keys.ability

	ExecOnGameInProgress(function (  )
		caster:InitBench(1, nil, nil, 0)
		caster:Set3DBench(true)
        caster:SetBenchHidden(true)

        caster:AddItemToBench("item_clean_plates")

        AddPlateStack(caster, 3 )
	end)
end