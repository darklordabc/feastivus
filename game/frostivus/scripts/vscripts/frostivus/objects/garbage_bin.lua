function Objects:ManageGarbageBin(object)
  for k,v in pairs(Objects:FindUnitsOnTop(object)) do
    UTIL_Remove(v)
    -- Particle effect?
  end
end