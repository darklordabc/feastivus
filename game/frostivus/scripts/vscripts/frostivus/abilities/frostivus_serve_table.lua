frostivus_serve_table = class({})

function frostivus_serve_table:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
        caster:InitBench(3, (function( bench, item )
        	return Frostivus.ItemsKVs[item:GetContainedItem():GetName()].CanBeServed == 1
        end), (function ( bench, items )
        	-- g_TryServe(CreateItem(item,nil,nil))
        end), 0)

        caster:SetBenchHidden(true)

        -- caster:AddItemToBench("item_bin_icon")

        caster.AddItemToBench = (function( self, item, user )
            if type(item) ~= 'string' then
                item = item:GetContainedItem():GetName()
            end

        	item = CreateItem(item,nil,nil)
    		g_Serve(item, user)

            local container = Frostivus:GetCarryingItem(self)

            if not IsValidEntity(container) then
                container = CreateItemOnPositionSync(self:GetAbsOrigin(),CreateItem("item_dirty_plates",self,self))

                local old_data = self.wp:GetData()
                old_data.items = {}
                table.insert(old_data.items, "item_dirty_plates")
                self.wp:SetData(old_data)
            end

            self:BindItem(container, (function ()
                return self:GetAbsOrigin() + Vector(0, -100, 92)
            end))

            container:GetContainedItem()._counter = (container:GetContainedItem()._counter or 0) + 1

            container:SetModel("models/plates/dirty_plate_"..tostring(container:GetContainedItem()._counter)..".vmdl")
        end)
    end)
end

function frostivus_serve_table:GetIntrinsicModifierName()
    return "modifier_serve_table"
end

modifier_serve_table = class({})
LinkLuaModifier("modifier_serve_table", "frostivus/abilities/frostivus_serve_table.lua", 0)