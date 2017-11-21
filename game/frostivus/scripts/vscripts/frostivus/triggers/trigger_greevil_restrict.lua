function OnGreevilTouchedRestrictArea(keys)
	if keys.activator:GetName() == "npc_dota_hero_axe" then
		local greevil = keys.activator
		local entOrigin = keys.caller:GetOrigin()
		greevil.__bTouchingRestrictArea__ = true
		Timers:CreateTimer(function()
			if greevil.__bTouchingRestrictArea__ then
				local origin = greevil:GetOrigin()
				if greevil.__vLastTouchPosition__ == nil then
					greevil.__vLastTouchPosition__ = origin
				end

				local d1 = math.abs(greevil.__vLastTouchPosition__.y - entOrigin.y)
				local d2 = math.abs(origin.y - entOrigin.y)
				if (d2 < d1) then
					origin.y = greevil.__vLastTouchPosition__.y
					greevil:SetOrigin(origin)
				end
				greevil.__vLastTouchPosition__ = origin
				return 0.03
			else
				greevil.__vLastTouchPosition__ = nil
				return nil
			end
		end)
	end
end

function OnGreevilEndTouchRestrictArea(keys)
	if keys.activator:GetName() == "npc_dota_hero_axe" then
		keys.activator.__bTouchingRestrictArea__ = nil
	end
end