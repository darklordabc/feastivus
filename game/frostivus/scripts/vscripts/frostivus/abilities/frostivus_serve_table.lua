function RotateVector2D(v,theta)
    local xp = v.x*math.cos(theta)-v.y*math.sin(theta)
    local yp = v.x*math.sin(theta)+v.y*math.cos(theta)
    return Vector(xp,yp,v.z):Normalized()
end

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

            if user.__bPlayingTutorial then
                user:OnDoTutorialServe(item)
    		else
                local success = g_Serve(item, user)
                if success then
                    PopupParticle(SCORE_PER_FINISHED_ORDER, Vector(250,250,250), 1.0, self, POPUP_SYMBOL_PRE_PLUS)

                    local p = ParticleManager:CreateParticle("particles/frostivus_gameplay/fireworks.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
                    ParticleManager:SetParticleControl(p, 3, self:GetAbsOrigin() + Vector(0,0,300))
                    
                    self:EmitSound("Frostivus.PointScored.Team")
                end
            end

            local container = Frostivus:GetCarryingItem(self)

            if not IsValidEntity(container) then
                container = CreateItemOnPositionSync(self:GetAbsOrigin(),CreateItem("item_dirty_plates",self,self))

                local old_data = self.wp:GetData()
                old_data.items = {}
                table.insert(old_data.items, "item_dirty_plates")
                self.wp:SetData(old_data)
            end

            self:BindItem(container, (function ()
                local forward = (100 * RotateVector2D(self:GetForwardVector(),math.rad(90)))
                local pos = self:GetAbsOrigin() + forward
                pos.z = self:GetAbsOrigin().z + 90
                return pos
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