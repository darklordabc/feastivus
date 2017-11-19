function SwapGreevil(keys)
	local caster = keys.caster
	local playerid = caster:GetPlayerID()
	local player = PlayerResource:GetPlayer(playerid)

	CustomGameEventManager:Send_ServerToPlayer(player, "player_swap_greevil", {})
end