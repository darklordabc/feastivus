frostivus_bin = class({})

function frostivus_bin:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
        caster:InitBench(1, nil, nil, 64)

        caster:AddItemToBench("item_bin_icon")

        caster.AddItemToBench = (function( self, item ) end)
    end)
end

function frostivus_bin:GetIntrinsicModifierName()
    return "modifier_bin"
end

modifier_bin = class({})
LinkLuaModifier("modifier_bin", "frostivus/abilities/frostivus_bin.lua", 0)