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

function CDOTA_Item_Physical:TriggerOnUse( user )
	self._on_use = self._on_use or (function( ) Frostivus:L("Triggered!") end)
	self._on_use(self, user)
end

function CDOTA_Item_Physical:SetOnUse( callback )
	self._on_use = callback or (function( ) Frostivus:L("Triggered!") end)
end