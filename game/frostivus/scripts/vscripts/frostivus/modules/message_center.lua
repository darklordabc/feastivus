MessageCenter = class({})

function MessageCenter:ShowMessageOnClient(player, args)
	local msgid = DoUniqueString("msg")
	args.id = msgid
	CustomGameEventManager:Send_ServerToPlayer(player,'frostivus_show_message',args)
	return msgid
end

function MessageCenter:ShowMessageOnAllClients(args)
	local msgid = DoUniqueString("msg")
	args.id = msgid
	CustomGameEventManager:Send_ServerToAllClients('frostivus_show_message',args)
	return msgid
end

function MessageCenter:RemoveMessage(msgid)
	CustomGameEventManager:Send_ServerToAllClients("frostivus_remove_message",{id = msgid})
end