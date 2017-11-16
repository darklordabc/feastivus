-- function CDOTA_BaseNPC:TriggerOnUse( user )
--   self._on_use = self._on_use or {(function( ) Frostivus:L("Triggered!") end)}

--   for k,v in pairs(self._on_use) do
--   	v(self, user)
--   end
-- end

-- function CDOTA_BaseNPC:SetOnUse( callback )
-- 	self._on_use = self._on_use or {}
-- 	local k = DoUniqueString(tostring(self:entindex()))
-- 	self._on_use[k] = callback
-- 	return k
-- end

function CDOTA_BaseNPC:TriggerOnUse( user )
	self._on_use = self._on_use or (function( ) Frostivus:L("Triggered!") end)
	self._on_use(self, user)
end

function CDOTA_BaseNPC:SetOnUse( callback )
	self._on_use = callback or (function( ) Frostivus:L("Triggered!") end)
end

function CDOTA_BaseNPC:BindItem( item )
	Frostivus:BindItem(item, self, (function ()
		return self:GetAbsOrigin() + Vector(0,0,128) + self:GetForwardVector() * 32
	end),(function ()
		return Frostivus:IsCarryingItem( self, item )
	end), (function (  )
		RemoveAnimationTranslate(self)
		AddAnimationTranslate(self, "level_3")
	end), true, false)

	RemoveAnimationTranslate(self)
	AddAnimationTranslate(self, "miniboss")
end

function CDOTA_BaseNPC:IsBench()
	return self.wp ~= nil
end

function CDOTA_BaseNPC:GetHolder()
	return self._holder
end

function CDOTA_Item_Physical:TriggerOnUse( user )
	self._on_use = self._on_use or (function( ) Frostivus:L("Triggered!") end)
	self._on_use(self, user)
end

function CDOTA_Item_Physical:SetOnUse( callback )
	self._on_use = callback or (function( ) Frostivus:L("Triggered!") end)
end

function CDOTA_Item_Physical:IsBench()
	return self.wp ~= nil
end

function CDOTA_Item_Physical:GetHolder()
	return self._holder
end

function CDOTA_BaseNPC_Hero:SetCameraTargetPosition(pos)
	if self.vCameraTarget == nil then
		self.vCameraTarget =CreateUnitByName("npc_camera_target", pos, false, self, self, self:GetTeamNumber())
	end

	self.vCameraTarget:SetAbsOrigin(pos)
	PlayerResource:SetCameraTarget(self:GetPlayerID(), self.vCameraTarget)
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(pos.z)
end