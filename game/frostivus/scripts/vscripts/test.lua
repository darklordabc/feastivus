print("WARNING, TEST SCRIPT IS LOADING")

local hero = PlayerResource:GetPlayer(0):GetAssignedHero()

local comp = SpawnEntityFromTableSynchronous("prop_dynamic",{
	model = "models/courier/greevil/greevil_eyes.vmdl"
})

comp:FollowEntity(hero,true)

print("TEST SCRIPT FINISHED")