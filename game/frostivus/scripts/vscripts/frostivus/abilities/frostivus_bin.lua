frostivus_bin = class({})

function frostivus_bin:OnUpgrade()
	local caster = self:GetCaster()

    ExecOnGameInProgress(function (  )
        caster:InitBench(1, nil, nil, 64)

        caster:SetFakeItem("item_bin_icon")

        caster:SetCustomInteract(function ( bench, user, item )
        	local item_name = item:GetContainedItem():GetName()

        	local is_bank = item_name == "item_pot" or item_name == "item_frying_pan"

        	if is_bank then
				item:ClearBank()
            elseif item:IsBench() and item:GetBenchItemCount() == 0 then
                return
        	elseif Frostivus.ItemsKVs[item_name].CanBeServed then
				local dirty_plate = CreateItemOnPositionSync(user:GetAbsOrigin(),CreateItem("item_dirty_plates",user,user))
            	dirty_plate:GetContainedItem()._counter = 1
            	dirty_plate:SetModel("models/plates/dirty_plate_1.vmdl")

            	Frostivus:DropItem( user, item ):RemoveSelf()
            	user:BindItem(dirty_plate)
        	else
        		Frostivus:DropItem( user, item ):RemoveSelf()
        	end
        end)
    end)
end

function frostivus_bin:GetIntrinsicModifierName()
    return "modifier_bin"
end

modifier_bin = class({})
LinkLuaModifier("modifier_bin", "frostivus/abilities/frostivus_bin.lua", 0)