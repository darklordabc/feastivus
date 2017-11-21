function PlayPickupSound( item, entity )
  if type(item) ~= 'string' then
    item = item:GetContainedItem():GetName()
  end

  local item_kv = Frostivus.ItemsKVs[item]
  local sound = item_kv.PickupSound

  if not sound and string.match(item, "plate") then
    sound = "custom_sound.plate_pickup"
  else
    sound = "custom_sound.pickup"
  end

  EmitSoundOn(sound, entity)
end

function PlayDropSound( item, entity )
  if type(item) ~= 'string' then
    item = item:GetContainedItem():GetName()
  end

  local item_kv = Frostivus.ItemsKVs[item]
  local sound = item_kv.DropSound

  if not sound and string.match(item, "plate") then
    sound = "custom_sound.plate_drop"
  else
    sound = "custom_sound.drop"
  end

  EmitSoundOn(sound, entity)
end

function ExecOnGameInProgress( callback )
  Timers:CreateTimer(function ()
    local newState = GameRules:State_Get()

    if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
      callback()
    else
      return 0.03
    end
  end)
end

function InitAbilities( hero )
  for i=0, hero:GetAbilityCount()-1 do
    local abil = hero:GetAbilityByIndex(i)
    if abil ~= nil then
      if hero:IsHero() and hero:GetAbilityPoints() > 0 then
        hero:UpgradeAbility(abil)
      elseif abil:GetLevel() < 1 then
        abil:SetLevel(1)
      end
    end
  end
end

function Distance(a, b)
  if not a.x then
    a = a:GetAbsOrigin()
  end
  if not b.x then
    b = b:GetAbsOrigin()
  end
  return (a - b):Length()
end

function UnitLookAtPoint( unit, point )
  local dir = (point - unit:GetAbsOrigin()):Normalized()
  dir.z = 0
  if dir == Vector(0,0,0) then return unit:GetForwardVector() end
  return dir
end

function IsInFront(a,b,direction,angle)
  local product = (a.x - b.x) * direction.x + (a.y - b.y) * direction.y + (a.z - b.z) * direction.z
  return product < -angle and product > (-180 + angle)
end

function FindUnitsInCone(position, coneDirection, coneLength, coneWidth, teamNumber, teamFilter, typeFilter, flagFilter, order)
  local units = FindUnitsInRadius(teamNumber, position, nil, coneLength, teamFilter, typeFilter, flagFilter, order, false)

  coneDirection = coneDirection:Normalized()

  local output = {}
  for _, unit in pairs(units) do
    local direction = (unit:GetAbsOrigin() - position):Normalized()
    if direction:Dot(coneDirection) >= math.cos(coneWidth/2) then
      table.insert(output, unit)
    end
  end

  return output
end

function GetTableLength( t )
  if not t then return 0 end
  local length = 0

  for k,v in pairs(t) do
    if v then
      length = length + 1
    end
  end

  return length
end

function deepcompare(t1,t2,ignore_mt)
  local ty1 = type(t1)
  local ty2 = type(t2)
  if ty1 ~= ty2 then return false end
  -- non-table types can be directly compared
  if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
  -- as well as tables which have the metamethod __eq
  local mt = getmetatable(t1)
  if not ignore_mt and mt and mt.__eq then return t1 == t2 end
  for k1,v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not deepcompare(v1,v2) then return false end
  end
  for k2,v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not deepcompare(v1,v2) then return false end
  end
  return true
end

function DebugPrint(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    print(...)
  end
end

function DebugPrintTable(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    PrintTable(...)
  end
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


function DebugAllCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name .. " -- " .. info.currentline)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end




--[[Author: Noya
  Date: 09.08.2015.
  Hides all dem hats
]]
function HideWearables( unit )
  unit.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(unit.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables( unit )

  for i,v in pairs(unit.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
end

function LoopOverHeroes(callback)
  for i = 0, DOTA_MAX_PLAYERS do
      local player = PlayerResource:GetPlayer(i)
      if player then
        local hero = player:GetAssignedHero()
        if hero then
          callback(hero)
        end
      end
    end   
end

function LoopOverPlayers(callback)
  for i = 0, DOTA_MAX_PLAYERS do
    local player = PlayerResource:GetPlayer(i)
    if player then
      callback(player)
    end
  end
end

function StartMainThemeAtPosition(pos)
  GameRules.__bMusicPlaying = true
  if GameRules.__hMusicPlayerEntity == nil then
    GameRules.__hMusicPlayerEntity = CreateUnitByName("npc_camera_target", pos, false, nil, nil, DOTA_TEAM_GOODGUYS)
  end
  GameRules.__hMusicPlayerEntity:SetAbsOrigin(pos)
  GameRules.__hMusicPlayerEntity:StopSound("custom_music.main_theme")
  GameRules.__hMusicPlayerEntity:EmitSound("custom_music.main_theme")
  Timers:CreateTimer(67, function()
    if GameRules.__bMusicPlaying then
      GameRules.__hMusicPlayerEntity:EmitSound("custom_music.main_theme")
    end
  end)
end

function StopMainTheme()
  GameRules.__bMusicPlaying = false
  if GameRules.__hMusicPlayerEntity == nil then
    GameRules.__hMusicPlayerEntity = CreateUnitByName("npc_camera_target", Vector(0,0,0), false, nil, nil, DOTA_TEAM_GOODGUYS)
  end
  GameRules.__hMusicPlayerEntity:StopSound("custom_music.main_theme")
end