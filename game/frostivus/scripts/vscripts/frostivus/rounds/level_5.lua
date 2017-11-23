LinkLuaModifier("modifier_kick_indicator", "frostivus/modifiers/modifier_kick_indicator.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tusk_kick", "frostivus/modifiers/modifier_tusk_kick.lua", LUA_MODIFIER_MOTION_BOTH)

local flKickInterval = 8

local forFunCreepSpawnPosBottom = Vector(-3974, 5300, -239)
local forFunCreepSpawnPosTop = Vector(-3974, 7400, -239)
-- local forFunCreepSpawnPosTop = Vector(-3974, 7900, -239) -- uncomment after extend river

local lastChaseTime = nil
local chaseDirection = "top-bottom"

local function hideCreep(creep)
	creep:AddNewModifier(creep, nil, "modifier_hide_health_bar", {})
	creep:AddNewModifier(creep, nil, "modifier_unselectable", {})
end

return {
	CameraTargetPosition = Vector(-3970.5, 6609.29, 1100),
	OnInitialize = function(round)
		-- in initialize script, setup round parameters
		-- such as pre round time, time limit, etc.
		print("RoundScript -> OnInitialize")
	end,
	OnTimer = function(round)
		local now = GameRules:GetGameTime()
		if lastChaseTime == nil then
			lastChaseTime = now
		end

		if now - lastChaseTime > 30 then
			local chasingCreeps = {}
			if chaseDirection == "top-bottom" then
				chaseDirection = "bottom-top"
				local creep1 = CreateUnitByName("creep_for_fun_dire", forFunCreepSpawnPosTop + Vector(-120,0,0), false, nil, nil, DOTA_TEAM_BADGUYS)
				table.insert(chasingCreeps, creep1)
				local creep2 = CreateUnitByName("creep_for_fun_dire", forFunCreepSpawnPosTop + Vector(120,0,0), false, nil, nil, DOTA_TEAM_BADGUYS)
				table.insert(chasingCreeps, creep2)
				local creep3 = CreateUnitByName("creep_for_fun_dire", forFunCreepSpawnPosTop + Vector(0,0,0), false, nil, nil, DOTA_TEAM_BADGUYS)
				table.insert(chasingCreeps, creep3)
				local creep4 = CreateUnitByName("creep_for_fun_radiant", forFunCreepSpawnPosTop + Vector(0, -300, 0) + Vector(0,0,0), false, nil, nil, DOTA_TEAM_BADGUYS)
				table.insert(chasingCreeps, creep4)
				Timers:CreateTimer(0.3, function()
					for _, creep in pairs(chasingCreeps) do
						hideCreep(creep)
						creep:MoveToPosition(forFunCreepSpawnPosBottom)
					end
				end)
			else
				chaseDirection = "top-bottom"
				local creep1 = CreateUnitByName("creep_for_fun_radiant", forFunCreepSpawnPosBottom + Vector(-120,0,0), false, nil, nil, DOTA_TEAM_BADGUYS)
				table.insert(chasingCreeps, creep1)
				local creep2 = CreateUnitByName("creep_for_fun_radiant", forFunCreepSpawnPosBottom + Vector(120,0,0), false, nil, nil, DOTA_TEAM_BADGUYS)
				table.insert(chasingCreeps, creep2)
				local creep3 = CreateUnitByName("creep_for_fun_radiant", forFunCreepSpawnPosBottom + Vector(0,0,0), false, nil, nil, DOTA_TEAM_BADGUYS)
				table.insert(chasingCreeps, creep3)
				local creep4 = CreateUnitByName("creep_for_fun_dire", forFunCreepSpawnPosBottom + Vector(0, 300, 0) + Vector(0,0,0), false, nil, nil, DOTA_TEAM_BADGUYS)
				table.insert(chasingCreeps, creep4)
				Timers:CreateTimer(1, function()
					for _, creep in pairs(chasingCreeps) do
						hideCreep(creep)
						creep:MoveToPosition(forFunCreepSpawnPosTop)
					end
				end)
			end

			Timers:CreateTimer(20, function()
				-- remove them after 20 seconds
				for _, creep in pairs(chasingCreeps) do
					creep:ForceKill(false)
				end
			end)

			lastChaseTime = now
		end
	end,
	OnPreRoundStart = function(round)
		print("RoundScript -> OnPreRoundStart")

		local i = 1
		for k,v in pairs(Frostivus.state.stages["tusk"].crates) do
			local item = Frostivus.StagesKVs["tusk"].Initial[tostring(i)]
			Frostivus:L(item)
			if item then
				v:InitBench(1)
				v:SetCrateItem(item)
			else

			end
			i = i + 1
		end

		GameRules.__flLastTuskKickTime_Left = GameRules:GetGameTime() - 100
		GameRules.__flLastTuskKickTime_Right = GameRules:GetGameTime() - 100
		GameRules.__vTuskKickAreaUnitsLeft__ = GameRules.__vTuskKickAreaUnitsLeft__ or {}
		GameRules.__vTuskKickAreaUnitsRight__ = GameRules.__vTuskKickAreaUnitsRight__ or {}
		if GameRules.__vTuskLeftTimer == nil then
			GameRules.__vTuskLeftTimer = true

			local tusk = Entities:FindByName(nil, "tusk_left")
			tusk:AddNewModifier(tuskModelLeft, nil, "modifier_hide_health_bar", {})
			tusk:AddNewModifier(tuskModelLeft, nil, "modifier_unselectable", {})
			tusk:AddNewModifier(tuskModelLeft, nil, "modifier_invulnerable", {})

			Timers:CreateTimer(function()
				local now = GameRules:GetGameTime()
				if now - GameRules.__flLastTuskKickTime_Left >= flKickInterval then
					if not tusk:HasModifier("modifier_kick_indicator") then
						tusk:AddNewModifier(tusk, nil, "modifier_kick_indicator", {})
					end
				end

				if tusk:HasModifier("modifier_kick_indicator") and table.count(GameRules.__vTuskKickAreaUnitsLeft__) > 0 then
					local target
					for v in pairs(GameRules.__vTuskKickAreaUnitsLeft__) do
						target = v
					end
					tusk:RemoveModifierByName("modifier_kick_indicator")
					tusk:ForcePlayActivityOnce(ACT_DOTA_CAST_ABILITY_5)

					if target:HasModifier("modifier_frostivus_boost") then
						target:RemoveModifierByName("modifier_frostivus_boost")
					end

					Timers:CreateTimer(0.2, function()
						target:AddNewModifier(target, nil, "modifier_tusk_kick", {Direction = "right"})
					end)
					EmitAnnouncerSound("announcer_dlc_tusk_tusk_ann_evil_greevils_appear_05")
					GameRules.__flLastTuskKickTime_Left = now
				end
				return 0.03
			end)
		end

		if GameRules.__vTuskRightTimer == nil then
			GameRules.__vTuskRightTimer = true

			local tusk = Entities:FindByName(nil, "tusk_right")
			tusk:AddNewModifier(tuskModelLeft, nil, "modifier_hide_health_bar", {})
			tusk:AddNewModifier(tuskModelLeft, nil, "modifier_unselectable", {})
			tusk:AddNewModifier(tuskModelLeft, nil, "modifier_invulnerable", {})

			Timers:CreateTimer(function()
				local now = GameRules:GetGameTime()
				if now - GameRules.__flLastTuskKickTime_Right >= flKickInterval then
					if not tusk:HasModifier("modifier_kick_indicator") then
						tusk:AddNewModifier(tusk, nil, "modifier_kick_indicator", {})
					end
				end

				if tusk:HasModifier("modifier_kick_indicator") and table.count(GameRules.__vTuskKickAreaUnitsRight__) > 0 then
					local target
					for v in pairs(GameRules.__vTuskKickAreaUnitsRight__) do
						target = v
					end
					tusk:RemoveModifierByName("modifier_kick_indicator")
					tusk:ForcePlayActivityOnce(ACT_DOTA_CAST_ABILITY_5)

					if target:HasModifier("modifier_frostivus_boost") then
						target:RemoveModifierByName("modifier_frostivus_boost")
					end

					Timers:CreateTimer(0.2, function()
						target:AddNewModifier(target, nil, "modifier_tusk_kick", {Direction = "left"})
					end)
					EmitAnnouncerSound("announcer_dlc_tusk_tusk_ann_evil_greevils_appear_05")
					GameRules.__flLastTuskKickTime_Right = now
				end
				return 0.03
			end)
		end
	end,
	OnRoundStart = function(round)
		print("RoundScript -> OnRoundStart")
	end,
	OnRoundEnd = function(round)
		-- if you do something special, clean them
		print("RoundScript -> OnRoundEnd")
	end,
	OnOrderExpired = function(round, order)
		-- @param order, table
		-- keys:
		--    nTimeRemaining
		--    pszItemName the name of the recipe
		print("RoundScript -> OnOrderExpired")
	end,
}