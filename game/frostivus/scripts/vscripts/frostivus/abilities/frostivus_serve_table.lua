frostivus_serve_table = class({})

function frostivus_serve_table:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
        caster:InitBench(1, (function( bench, item )
        	print(item:GetContainedItem():GetName())
        	return Frostivus.ItemsKVs[item:GetContainedItem():GetName()].CanBeServed == 1
        end), (function ( bench, items )
        	-- g_TryServe(CreateItem(item,nil,nil))
        end), 0)

        -- caster:AddItemToBench("item_bin_icon")

        caster.AddItemToBench = (function( self, item )
        	g_TryServe(CreateItem(item,nil,nil))
        end)
    end)
end

function frostivus_serve_table:GetIntrinsicModifierName()
    return "modifier_serve_table"
end

modifier_serve_table = class({})
LinkLuaModifier("modifier_serve_table", "frostivus/abilities/frostivus_serve_table.lua", 0)