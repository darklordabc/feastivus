function Spawn ( entityKeyValues )
	ExecOnGameInProgress( function (  )
		thisEntity:SetOnUse( OnUse )

		thisEntity:AddNewModifier(nil,nil,"modifier_hide_health_bar",{})
	end)
end

function OnUse( thisEntity, user )
	if user then
		if not Frostivus:IsCarryingItem( thisEntity, item ) then
			if user:FindModifierByName("modifier_carrying_item") then
				local old_item = user:FindModifierByName("modifier_carrying_item").item

				if old_item then
					local item = old_item

					Frostivus:BindItem(item, thisEntity, (function ()
						return thisEntity:GetAbsOrigin() + Vector(0,0,128)
					end),(function ()
						return Frostivus:IsCarryingItem( thisEntity, item )
					end),(function ()
						Frostivus:DropItem( thisEntity, item )
					end), true, false)

					item:FollowEntity(thisEntity,false)

					Frostivus:DropItem( user, item )
				end
			end
		elseif not Frostivus:IsCarryingItem( user ) then
			local item = thisEntity:FindModifierByName("modifier_carrying_item").item

			Frostivus:BindItem(item, user, (function ()
				return user:GetAbsOrigin() + Vector(0,0,128) + user:GetForwardVector() * 32
			end),(function ()
				return Frostivus:IsCarryingItem( user, item )
			end), nil, true, false)

			Frostivus:DropItem( thisEntity, item )
		end
	end
end