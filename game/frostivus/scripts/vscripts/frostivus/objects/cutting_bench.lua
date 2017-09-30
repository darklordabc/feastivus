function Spawn ( entityKeyValues )
	ExecOnGameInProgress( function (  )
		thisEntity:SetOnUse( OnUse )

		thisEntity:AddNewModifier(nil,nil,"modifier_hide_health_bar",{})

		thisEntity.wp = WorldPanels:CreateWorldPanelForAll({
			layout = "file://{resources}/layout/custom_game/worldpanels/bench.xml",
			entity = thisEntity,
			entityHeight = 64,
		})
	end)
end

function OnUse( thisEntity, user )
	if user then
		if not Frostivus:IsCarryingItem( thisEntity, item ) then
			if user:FindModifierByName("modifier_carrying_item") then
				local item = user:FindModifierByName("modifier_carrying_item").item

				if item then
					local old_data = {}
					if thisEntity.wp.pt.data then
						for k,v in pairs(thisEntity.wp.pt.data) do
							old_data[k] = v
						end
					end
					
					if GetTableLength(old_data) == 4 then

					else
						table.insert(old_data, item:GetContainedItem():GetName())
						thisEntity.wp:SetData(old_data)

						item:AddEffects(EF_NODRAW)
						item:SetAbsOrigin(thisEntity:GetAbsOrigin())

						Frostivus:DropItem( user, item )
					end
				end
			end
		end
	end
end