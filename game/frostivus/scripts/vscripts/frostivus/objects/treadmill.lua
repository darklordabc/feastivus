function Objects:ManageTreadmill(object)
  local flSpeed = 3
  for k,v in pairs(Objects:FindUnitsOnTop(object)) do
    v:SetAbsOrigin(v:GetAbsOrigin()+object:GetForwardVector()*flSpeed)
    -- Particle effect?
  end
end