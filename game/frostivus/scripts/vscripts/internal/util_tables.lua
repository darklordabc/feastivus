function ShallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function GetRandomElement(list, checker, return_key)
  local new_table = {}

  for k,v in pairs(list) do
    if (checker and checker(v) == false) then

    else
      new_table[k] = v
    end
  end

  local count = GetTableLength(new_table)
  local seed = math.random(1, count)
  local i = 1
  
  for k,v in pairs(new_table) do
    if i == seed then
      if return_key then
        return k
      end
      return v
    end
    i = i + 1
  end
end

function Shuffle(list)
    local indices = {}
    for i = 1, #list do
        indices[#indices+1] = i
    end

    local shuffled = {}
    for i = 1, #list do
        local index = math.random(#indices)

        local value = list[indices[index]]

        table.remove(indices, index)

        shuffled[#shuffled+1] = value
    end

    return shuffled
end

function GetTableKeys(t)
  local keyset={}
  local n=0

  for k,v in pairs(t) do
    n=n+1
    keyset[n]=k
  end

  return keyset
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

function MergeTables(t1, t2)
  for k,v in pairs(t2) do
    if type(v) == "table" then
      if type(t1[k] or false) == "table" then
        Util:MergeTables(t1[k] or {}, t2[k] or {})
      else
        t1[k] = v
      end
    else
      t1[k] = v
    end
  end
  return t1
end

function __genOrderedIndex( t )
  local orderedIndex = {}
  for key in pairs(t) do
    table.insert( orderedIndex, key )
  end
  table.sort( orderedIndex )
  return orderedIndex
end

function orderedNext(t, state)
  -- Equivalent of the next function, but returns the keys in the alphabetic
  -- order. We use a temporary ordered key table that is stored in the
  -- table being iterated.

  local key = nil
  --print("orderedNext: state = "..tostring(state) )
  if state == nil then
    -- the first time, generate the index
    t.__orderedIndex = __genOrderedIndex( t )
    key = t.__orderedIndex[1]
  else
    -- fetch the next value
    for i = 1,table.getn(t.__orderedIndex) do
      if t.__orderedIndex[i] == state then
        key = t.__orderedIndex[i+1]
      end
    end
  end

  if key then
    return key, t[key]
  end

  -- no more value to return, cleanup
  t.__orderedIndex = nil
  return
end

function orderedPairs(t)
  -- Equivalent of the pairs() function on tables. Allows to iterate
  -- in order
  return orderedNext, t, nil
end

--[[
  table library in table scope
  @author:XavierCHN
  @date:2015.11
]]
function table.count(t)
    local c = 0
    for _ in pairs(t) do
        c = c + 1
    end

    return c
end

function table.contains(t, v)
    for _, _v in pairs(t) do
        if _v == v then
            return true
        end
    end
end

function table.has_element_fit(t, func)
    for k, v in pairs(t) do
        if func(t, k, v) then
            return k, v
        end
    end
end

function table.findkey(t, v)
    for k, _v in pairs(t) do
        if _v == v then
            return k
        end
    end
end

function table.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.random(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    local key = keys[RandomInt(1, # keys)]
    return t[key], key
end

function table.shuffle(tbl)
    local t = table.shallowcopy(tbl)
    for i = # t, 2, - 1 do
        local j    = RandomInt(1, i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

function table.random_some(t, count)
    local key_table = table.make_key_table(t)
    key_table       = table.shuffle(key_table)
    local r         = {}
    for i = 1, count do
        local key = key_table[i]
        table.insert(r, t[key])
    end
    return r
end

function table.random_with_condition(t, func)
    local keys = {}
    for k, v in pairs(t) do
        if func(t, k, v) then
            table.insert(keys, k)
        end
    end

    local key = keys[RandomInt(1, # keys)]
    return t[key], key
end

function table.random_with_weight(t)
    local weight_table = {}
    local total_weight = 0
    for k, v in pairs(t) do
        local w
        if v.GetWeight then
            w = v:GetWeight()
        else
            w = v.Weight or v[2] or 0
        end
        total_weight = total_weight + w
        table.insert(weight_table, { key = k, total_weight = total_weight })
    end

    local randomValue = RandomFloat(0, total_weight)
    for i = 1, # weight_table do
        if weight_table[i].total_weight >= randomValue then
            local key = weight_table[i].key
            return t[key]
        end
    end
end

function table.filter(t, condition)
    local r = {}
    for k, v in pairs(t) do
        if condition(t, k, v) then
            r[k] = v
        end
    end
    return r
end

function table.make_key_table(t)
    local r = {}
    for k, _ in pairs(t) do
        table.insert(r, k)
    end
    return r
end

function table.is_equal(t1, t2)
    for k, v in pairs(t1) do
        if t2[k] ~= v then
            return false
        end
    end
    return true
end

function table.random_key(t)
    return table.random(table.make_key_table(t))
end