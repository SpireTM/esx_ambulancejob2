Config                            = {}

Config.DrawDistance               = 1.0
Config.MarkerColor                = { r = 255, g = 0, b = 255 }
Config.MarkerSize                 = { x = 2.5, y = 2.5, z = 1.0 }
Config.ReviveReward               = 250  -- revive reward, set to 0 if you don't want it enabled
Config.AntiCombatLog              = true -- enable anti-combat logging?
Config.LoadIpl                    = false -- disable if you're using fivem-ipl or other IPL loaders
Config.Locale                     = 'fi'

local second = 1000
local minute = 60 * second

-- How much time before auto respawn at hospital
Config.RespawnDelayAfterRPDeath   = 30 * minute
-- joku vitun nopeutettu sairaalaan pääsy paska 

Config.RespawnToHospitalMenuTimer   = true
Config.MenuRespawnToHospitalDelay   = 12 * minute


Config.EnablePlayerManagement       = true
Config.EnableSocietyOwnedVehicles   = false

Config.RemoveWeaponsAfterRPDeath    = true
Config.RemoveCashAfterRPDeath       = true
Config.RemoveItemsAfterRPDeath      = true

-- Will display a timer that shows RespawnDelayAfterRPDeath as a countdown
Config.ShowDeathTimer               = true

-- Will allow respawn after half of RespawnDelayAfterRPDeath has elapsed.
Config.EarlyRespawn                 = false
-- The player will be fined for respawning early (on bank account)
Config.EarlyRespawnFine                  = false
Config.EarlyRespawnFineAmount            = 500

Config.Blip = {
	Pos     = { x = -809.4229, y = -1233.885, z = 7.3374285 },
	Sprite  = 61,
	Display = 4,
	Scale   = 0.6,
	Colour  = 59,
}

Config.HelicopterSpawner = {
	SpawnPoint = { x = 351.78738, y = -588.7415, z = 73.161781 },
	Heading    = 0.0
}

-- https://wiki.fivem.net/wiki/Vehicles
Config.AuthorizedVehicles = {
	{
		model = 'ambulance',
		label = 'Ambulance'
	},
}

Config.Zones = {

	Kopterinotto = { -- Kopterin otto
		Pos	= { x = -862.6023, y = -1227.538, z = 149.41149 },
		Type = 1
	},	
	
	Mihinspawnaat = { -- tänne kuolleet spawnaa
	    Pos	= { x = -2022.846, y = -254.999, z = 23.421 },
		Type = 1
	},
	
	--AmbulanceActions = { -- Varasto
	--	Pos	= { x = -819.9445, y = -1242.581, z = 6.3374257 },
	--	Type = 1
	--},
	
	AmbulanceActions = { -- Boss menu
	Pos	= { x = -819.9445, y = -1242.581, z = 6.3374257 },
	Type = 1
	},

	VehicleSpawner = {
		Pos	= { x = -825.9926, y = -1227.373, z = 5.9341197 },
		Type = 1
	},

	VehicleSpawnPoint = {
		Pos	= { x = -840.346, y = -1231.14, z = 5.9339318 },
		Type = -1
	},

	VehicleDeleter = {
		Pos	= { x = -840.346, y = -1231.14, z = 5.9339318 },
		Type = 1
	},
	--Helikopteri
	VehicleDeleter2 = {
		Pos	=  { x = 351.725, y = -587.728, z = 74.50 },
		Type = 1
	},

-------------
--Keskimaa--

	VehicleSpawner2 = {
		Pos	= { x = 1825.96, y = 3690.08, z = 34.22 },
		Type = 1
	},

	VehicleSpawnPoint2 = {
		Pos	= { x = 1831.60, y = 3696.16, z = 33.22 },
		Type = -1
	},

	VehicleDeleter3 = {
		Pos	=  { x = 1818.87, y = 3688.90, z = 33.22 },
		Type = 1
	},

	AmbulanceActions5 = { -- Varasto
		Pos	= { x = 1823.65, y = 3687.02, z = 34.27 },
		Type = 1
	},

-------------
--Paleto--

	AmbulanceActions4 = { -- Varasto
		Pos	= { x = -251.57, y = 6322.89, z = 32.44 },
		Type = 1
	},

	VehicleSpawner3 = {
		Pos	= { x = -249.27, y = 6330.55, z = 32.43 },
		Type = 1
	},

	VehicleSpawnPoint3 = {
		Pos	= { x = -239.093, y = 6333.785, z = 32.207 },
		Type = -1
	},

	VehicleDeleter4 = {
		Pos	=  { x = -239.093, y = 6333.785, z = 32.207 },
		Type = 1
	}

}

Config.Hoito = {
	Check = vector3(-817.4868, -1236.78, 7.3374247)
}

--- Sänky hommeli--
Config.BedList = {
	{ heading = 156.9, objCoords = {x = 322.63, y = -587.04, z = 43.2} },
	{ heading = 156.9, objCoords = {x = 317.76, y = -585.09, z = 43.2} },
	{ heading = 156.9, objCoords = {x = 314.45, y = -584.06, z = 43.2} },
	{ heading = 156.9, objCoords = {x = 311.2, y = -582.99, z = 43.2} },
	{ heading = 156.9, objCoords = {x = 307.66, y = -581.88, z = 43.2} },

	{ heading = 341.2, objCoords = {x = 324.13, y = -582.75, z = 43.2} },
	{ heading = 341.2, objCoords = {x = 319.34, y = -581.32, z = 43.2} },
	{ heading = 341.2, objCoords = {x = 313.96, y = -579.28, z = 43.2} },
	{ heading = 341.2, objCoords = {x = 309.44, y = -577.27, z = 43.2} },
}