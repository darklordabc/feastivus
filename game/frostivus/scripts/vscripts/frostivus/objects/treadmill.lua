function Objects:ManageTreadmill(object)
  local origin = treadmill:GetAbsOrigin()
  local flSpeed = 3
  for k,v in pairs(Objects:FindUnitsOnTop(object)) do
    v:SetAbsOrigin(v:GetAbsOrigin+object:GetForwardVector()*flSpeed)
    -- Particle effect?
  end
end