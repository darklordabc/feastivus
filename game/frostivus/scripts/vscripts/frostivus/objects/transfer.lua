function Spawn ( entityKeyValues  )
	thisEntity:SetOnUse( OnUse )
end

function OnUse( thisEntity, user )
	if user then
		if not Frostivus:IsCarryingItem( thisEntity, item ) then
			local old_item = user:FindModifierByName("modifier_carrying_item").item

			if old_item then
				local item = old_item

				Frostivus:BindItem(item, thisEntity, (function ()
					return thisEntity:GetAbsOrigin() + Vector(0,0,128)
				end),(function ()
					return Frostivus:IsCarryingItem( thisEntity, item )
				end),(function ()
					thisEntity:RemoveModifierByName("modifier_unselectable")
					Frostivus:DropItem( thisEntity, item )
				end), true, true)

				thisEntity:AddNewModifier(thisEntity,nil,"modifier_unselectable",{})

				Frostivus:DropItem( user, item )
			end
		end
	end
end