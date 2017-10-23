frostivus_serve_table = class({})

function frostivus_serve_table:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
        caster:InitBench(1, (function( bench, item )
        	return Frostivus.ItemsKVs[item:GetContainedItem():GetName()].CanBeServed == 1
        end), (function ( bench, items )
        	-- g_TryServe(CreateItem(item,nil,nil))
        end), 0)

        caster:SetBenchHidden(true)

        -- caster:AddItemToBench("item_bin_icon")

        caster.AddItemToBench = (function( self, item )
            if type(item) ~= 'string' then
                item = item:GetContainedItem():GetName()
            end

        	item = CreateItem(item,nil,nil)
    		g_Serve(item)

            caster._dirty_plates = caster._dirty_plates or CreateItemOnPositionSync(caster:GetAbsOrigin() + Vector(-64,-64,100),CreateItem("item_dirty_plates",caster,caster))
            caster._dirty_plates:GetContainedItem()._counter = (caster._dirty_plates:GetContainedItem()._counter or 0) + 1

            caster._dirty_plates:SetModel("models/plates/dirty_plate_"..tostring(caster._dirty_plates:GetContainedItem()._counter)..".vmdl")
        end)
    end)
end

function frostivus_serve_table:GetIntrinsicModifierName()
    return "modifier_serve_table"
end

modifier_serve_table = class({})
LinkLuaModifier("modifier_serve_table", "frostivus/abilities/frostivus_serve_table.lua", 0)