function InitBench( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster.SetCrateItem = (function( self, item )
		self:AddItemToBench(item)
	end)
end