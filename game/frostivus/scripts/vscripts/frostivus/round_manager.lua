_G.SCORE_PER_FINISHED_ORDER = 100
_G.g_DEFAULT_ORDER_TIME_LIMIT = 80
local ORDER_EXPIRE_COUNT_TO_FAIL = 3 -- after n of orders expired, round will restart or game failed
local TRY_AGAIN_SCREEN_TIME = 3
local RETRY_COUNT_TO_LOSE = 2

GameRules.vRoundDefinations = LoadKeyValues('scripts/kv/rounds.kv')
for level, data in pairs(GameRules.vRoundDefinations) do
	GameRules.vRoundDefinations[tonumber(level)] = data
end

LinkLuaModifier("modifier_teleport_to_new_round","frostivus/modifiers/modifier_teleport_to_new_round.lua",LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------
-- GLOBAL API
--=====================================================================================
-- g_TryServe(itemEntity) trying to serve an item, return true if it's a valid serve
-- this is a function for functions such as trying to put something on the serve window
-- do nothing real but validation
-- @param itemEntity CDOTA_Item
--=====================================================================================
function g_TryServe(itemEntity)
	local roundManager = GameRules.RoundManager
	local round = roundManager:GetCurrentRound()
	if round then
		return round:TryServe(itemEntity)
	end
end
GameRules.TryServe = g_TryServe
--=====================================================================================
-- g_Serve(itemEntity) trying to serve some item and make a progress
-- this function will remove the itemEntity and its container(if exists)
-- @param itemEntity CDOTA_Item
--=====================================================================================
function g_Serve(itemEntity, user)
	local round = g_GetCurrentRound()
	if round then
		local success = round:OnServe(itemEntity, user)
		return success
	end
end
GameRules.Serve = g_Serve
--=====================================================================================
-- g_GetCurrentOrders
--=====================================================================================
function g_GetCurrentOrders()
	if GameRules.RoundManager and GameRules.RoundManager:GetCurrentRound() then
		return GameRules.RoundManager:GetCurrentRound().vCurrentOrders
	end
end
--=====================================================================================
-- g_GetCurrentRound
--    return current Round instance
--=====================================================================================
function g_GetCurrentRound()
	return GameRules.RoundManager:GetCurrentRound()
end

--=====================================================================================
-- g_IsValidProduct
--    @param pszProductName string the product item name for validation
--=====================================================================================
function g_IsValidProduct(pszProductName)
	return g_GetCurrentRound() and g_GetCurrentRound():IsValidProduct(pszProductName) or false
end

--=====================================================================================
-- g_GetRoundTimeLeft
--    return round time left in seconds
--=====================================================================================
function g_GetRoundTimeLeft()
	local round = g_GetCurrentRound()
	if (round and round.nCountDownTimer) then
		return round.nCountDownTimer
	end
	return 0
end

--=====================================================================================
--=====================================================================================
-- the Round Class
--=====================================================================================
--=====================================================================================
if Round == nil then Round = class({}) end

LinkLuaModifier("modifier_preround_freeze","frostivus/modifiers/states.lua",LUA_MODIFIER_MOTION_NONE)

ROUND_STATE_PRE_ROUND = 1 -- ready, set go
ROUND_STATE_IN_PROGRESS = 2 -- playing
ROUND_STATE_POST_ROUND = 3 -- show score or round end
ROUND_STATE_PENDING_TRY_AGAIN = 4 -- try again appears

function Round:constructor(roundData)
	self.vRoundData = roundData
	self.bSecondChanceState = false
	self:Initialize()
end

function Round:Initialize()
	local roundData = self.vRoundData

	-- load round script
	self.vRoundScript =  {}
	if roundData.ScriptFile then
		self.vRoundScript = require(roundData.ScriptFile)
	end



	-- initialize orders
	self.vFinishedOrders = {}
	self.nExpiredOrders = 0
	self.vCurrentOrders = {}
	self:UpdateOrdersToClient() -- clear all orders of last round

	local maxOrderTime = 0
	self.vPendingOrders = {}
	for time, orderData in pairs(roundData.Orders) do
		local t = tonumber(time)
		self.vPendingOrders[t] = orderData
		if t > maxOrderTime then
			maxOrderTime = t
		end
	end

	-- initialize timers
	self.nTimeLimit = 60
	-- automatically generated round time limit according to the last order appear time
	if maxOrderTime > 0 then
		self.nTimeLimit = maxOrderTime + g_DEFAULT_ORDER_TIME_LIMIT
	end
	self.nCountDownTimer = self.nTimeLimit
	self.nPreRoundTime = roundData.nPreRoundTime or 4
	self.nPreRoundCountDownTimer = self.nPreRoundTime
	self.nEndRoundDelay = 10
	self.nExpiredTime = 0

	-- initialize score and 
	self.vRoundScore = 0
	
	-- call round script -> OnInitialize
	if self.vRoundScript.OnInitialize then
		self.vRoundScript.OnInitialize(self)
	end

	self:SetState(ROUND_STATE_PRE_ROUND)
end

function Round:Restart()
	GameRules.nRetryCount = GameRules.nRetryCount or 0
	GameRules.nRetryCount = GameRules.nRetryCount + 1
	self:Initialize()
end

function Round:GetState()
	return self.nCurrentState
end

function Round:SetState(newState)
	self:OnStateChanged(newState)
	self.nCurrentState = newState
end

function Round:OnStateChanged(newState)
	print("Round state changed to->", newState, ROUND_STATE_PRE_ROUND)
	--====================================================================================
	-- ON ENTERING PRE ROUND STATE
	--====================================================================================
	if newState == ROUND_STATE_PRE_ROUND then

		if self.vRoundScript.OnPreRoundStart then
			self.vRoundScript.OnPreRoundStart(self)
		end

		StopMainTheme()

		Frostivus:ResetStage(self:GetCameraTargetPosition())

		-- display round start message on clients
		CustomGameEventManager:Send_ServerToAllClients("round_start",{
			Level = level
		})
		CustomGameEventManager:Send_ServerToAllClients("set_round_name",{
			name = self.vRoundData.Name
		})

		Timers:CreateTimer(0, function()
			local teleportTargetName = self:GetStartPositionName() or 'level_' .. tostring(level) .. '_start'
			local teleport_target_entities = Entities:FindAllByName(teleportTargetName)
			local lastTeleportTarget = nil
			LoopOverHeroes(function(hero)
				print("add freeeze state to heroes")
				if not IsValidAlive(hero) then return 0.03 end
				if hero.__bPlayingTutorial then return end

				-- set camera target
				hero:AddNewModifier(hero,nil,"modifier_preround_freeze",{})
				hero:SetCameraTargetPosition(self:GetCameraTargetPosition())

				-- players in tutorial should not be effected

				EndAnimation(hero)
				RemoveAnimationTranslate(hero)
				AddAnimationTranslate(hero, "level_3")
				if Frostivus:IsCarryingItem( hero ) then
					if IsValidEntity(Frostivus:GetCarryingItem( hero )) then
						Frostivus:GetCarryingItem( hero ):RemoveSelf()
					end
					Frostivus:DropItem( hero )
				end
				hero:RemoveModifierByName("modifier_bench_interaction")
				hero:Stop()

				print("trying to teleport heroes to ->", teleportTargetName)

				-- teleport players to new round
				local teleportTarget
				if table.count(teleport_target_entities) > 0 then
					teleportTarget = table.remove(teleport_target_entities)
					teleportTarget = teleportTarget:GetOrigin()
				end

				if teleportTarget == nil then
					-- print("Not enough level start position entity!! moving hero to last teleport target pos")
					if lastTeleportTarget == nil then
						print("Not any level start entity found!! go check the map file for teleport entity ->", self:GetStartPositionName() or 'level_' .. tostring(level) .. '_start')
					else
						teleportTarget = lastTeleportTarget
					end
				else
					lastTeleportTarget = teleportTarget
				end

				FindClearSpaceForUnit(hero,teleportTarget or hero:GetOrigin(),true)

				-- remove teleporting effect
				hero:RemoveModifierByName('modifier_teleport_to_new_round')
			end)
		end)

		-- on pre round start, show initial recipes
		if self.vPendingOrders[0] then
			local orders = self.vPendingOrders[0]
			for recipeName, orderCount in pairs(orders) do
				for i = 1, orderCount do
					table.insert(self.vCurrentOrders, {
						nTimeRemaining = g_DEFAULT_ORDER_TIME_LIMIT,
						pszItemName = recipeName,
						pszID = DoUniqueString("order"),
						nTimeLimit = g_DEFAULT_ORDER_TIME_LIMIT,
						bComingSoon = true,
						nStartTime = 0
					})
				end
			end
			self.vPendingOrders[0] = nil
			self:UpdateOrdersToClient()
		end
	--====================================================================================
	-- ON ENTERING PLAYING STATE
	--====================================================================================
	elseif newState == ROUND_STATE_IN_PROGRESS then
		LoopOverHeroes(function(hero)
			hero:RemoveModifierByName("modifier_preround_freeze")
		end)

		StartMainThemeAtPosition(self:GetCameraTargetPosition(), self)

		if self.vRoundScript.OnRoundStart then
			self.vRoundScript.OnRoundStart(self)
		end

	--====================================================================================
	-- ON ROUND ENDS
	--====================================================================================
	elseif newState == ROUND_STATE_POST_ROUND then
		-- calculate stars
		local stars = 0
		-- local starCriterias = self.vRoundData.StarCriteria
		-- if starCriterias then
		-- 	for _, criteria in pairs(starCriterias) do
		-- 		if criteria.Type == 'STAR_CRITERIA_FINISHED_RECIPES' then
		-- 			local values = string.split(criteria.values, ' ')
		-- 			for index, value in pairs(values) do
		-- 				if table.count(self.vFinishedOrders) >= tonumber(value) then
		-- 					stars = index
		-- 				end
		-- 			end
		-- 		end
		-- 		-- @todo other criterias
		-- 	end
		-- end

		-- If you complete the round with no failed orders, you get 3 stars
		-- , if you fail 1 order, 2 stars, fail 2 orders, 1 star, if you fail 3, 
		-- you have to restart the round and never make it to score screen.

		local totalFailedOrdersCount = self.nExpiredOrders + table.count(self.vPendingOrders) -- table.count(pendingOrders) should always return 0, write it here just in case
		if totalFailedOrdersCount <= 0 then
			stars = 3
		elseif totalFailedOrdersCount == 1 then
			stars = 2
		elseif totalFailedOrdersCount == 2 then
			stars = 1
		end


		-- tell client to show round end summary
		local nScoreOrdersDelivered = table.count(self.vFinishedOrders) * SCORE_PER_FINISHED_ORDER

		-- #155 https://github.com/darklordabc/feastivus/issues/155
		-- change score bonus to round time left
		local scoreSpeedBonus = 0
		if self.nCountDownTimer > 0 then
			scoreSpeedBonus = self.nCountDownTimer
		end
		self.vRoundScore = scoreSpeedBonus + self.vRoundScore

		CustomGameEventManager:Send_ServerToAllClients('show_round_end_summary',{
			Stars = stars,
			FinishedOrdersCount = table.count(self.vFinishedOrders),
			UnFinishedOrdersCount = table.count(self.vPendingOrders) + self.nExpiredOrders,
			ScoreOrdersDelivered = nScoreOrdersDelivered,
			ScoreSpeedBonus = scoreSpeedBonus,
			Level = g_RoundManager.nCurrentLevel,
		})

		-- send the score to server
		local player_json = {}
		LoopOverPlayers(function(player)
			table.insert(player_json, PlayerResource:GetSteamAccountID(player:GetPlayerID()))
		end)
		local json = require('utils.dkjson')
		player_json = json.encode(player_json)
		local req = CreateHTTPRequest("POST", "http://18.216.43.117:10010/SaveScore")
		req:SetHTTPRequestGetOrPostParameter("auth","BOV4k4oOWI!yPeWSXY*1eZOlB3pBW3!#")
		req:SetHTTPRequestGetOrPostParameter("player_json",player_json)
		req:SetHTTPRequestGetOrPostParameter("level",tostring(g_RoundManager.nCurrentLevel))
		req:SetHTTPRequestGetOrPostParameter("score",tostring(self.vRoundScore))
		req:Send(function(result)
			if result.StatusCode == 200 then
				-- server will return highscore of this level
				local highscore = json.decode(result.Body)
				print("highscore")
				PrintTable(highscore)
				CustomNetTables:SetTableValue("highscore", "highscore", highscore)
			end
		end)

		local pos = self:GetCameraTargetPosition()
		Timers:CreateTimer(5.0, function (  )
			Frostivus:ClearStage( pos )
		end)

		if not g_RoundManager:HasNextRound() then
			LoopOverHeroes(function(v)
				StartAnimation(v, {duration=-1, activity=ACT_DOTA_GREEVIL_CAST, rate=1.0, translate="greevil_miniboss_red_overpower"})
				ParticleManager:CreateParticle("particles/econ/events/ti6/hero_levelup_ti6_godray.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
			end)

			Timers:CreateTimer(7, function (  )
				GameRules:SetGameWinner(2)
			end)
		else
			-- teleport particle
			Timers:CreateTimer(self.nEndRoundDelay - 2, function()
				LoopOverHeroes(function(v)
					v:AddNewModifier(v,nil,"modifier_teleport_to_new_round",{})
				end)
			end)

			-- tell the round manager to start a new round after delay
			Timers:CreateTimer(self.nEndRoundDelay, function()
				GameRules.RoundManager:StartNewRound()
			end)

			if self.vRoundScript.OnRoundEnd then
				self.vRoundScript.OnRoundEnd(self)
			end
		end
	end
end

function Round:OnTimer()
	--=========================================================================
	-- timer during pre-round
	--=========================================================================
	if self:GetState() == ROUND_STATE_PRE_ROUND then
		print("Timer -> pre round")
		self.nPreRoundCountDownTimer = self.nPreRoundCountDownTimer - 1

		if self.nPreRoundCountDownTimer > 0 then
			CustomGameEventManager:Send_ServerToAllClients("pre_round_countdown",{
				value = self.nPreRoundCountDownTimer
			})
		else
			self:SetState(ROUND_STATE_IN_PROGRESS)
		end
	--=========================================================================
	-- timer during round in progress
	--=========================================================================
	elseif self:GetState() == ROUND_STATE_IN_PROGRESS then
		self.nCountDownTimer = self.nCountDownTimer - 1
		self.nExpiredTime = self.nExpiredTime + 1

		-- free greevils
		LoopOverHeroes(function(hero)
			hero:RemoveModifierByName("modifier_preround_freeze")
		end)

		-- time for more orders
		for t, orders in pairs(self.vPendingOrders) do
			if tonumber(t) <= self.nExpiredTime then
				for recipeName, orderCount in pairs(orders) do
					for i = 1, orderCount do
						table.insert(self.vCurrentOrders, {
							nTimeRemaining = g_DEFAULT_ORDER_TIME_LIMIT,
							pszItemName = recipeName,
							pszID = DoUniqueString("order"),
							nTimeLimit = g_DEFAULT_ORDER_TIME_LIMIT,
							bComingSoon = false,
							nStartTime = t
						})
					end
				end
				self.vPendingOrders[t] = nil -- remove from pending orders
			end
		end

		-- #152, https://github.com/darklordabc/feastivus/issues/152
		-- if there are less than 3 orders, always add 'coming soon' orders
		if table.count(self.vCurrentOrders) < 3 and table.count(self.vPendingOrders) > 0 then
			-- find and add one order, the next order will be add in the next second loop
			-- so 3 orders will be added in 3 seconds rather than coming together
			local minTime = 9999
			local orders
			for t, o in pairs(self.vPendingOrders) do
				if t < minTime then
					orders = o
					minTime = t
				end
			end

			if orders then
				-- add one order to current orders
				local recipeName
				for name, count in pairs(orders) do
					recipeName = name
				end
				if orders[recipeName] then
					orders[recipeName] = tonumber(orders[recipeName]) - 1
					-- if this order dont have recipes < 1, remove it
					if orders[recipeName] <= 0 then
						orders[recipeName] = nil
					end
					-- if there are no more orders in this time, remove it
					if table.count(orders) <= 0 and self.vPendingOrders[minTime] then
						self.vPendingOrders[minTime] = nil
					end

					table.insert(self.vCurrentOrders, {
						nTimeRemaining = g_DEFAULT_ORDER_TIME_LIMIT,
						pszItemName = recipeName,
						pszID = DoUniqueString("order"),
						nTimeLimit = g_DEFAULT_ORDER_TIME_LIMIT,
						bComingSoon = true,
						nStartTime = minTime
					})
				end
			end
		end

		-- reduce all recipe time remaining, excluding 'coming soon orders'
		for k, order in pairs(self.vCurrentOrders) do
			-- if expired time > order start time, remove coming soon attribute
			if order.nStartTime and self.nExpiredTime > order.nStartTime then
				order.bComingSoon = false
			end
												-- coming soon orders will not reduce time remaining
			if order.pszFinishType == nil and not order.bComingSoon then 
				-- reduce unfinised orders only
				order.nTimeRemaining = order.nTimeRemaining - 1
			end

			-- if an order expired
			if order.nTimeRemaining <= 0 and not order.pszFinishType then
				self.nExpiredOrders = self.nExpiredOrders + 1
				order.pszFinishType = "Expired"
				Timers:CreateTimer(2, function()
					self.vCurrentOrders[k] = nil
				end)

				self:OnOrderExpired(order)
			end
		end

		-- time's up or there are no pending orders and no orders running
		-- this round is ended
		-- fixes #168 End clock as soong as last order is complete
		-- as soon as the last order complete, enter round end state
		local allCurrentOrderFinished = true
		for _, order in pairs(self.vCurrentOrders) do
			if order.pszFinishType ~= "Finished" then
				allCurrentOrderFinished = false
				break
			end
		end
		if self.nCountDownTimer <= 0 or (table.count(self.vPendingOrders) <= 0 and allCurrentOrderFinished) then
			self.nCountDownTime = 0
			self:SetState(ROUND_STATE_POST_ROUND)
		end

		self:UpdateOrdersToClient()
	end

	if self.vRoundScript.OnTimer then
		self.vRoundScript.OnTimer(self)
	end
	
	-- update ui timer
	CustomGameEventManager:Send_ServerToAllClients("round_timer",{
		value = self.nCountDownTimer
	})
end

function Round:OnOrderExpired(order)
	if self.vRoundScript.OnRecipeExpired then
		self.vRoundScript.OnRecipeExpired(self, order)
	end

	if self.nExpiredOrders >= ORDER_EXPIRE_COUNT_TO_FAIL then
		if GameRules.nRetryCount and GameRules.nRetryCount >= RETRY_COUNT_TO_LOSE then
			GameRules:SetGameWinner(3)
			LoopOverHeroes(function(v)
				StartAnimation(v, {duration=-1, activity=ACT_DOTA_DIE, rate=1.0, translate="black"})
			end)
		else
			LoopOverHeroes(function(v)
				StartAnimation(v, {duration=4, activity=ACT_DOTA_DISABLED, rate=1.0, translate="white"})
			end)

			self:SetState(ROUND_STATE_PENDING_TRY_AGAIN)
			CustomGameEventManager:Send_ServerToAllClients("frostivus_try_again", {})
			Timers:CreateTimer(TRY_AGAIN_SCREEN_TIME, function()
				self:Restart()
			end)
		end
	end
end

function Round:OnServe(itemEntity, user)
	-- the item entity should be CDOTA_Item, not a CDOTA_Item_Physical
	if not itemEntity.GetContainer then
		error(debug.traceback("The param 'itemEntity' should be an CDOTA_Item"))
	end

	if self:TryServe(itemEntity) then
		-- find the order with least time left
		local itemName = itemEntity:GetAbilityName()
		local orderIndex, theOrder = nil, nil
		local lowestTime = 999
		local pszID

		for k, order in pairs(self.vCurrentOrders) do
			if order.pszItemName == itemName and order.nTimeRemaining < lowestTime and order.pszFinishType == nil then
				orderIndex = k
				theOrder = order
				lowestTime = order.nTimeRemaining
				pszID = order.pszID
			end
		end

		table.insert(self.vFinishedOrders, {pszItemName = itemName, nFinishTime = self.nCountDownTimer})

		-- tell client to show order finished message
		self.vCurrentOrders[orderIndex].pszFinishType = "Finished"
		self:UpdateOrdersToClient()

		-- remove order after a short delay
		Timers:CreateTimer(2, function()
			self.vCurrentOrders[orderIndex] = nil
		end)

		-- add score
		self.vRoundScore = self.vRoundScore or 0
		self.vRoundScore = self.vRoundScore + 100 -- score for finishing an order

		-- #155, we dont use order time remaining to calculate bonus score anymore
		-- local orderTimeRemaining = self.vCurrentOrders[orderIndex].nTimeRemaining
		-- if orderTimeRemaining >= 1 then
		-- 	-- add time bonus
		-- 	self.vRoundScore = self.vRoundScore + math.floor(orderTimeRemaining)
		-- end

		self:UpdateScoreToClient()

		local itemPhysical = itemEntity:GetContainer()
		if itemPhysical then
			UTIL_Remove(itemPhysical)
		end

		-- trigger event
		GameRules.FrostivusEventListener:Trigger("frostivus_serve", {
			Unit = user
		})

		return true
	end
end

function Round:TryServe(itemEntity)
	-- the item entity should be CDOTA_Item, not a CDOTA_Item_Physical
	if not itemEntity.GetContainer then
		error(debug.traceback("The param 'itemEntity' should be an CDOTA_Item"))
	end

	local itemName = itemEntity:GetAbilityName()
	for _, order in pairs(self.vCurrentOrders) do
		if order.pszItemName == itemName then
			return true
		end
	end

	return false
end

function Round:UpdateOrdersToClient()
	CustomNetTables:SetTableValue("orders","orders",self.vCurrentOrders)
end

function Round:UpdateScoreToClient()
	CustomNetTables:SetTableValue("score","score_" ..  g_RoundManager.nCurrentLevel,{value=self.vRoundScore})
end

function Round:_Debug_SetRoundTime(time)
	self.nCountDownTimer = time
end

function Round:GetCurrentOrders()
	return self.vCurrentOrders
end

function Round:IsValidProduct(pszProductName)
	for _, order in pairs(self.vCurrentOrders) do
		if order.pszItemName == pszProductName then
			return true
		end
	end
end

function Round:GetCameraTargetPosition()
	return self.vRoundScript.CameraTargetPosition or Vector(0,0,0)
end

function Round:GetStartPositionName()
	return self.vRoundData.StartPositionName or 'level_' .. tostring(level) .. '_start'
end

--=====================================================================================
--=====================================================================================
-- RoundManager
--=====================================================================================
--=====================================================================================
if RoundManager == nil then RoundManager = class({}) end

function RoundManager:constructor()
	self.nCurrentLevel = 0
	ListenToGameEvent("game_rules_state_change",Dynamic_Wrap(RoundManager, "OnGameRulesStateChanged"),self)
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("round_timer"),function()
		if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
			return nil
		end
		if not GameRules:IsGamePaused() then
			self:OnTimer()
		end
		-- if the extra greevil is created, the timer is slower
		if GameRules.__bExtraGreevilCreated__ and self.vCurrentRound and self.vCurrentRound:GetState() == ROUND_STATE_IN_PROGRESS then
			return 1.3 -- change this value to rescale
		end
		return 1
	end,1)
end

function RoundManager:OnGameRulesStateChanged()
	-- init round manager when pre game
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_PRE_GAME then
		Timers:CreateTimer(0.5, function()
			if GameRules.nPlayerFinishedTutorialCount >= 1 then
				GameRules.bMainRoundStarted = true
				self:StartNewRound()
			end
		end)
	end
end

function RoundManager:HasNextRound()
	return GameRules.vRoundDefinations[self.nCurrentLevel + 1] ~= nil
end

function RoundManager:StartNewRound(level) -- level is passed for test purpose
	level = level or self.nCurrentLevel + 1
	self.nCurrentLevel = level

	local roundData = GameRules.vRoundDefinations[level]

	-- tell players in tutorial that main round have started
	GameRules.bMainRoundStarted = true

	-- instantiation round
	self.vCurrentRound = Round(roundData)
end

function RoundManager:OnTimer()
	-- this function called every second
	if self.vCurrentRound then
		self.vCurrentRound:OnTimer()
	end
end

function RoundManager:GetCurrentRound()
	return self.vCurrentRound
end

if GameRules.RoundManager == nil then GameRules.RoundManager = RoundManager() end

g_RoundManager = GameRules.RoundManager
