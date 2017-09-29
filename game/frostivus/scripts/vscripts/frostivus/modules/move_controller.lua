-- WASD movement controller
-- XavierCHN@2017.6
-- known bug:
--   1. if any other panorama panel got focus, player will need to click on a blank position to make keyboard input to be captured by panorama
-- Changelog:


if MoveController == nil then MoveController = class({}) end

local UP_VECTOR = Vector(0, 1, 0)
local DOWN_VECTOR = Vector(0, -1, 0)
local LEFT_VECTOR = Vector(-1, 0, 0)
local RIGHT_VECTOR = Vector(1, 0, 0)

-- I assume that max movespeed is 522
-- @todo
local MAX_MOVE_SPEED = 522

function MoveController:constructor()

	if IsInToolsMode() then
		print("Loading WASD move controller")
	end

	CustomGameEventManager:RegisterListener("pkd", function(_, args)
        self:OnPlayerKeyDown(args)
    end)
    CustomGameEventManager:RegisterListener("pku", function(_, args)
        self:OnPlayerKeyUp(args)
    end)

    CustomGameEventManager:RegisterListener("player_set_controller", function(_, args)
        self:OnPlayerSetController(args)
    end)
end

function MoveController:OnPlayerSetController(args)
	local player = PlayerResource:GetPlayer(args.PlayerID)
	if not player then return end
	local hero = player:GetAssignedHero()
	if not hero then return end

	if args.option == "keyboard" then
		hero.bUseKeyboardMoveController = true
	else
		-- mouse by default
		hero.bUseKeyboardMoveController = false
	end
end

function MoveController:OnPlayerKeyDown(args)
	local player = PlayerResource:GetPlayer(args.PlayerID)
	if not player then return end
	local hero = player:GetAssignedHero()
	if not hero then return end
	if not (IsValidEntity(hero) and hero:IsAlive()) then
		-- @todo show error to tell player cannot move?
		return
	end

	if not hero.m_MoveController_MoveTimer then
		hero.m_MoveController_MoveTimer = true
		self:CreateHeroMoveTimer(hero)
	end

	local keyCode = args.c
	if keyCode == "W" then
		hero.bMoveController_MovingUp = true
	elseif keyCode == "A" then
		hero.bMoveController_MovingLeft = true
	elseif keyCode == "S" then
		hero.bMoveController_MovingDown = true
	elseif keyCode == "D" then
		hero.bMoveController_MovingRight = true
	end

	-- @todo
	-- implement ctrl and space actions
	if keyCode == "ctrl" then
		print("NOT IMPLEMENT YET")
	end

	if keyCode == "space" then
		print("NOT IMPLEMENT YET")
	end
end

function MoveController:OnPlayerKeyUp(args)
	local player = PlayerResource:GetPlayer(args.PlayerID)
	if not player then return end
	local hero = player:GetAssignedHero()
	if not hero then return end
	if not (IsValidEntity(hero) and hero:IsAlive()) then
		-- @todo show error to tell player cannot move?
		return
	end

	if not hero.m_MoveController_MoveTimer then
		hero.m_MoveController_MoveTimer = true
		self:CreateHeroMoveTimer(hero)
	end

	local keyCode = args.c
	if keyCode == "W" then
		hero.bMoveController_MovingUp = false
	elseif keyCode == "A" then
		hero.bMoveController_MovingLeft = false
	elseif keyCode == "S" then
		hero.bMoveController_MovingDown = false
	elseif keyCode == "D" then
		hero.bMoveController_MovingRight = false
	end
end

function MoveController:CreateHeroMoveTimer(hero)
	hero:SetContextThink(DoUniqueString("hero_move_timer"),function()

		-- if player is not using keyboard controller
		if not hero.bUseKeyboardMoveController then
			return 0.03 -- keep running in case of player change his mind
		end

		if not (IsValidEntity(hero) and hero:IsAlive()) then 
			-- clear move state
			hero.bMoveController_MovingUp = false
			hero.bMoveController_MovingDown = false
			hero.bMoveController_MovingLeft = false
			hero.bMoveController_MovingRight = false
			return 0.03 
		end

		local moveVector = Vector(0,0,0)

		-- this is an 8 direction move
		-- if we want only 4 directions, use
		-- moveVector = UP_VECTOR instead
		if hero.bMoveController_MovingUp then
			moveVector = moveVector + UP_VECTOR
		end
		if hero.bMoveController_MovingDown then
			moveVector = moveVector + DOWN_VECTOR
		end
		if hero.bMoveController_MovingLeft then
			moveVector = moveVector + LEFT_VECTOR
		end
		if hero.bMoveController_MovingRight then
			moveVector = moveVector + RIGHT_VECTOR
		end

		moveVector = moveVector:Normalized()

		if not (moveVector.x == 0 and moveVector.y == 0) then
			-- set the direction
			hero:SetForwardVector(moveVector)
			-- order hero to move towards the direction
			-- draw the direction and target spot in tools mode
			local targetPos = hero:GetOrigin() + moveVector * MAX_MOVE_SPEED * 1.1 * 0.03
			if IsInToolsMode() then
				DebugDrawLine(hero:GetOrigin(),hero:GetOrigin() + moveVector * 256,255,255,255,false,0.03)
				DebugDrawCircle(targetPos,Vector(255,0,0),255,64,false,0.03)
			end
			hero:MoveToPosition(targetPos)
		else
			-- stop
			hero:Stop()
		end

		return 0.03
	end,0)
end

if GameRules._CMoveController == nil then GameRules._CMoveController = MoveController() end