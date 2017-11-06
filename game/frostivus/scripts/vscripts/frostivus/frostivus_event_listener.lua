FrostivusEventListener = class({})

FrostivusEventListener.vEventNames = {}
FrostivusEventListener.vEventCallbacks = {}

function FrostivusEventListener:RegisterListener(pszEventName, funcCallback)
    if not self.vEventCallbacks[pszEventName] then
        --print("new kind of event registered ->" .. pszEventName)
        self.vEventCallbacks[pszEventName] = {}
    end
    local nEventID = DoUniqueString("e")
    self.vEventCallbacks[pszEventName][nEventID] = funcCallback
    self.vEventNames[nEventID] = pszEventName
    return nEventID
end

function FrostivusEventListener:UnregisterListener(nEventID)
    local pszEventName = self.vEventNames[nEventID]
    if not pszEventName then
        error(debug.traceback("attempt to remove unregistered event"))
    end

    self.vEventCallbacks[pszEventName][nEventID] = nil
    self.vEventNames[nEventID] = nil
end

function FrostivusEventListener:Trigger(eventName, eventArgs)
    if not self.vEventCallbacks[eventName] then
        print("event triggered but no one registered", eventName)
        return
    end

    print("EventManager:[Triggered]->", eventName)

    for _, callback in pairs(self.vEventCallbacks[eventName]) do
        --print("calling!")
        local success, msg = pcall(callback, eventArgs)
        if not success then print(msg) end
    end
end

GameRules.FrostivusEventListener = FrostivusEventListener