POPUP_SYMBOL_PRE_PLUS = 0
POPUP_SYMBOL_PRE_MINUS = 1
POPUP_SYMBOL_PRE_SADFACE = 2
POPUP_SYMBOL_PRE_BROKENARROW = 3
POPUP_SYMBOL_PRE_SHADES = 4
POPUP_SYMBOL_PRE_MISS = 5
POPUP_SYMBOL_PRE_EVADE = 6
POPUP_SYMBOL_PRE_DENY = 7
POPUP_SYMBOL_PRE_ARROW = 8

POPUP_SYMBOL_POST_EXCLAMATION = 0
POPUP_SYMBOL_POST_POINTZERO = 1
POPUP_SYMBOL_POST_MEDAL = 2
POPUP_SYMBOL_POST_DROP = 3
POPUP_SYMBOL_POST_LIGHTNING = 4
POPUP_SYMBOL_POST_SKULL = 5
POPUP_SYMBOL_POST_EYE = 6
POPUP_SYMBOL_POST_SHIELD = 7
POPUP_SYMBOL_POST_POINTFIVE = 8

function PopupParticle(number, color, duration, caster, preSymbol, postSymbol)
  if number < 1 then
    return false
  end
  number = math.floor(number)
  local pfxPath = string.format("particles/frostivus_gameplay/score.vpcf", pfx)

  local pidx

  if caster:GetPlayerOwner() == nil then
    pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, caster)
  else
    pidx = ParticleManager:CreateParticleForPlayer(pfxPath, PATTACH_ABSORIGIN_FOLLOW, caster, caster:GetPlayerOwner())
  end

  local color = color
  local lifetime = duration
  local digits = #tostring(number) + 1

  local digits = 0
  if number ~= nil then
      digits = #tostring(number)
  end
  if preSymbol ~= nil then
      digits = digits + 1
  end
  if postSymbol ~= nil then
      digits = digits + 1
  end

  ParticleManager:SetParticleControl(pidx, 1, Vector( preSymbol, number, postSymbol ) )
  ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
  ParticleManager:SetParticleControl(pidx, 3, color)
end

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

function IsBenchReachable(unit, bench)
  local a, b = unit:GetAbsOrigin(), bench:GetAbsOrigin()
  if bench:GetUnitName() == "npc_serve_table" then
    local fw = bench:GetForwardVector()
    if fw.x == 1 then
      if ((a-b):Length2D() <= FROSTIVUS_CELL_SIZE + 1) then
        return true
      else
        a.y = a.y - 128
        if ((a-b):Length2D() <= FROSTIVUS_CELL_SIZE + 1) then
          return true
        else
          a.y = a.y + 256
          if ((a-b):Length2D() <= FROSTIVUS_CELL_SIZE + 1) then
            return true
          end
        end
      end
    elseif fw.y == 1 then
      if ((a-b):Length2D() <= FROSTIVUS_CELL_SIZE + 1) then
        return true
      else
        a.x = a.x - 128
        if ((a-b):Length2D() <= FROSTIVUS_CELL_SIZE + 1) then
          return true
        else
          a.x = a.x + 256
          if ((a-b):Length2D() <= FROSTIVUS_CELL_SIZE + 1) then
            return true
          end
        end
      end
    -- consider other directions, dont need them now
    end
  else
    return (a-b):Length2D() <= FROSTIVUS_CELL_SIZE + 1
  end
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
        if player.vExtraGreevillings and table.count(player.vExtraGreevillings) then
          for _, g in pairs(player.vExtraGreevillings) do
            callback(g)
          end
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

function StartMainThemeAtPosition(pos, round)
  if GameRules.__hMusicPlayerEntity == nil then
    GameRules.__hMusicPlayerEntity = CreateUnitByName("npc_camera_target", pos, false, nil, nil, DOTA_TEAM_GOODGUYS)
  end
  GameRules.__hMusicPlayerEntity:SetAbsOrigin(pos)
  GameRules.__hMusicPlayerEntity:StopSound("custom_music.main_theme")
  GameRules.__hMusicPlayerEntity:EmitSound("custom_music.main_theme")

  -- loop sound in round
  if round then
    Timers:CreateTimer(67, function()
      if round.nCountDownTimer > 0 and GameRules:State_Get() < DOTA_GAMERULES_STATE_POST_GAME then
        StartMainThemeAtPosition(pos, round)
      end
    end)
  end
end

function StopMainTheme()
  if GameRules.__hMusicPlayerEntity == nil then
    GameRules.__hMusicPlayerEntity = CreateUnitByName("npc_camera_target", Vector(0,0,0), false, nil, nil, DOTA_TEAM_GOODGUYS)
  end
  GameRules.__hMusicPlayerEntity:StopSound("custom_music.main_theme")
end

function StartMainTheme_Sad()
  print(debug.traceback("begin to play sad main theme"))
  GameRules.__hMusicPlayerEntity:StopSound("custom_music.main_theme")
  GameRules.__hMusicPlayerEntity:EmitSound("custom_music.main_theme.sad")
end

function CreateExtraGreevilForHero(hero)
  local player = PlayerResource:GetPlayer(hero:GetPlayerID())
  local greevilling = CreateUnitByName('npc_dota_hero_axe',hero:GetOrigin(),true,player,player,hero:GetTeamNumber())
  hero:AddNewModifier(hero, nil, "modifier_phased", {Duration=0.1})
  greevilling:AddNewModifier(greevilling, nil, "modifier_phased", {Duration=0.1})
  greevilling:SetControllableByPlayer(hero:GetPlayerID(),false)
  player.vExtraGreevillings = player.vExtraGreevillings or {}
  table.insert(player.vExtraGreevillings, greevilling)

  -- add greevil switch ability to both greevils
  hero:AddAbility("frostivus_swap_greevil")
  hero:FindAbilityByName("frostivus_swap_greevil"):SetLevel(1)
  greevilling:AddAbility("frostivus_swap_greevil")
  greevilling:FindAbilityByName("frostivus_swap_greevil"):SetLevel(1)

  greevilling.bIsExtra = true

  Timers:CreateTimer(0.5, function()
    CustomGameEventManager:Send_ServerToPlayer(player, "player_extra_greevil", {entindex = greevilling:GetEntityIndex()})
  end)
end

CustomGameEventManager:RegisterListener("request_extra_greevil", function(_, args)
  local playerid = args.PlayerID
  local player = PlayerResource:GetPlayer(playerid)
  if player then
    local greevilling
    for _, v in pairs(player.vExtraGreevillings or {}) do
      greevilling = v
    end
    if greevilling then
      CustomGameEventManager:Send_ServerToPlayer(player, "player_extra_greevil", {entindex = greevilling:GetEntityIndex()})
    end
  end
end)