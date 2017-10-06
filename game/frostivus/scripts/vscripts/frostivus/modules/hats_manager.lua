-- a file to respond to player's selection of color, hats (basic selection)
-- and particles ? I think we can make this to be a bonus for experienced/paid players
-- and body component? we have horns/ noses/ tails/ teeth and wings
-- and greevils have 8 material groups

if HatsManager == nil then HatsManager = class({}) end

local BODY_COMPONENTS = {
	ears = 
	{
		"models/courier/greevil/greevil_ears1.vmdl",
		"models/courier/greevil/greevil_ears2.vmdl",
	},
	feathers = {
		"models/courier/greevil/greevil_feathers.vmdl",
	},
	hairs = {
		"models/courier/greevil/greevil_hair1.vmdl",
		"models/courier/greevil/greevil_hair2.vmdl",
	},
	horns = {
		"models/courier/greevil/greevil_horns1.vmdl",
		"models/courier/greevil/greevil_horns2.vmdl",
		"models/courier/greevil/greevil_horns3.vmdl",
		"models/courier/greevil/greevil_horns4.vmdl",
	},
	noses = {	
		"models/courier/greevil/greevil_nose1.vmdl",
		"models/courier/greevil/greevil_nose2.vmdl",
		"models/courier/greevil/greevil_nose3.vmdl",
	},
	tails = {
		"models/courier/greevil/greevil_tail1.vmdl",
		"models/courier/greevil/greevil_tail2.vmdl",
		"models/courier/greevil/greevil_tail3.vmdl",
		"models/courier/greevil/greevil_tail4.vmdl",
	},
	teeths = {
		"models/courier/greevil/greevil_teeth1.vmdl",
		"models/courier/greevil/greevil_teeth2.vmdl",
		"models/courier/greevil/greevil_teeth3.vmdl",
		"models/courier/greevil/greevil_teeth4.vmdl",
	},
	wings = {
		"models/courier/greevil/greevil_wings1.vmdl",
		"models/courier/greevil/greevil_wings2.vmdl",
		"models/courier/greevil/greevil_wings3.vmdl",
		"models/courier/greevil/greevil_wings4.vmdl",
	}
}

function HatsManager:constructor()
	self.vPlayerHats = {}
	CustomGameEventManager:RegisterListener("player_select_hats", function(_, args) self:OnPlayerSelect(args) end)	
	ListenToGameEvent("npc_spawned",Dynamic_Wrap(HatsManager, "OnNPCSpawned"),self)
	print("HatsManager:constructor")
end

function HatsManager:OnPlayerSelect(args)
	local playerID = args.PlayerID

	local json = require 'dkjson'

	local materialGroup = args.MaterialGroup or tostring(RandomInt(0,8))
	local particles = json.decode(args.ParticlesJSON or '[]') -- maybe we should decode a json table to do this if we want multiple particles on one greevil
	local hat = args.HatID
	local bodyComponents = json.decode(args.BodyComponentsJSON or '[]') -- json string

	self.vPlayerHats[playerID] = {
		materialGroup = materialGroup,
		particles = particles,
		hat = hat,
		bodyComponents = bodyComponents,
	}
end

function HatsManager:OnNPCSpawned(args)

	print("Hats Manager -> NPC Spawned")

	local npc = EntIndexToHScript(args.entindex)

	if npc:IsHero() then -- also apply custom components to illusions
		-- if all body components will be remove upon death, we should recreate it
		-- 
		if not npc.bHatsManager_Created then
			npc.bHatsManager_Created = true
			local playerID = npc:GetPlayerID()

			local hats = self.vPlayerHats[playerID] or {}

			-- create hat
			if hats.hat ~= nil then
				self:AttachHat(npc, hats.hat)
			end

			-- set material group
			-- if not exist, just random it?
			if hats.materialGroup then
				npc:SetMaterialGroup(hats.materialGroup)
			else
				npc:SetMaterialGroup(tostring(RandomInt(0,8)))
			end

			-- add body components
			if hats.bodyComponents then
				for _, bodyComponent in pairs(hats.bodyComponents) do
					self:AttachBodyComponent(npc, bodyComponent)
				end
			end

			-- add eyes by default
			self:AttachBodyComponent(npc, "models/courier/greevil/greevil_eyes.vmdl")
		end
	end
end

function HatsManager:AttachHat(unit, hat)
	-- todo, hat!
	print("HatsManager:AttachHat - NOT IMPLEMENT YET")
end

function HatsManager:AttachBodyComponent(unit, modelPath)
	local comp = SpawnEntityFromTableSynchronous("prop_dynamic",{
		model = modelPath,
	})
	comp:FollowEntity(unit, true)
end

function HatsManager:AttachParticle(unit, pszParticleName, particleAttachType)
	-- todo, particle!
	print("HatsManager:AttachParticle - NOT IMPLEMENT YET")
end

if GameRules._CHatsManager == nil then GameRules._CHatsManager = HatsManager() end