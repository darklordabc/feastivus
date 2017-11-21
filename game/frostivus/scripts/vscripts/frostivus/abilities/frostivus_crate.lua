frostivus_crate = class({})

function frostivus_crate:OnUpgrade()
	local caster = self:GetCaster()
	caster.SetCrateItem = (function( self, item )
		self:AddItemToBench(item)
        self:SetBenchInfiniteItems(true)
        self:SetBenchHidden(true)

        caster:SetCheckItem( function ( self, item )
            return false
        end )

        self:SetOnPickedFromBench(function ( item )
            EmitSoundOn("custom_sound.crate_pickup", item)
        end)

        local panelTable = 
        {
            origin = caster:GetAbsOrigin() + Vector(0,0,93),
            dialog_layout_name = "file://{resources}/layout/custom_game/frostivus/crate.xml",
            width = "160",
            height = "160",
            panel_dpi = "1",
            interact_distance = "0",
            horizontal_align = "1",
            vertical_align = "1",
            orientation = "0",
            angles = "0 0 0"
        }
        local lockedPanel = SpawnEntityFromTableSynchronous("point_clientui_world_panel", panelTable)
        CustomGameEventManager:Send_ServerToAllClients("frostivus_crate_item", {id = lockedPanel:GetEntityIndex(); item = item})
        -- lockedPanel:SetParent(handAttachment, "lock_message")
	end)
end

function frostivus_crate:GetIntrinsicModifierName()
    return "modifier_crate"
end

modifier_crate = class({})
LinkLuaModifier("modifier_crate", "frostivus/abilities/frostivus_crate.lua", 0)

modifier_crate_open = class({})
LinkLuaModifier("modifier_crate_open", "frostivus/abilities/frostivus_crate.lua", 0)

function modifier_crate_open:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MODEL_CHANGE,
    }

    return funcs
end

function modifier_crate_open:GetPriority()
    return MODIFIER_PRIORITY_ULTRA
end

function modifier_crate_open:GetModifierModelChange()
    return "models/crate/ingredient_crate_02.vmdl"
end

function modifier_crate_open:IsPurgable()
    return false
end

function modifier_crate_open:IsHidden()
    return true
end