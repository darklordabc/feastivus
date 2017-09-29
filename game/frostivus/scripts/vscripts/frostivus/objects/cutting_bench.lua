function Spawn ( entityKeyValues )
	ExecOnGameInProgress( function (  )
		thisEntity:SetOnUse( OnUse )

		thisEntity:AddNewModifier(nil,nil,"modifier_hide_health_bar",{})

		thisEntity.wp = WorldPanels:CreateWorldPanelForAll({
			layout = "file://{resources}/layout/custom_game/worldpanels/bench.xml",
			position = GetGroundPosition(thisEntity:GetAbsOrigin(), nil) + Vector(0,0,128),
		})

		print("Asdasd")
	end)
end

function OnUse( thisEntity, user )
	if user then
		if not Frostivus:IsCarryingItem( thisEntity, item ) then
			if user:FindModifierByName("modifier_carrying_item") then
				local item = user:FindModifierByName("modifier_carrying_item").item

				if item then
					local old_data = thisEntity.wp.pt.data or {}
					
					if GetTableLength(old_data) == 4 then

					else
						table.insert(old_data, item:GetContainedItem():GetName())

						thisEntity.wp:SetData(old_data)

						Frostivus:DropItem( user, item )
					end
				end
			end
		end
	end
end