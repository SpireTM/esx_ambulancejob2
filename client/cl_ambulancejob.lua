local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData				= {}
local FirstSpawn				= true
local IsDead					= false
local HasAlreadyEnteredMarker	= false
local LastZone					= nil
local CurrentAction				= nil
local CurrentActionMsg			= ''
local CurrentActionData			= {}
local IsBusy					= false
local IsDragged                 = false
local CopPed                    = 1
local timerr = 0

ESX								= nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	Citizen.Wait(5000)
	PlayerData = ESX.GetPlayerData()
end)

function SetVehicleMaxMods(vehicle)
	local props = {
		modEngine       = 1,
		modBrakes       = 1,
		modTransmission = 1,
		modSuspension   = 1,
		modArmor		= 1,
		modTurbo        = true,
	}

	ESX.Game.SetVehicleProperties(vehicle, props)
end

local timer = 0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if timer ~= 0 then
            timer = timer - 1
        end
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60000)
		if timerr ~= 0 then
			timerr = timerr - 1
		end
	end
end)

function RespawnPed(ped, coords)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false)
	SetPlayerInvincible(ped, false)
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z, coords.heading)
	ClearPedBloodDamage(ped)

	ESX.UI.Menu.CloseAll()
end

local IsAnimated = false

RegisterNetEvent('esx_ambulancejob:heal2')
AddEventHandler('esx_ambulancejob:heal2', function()
	local maxHealth = GetEntityMaxHealth(PlayerPedId())
	SetEntityHealth(PlayerPedId(), maxHealth)
	TriggerEvent('esx_vuoto:lopetus')
end)

RegisterNetEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(_type)
	local ajastus = 0
	local playerPed = GetPlayerPed(-1)
	if not IsPedInAnyVehicle(playerPed,  false) then
		local maxHealth = GetEntityMaxHealth(playerPed)
		if _type == 'small' then
			if not IsAnimated then
				local prop_name = 'p_cs_script_bottle_s'
				IsAnimated = true
				local x,y,z = table.unpack(GetEntityCoords(playerPed))
				prop = CreateObject(GetHashKey(prop_name), x, y, z+0.2, true, true, true)
				AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.09, -0.09, -0.03, 90.0, 190.0, 200.0, true, true, false, true, 1, true)
				RequestAnimDict("amb@world_human_drinking@coffee@female@idle_a")
				while not HasAnimDictLoaded("amb@world_human_drinking@coffee@female@idle_a") do
					Citizen.Wait(0)
				end
				TaskPlayAnim(GetPlayerPed(-1), "amb@world_human_drinking@coffee@female@idle_a", "idle_a", 8.0, -8, -1, 55, 0, 0, 0, 0)
				for i=1, 99999 do
					Wait(5)
					ajastus = ajastus + 1
					if IsControlPressed(0, 73) then
						break
					end
					if ajastus == 500 then
						if not IsPedDeadOrDying(playerPed) then
							local health = GetEntityHealth(playerPed)
							local newHealth = math.min(maxHealth , math.floor(health + maxHealth/8))
							SetEntityHealth(playerPed, newHealth)
							ESX.ShowNotification(_U('healed'))
						end
						break
					end
				end
				IsAnimated = false
				StopAnimPlayback(GetPlayerPed(-1), 0, true)
				DeleteObject(prop)
			end
		elseif _type == 'big' then
			if not IsAnimated then
				local prop_name = 'prop_ld_health_pack'
				IsAnimated = true
				local x,y,z = table.unpack(GetEntityCoords(playerPed))
				prop = CreateObject(GetHashKey(prop_name), x, y, z+0.2, true, true, true)
				AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.09, 0.09, -0.03, 70.0, 90.0, 100.0, true, true, false, true, 1, true)
				RequestAnimDict("missarmenian3@franklin_driving")
				while not HasAnimDictLoaded("missarmenian3@franklin_driving") do
					Citizen.Wait(0)
				end
				TaskPlayAnim(GetPlayerPed(-1), "missarmenian3@franklin_driving", "steer_no_lean", 8.0, -8, -1, 63, 0, 0, 0, 0)
				for i=1, 99999 do
					Wait(5)
					ajastus = ajastus + 1
					DisableControlAction(0, 21, true)
					DisableControlAction(0, 22, true)
					if IsControlPressed(0, 73) then
						ClearPedTasks(PlayerPedId())
						break
					end
					if ajastus == 1500 then
						TriggerEvent('esx_vuoto:lopetus')
						if not IsPedDeadOrDying(playerPed) then
							SetEntityHealth(playerPed, maxHealth)
						end
						ESX.ShowNotification(_U('healed'))
						ClearPedTasks(playerPed)
						break
					end
				end
				IsAnimated = false
				DeleteObject(prop)
			end
		end
	else
		ESX.ShowNotification('Perkeleen perkele tässä vauhdissa ei pysty paikkaamaan haavoja')
	end
end)

function StartRespawnTimer()
	Citizen.SetTimeout(Config.RespawnDelayAfterRPDeath, function()
		if IsDead then
			RemoveItemsAfterRPDeath()
		end
	end)
end

function polar3DToWorld3D(entityPosition, radius, polarAngleDeg, azimuthAngleDeg)
	local polarAngleRad   = polarAngleDeg   * math.pi / 180.0
	local azimuthAngleRad = azimuthAngleDeg * math.pi / 180.0

	local pos = {
		x = entityPosition.x + radius * (math.sin(azimuthAngleRad) * math.cos(polarAngleRad)),
		y = entityPosition.y - radius * (math.sin(azimuthAngleRad) * math.sin(polarAngleRad)),
		z = entityPosition.z - radius * math.cos(azimuthAngleRad)
	}

	return pos
end

function ShowDeathTimer()
	local saamennasairaalaan = false
	local minuutitkertaakaksi = 6 --monta minuuttia että pääsee sairaalaan - 5 = 10
	local aloitustunti = GetClockHours()
	local kikulitimeri = -200
	local cam = nil
	local polarAngleDeg = 0
	local azimuthAngleDeg = 90

	SetPlayerInvincible(PlayerId(), true)
	SetPedCanBeTargetted(GetPlayerPed(-1), false)
	
	--PlayMissionCompleteAudio("GENERIC_FAILED")
	
	--SetFlash(1, 1, 0, 10000, 1000)

	if not DoesCamExist(cam) then
		cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
	end

	SetCamActive(cam, true)
	RenderScriptCams(true, false, 0, true, true)
	
	Citizen.CreateThread(function()
		while IsDead do
			Citizen.Wait(0)
			
			local xMagnitude = GetDisabledControlNormal(0, 1)
			local yMagnitude = GetDisabledControlNormal(0, 2)

			polarAngleDeg = polarAngleDeg + xMagnitude * 10

			if polarAngleDeg >= 360 then
				polarAngleDeg = 0
			end

			azimuthAngleDeg = azimuthAngleDeg + yMagnitude * 10

			if azimuthAngleDeg >= 360 then
				azimuthAngleDeg = 0
			end
			
			local radius = 5

			local camipositioni = GetEntityCoords(GetPlayerPed(-1))
			local nextCamLocation = polar3DToWorld3D(camipositioni, radius, polarAngleDeg, azimuthAngleDeg)

			SetCamCoord(cam,  nextCamLocation.x,  nextCamLocation.y,  nextCamLocation.z)
			PointCamAtEntity(cam,  GetPlayerPed(-1))
			
			if aloitustunti ~= GetClockHours() then
				aloitustunti = GetClockHours()
				minuutitkertaakaksi = minuutitkertaakaksi - 1
			end
			
			minutes = (minuutitkertaakaksi * 2)
			
			if GetClockMinutes() > 30 then
				minutes = minutes - 1
			end

			local UI = { 
				x =  0.000 ,
				y = -0.001 ,
			}
			
			SetTextFont(4)
			SetTextProportional(0)
			SetTextScale(0.0, 0.5)
			SetTextColour(255, 255, 255, 255)
			SetTextDropshadow(0, 0, 0, 0, 255)
			SetTextEdge(1, 0, 0, 0, 255)
			SetTextDropShadow()
			SetTextOutline()
			
			if minutes < 1 then
				saamennasairaalaan = true
			end

			local text = 'Olet tajuton! Pääset terveyskeskukseen '..minutes..' minuutin kuluttua.\n Välilyönti - Päivitä'
			
			if saamennasairaalaan then
				text = 'Paina E - päästäkseksi sairaalaan'
				if IsControlJustPressed(0, Keys['E']) then
					SetPedCanRagdoll(PlayerPedId(),true)
					VitunHienotSairaalanSiirtymisEfektit()
					break
				end
			end
			
			SetTextCentre(true)
			SetTextEntry("STRING")
			AddTextComponentString(text)
			DrawText(0.5, 0.8)

			kikulitimeri = kikulitimeri + 1
			if kikulitimeri == -1 then
				local coords = GetEntityCoords(GetPlayerPed(-1))
				NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, 0, true, false)
				SetEntityHealth(GetPlayerPed(-1), 0)
			end
			if IsControlJustReleased(0, 22) then
				if kikulitimeri > 6000 then
					local coords = GetEntityCoords(GetPlayerPed(-1))
					NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, 0, true, false)
					SetEntityHealth(GetPlayerPed(-1), 0)
					kikulitimeri = 0
					exports['mythic_notify']:DoHudText('inform', 'Ruumiisi on päivitetty muille pelaajille')
				else
                    if timer == 0 then
						exports['mythic_notify']:DoHudText('inform', 'Voit päivittää ruumiisi minuutin välein')
                    	timer = 5
					end
				end
			end
		end
		SetCamActive(cam, false)
		RenderScriptCams(false, false, 0, true, true)
	end)
end

function VitunHienotSairaalanSiirtymisEfektit()
    TriggerServerEvent('esx_ambulancejob:setDeathStatus', 0)

    Citizen.CreateThread(function()
        while not IsScreenFadedOut() do
            Citizen.Wait(10)
        end
        ESX.TriggerServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function()
            Wait(1000)
        end)

        ESX.SetPlayerData('lastPosition', Config.Zones.Mihinspawnaat.Pos)
        ESX.SetPlayerData('loadout', {})

        TriggerServerEvent('esx:updateLastPosition', Config.Zones.Mihinspawnaat.Pos)
        RespawnPed(GetPlayerPed(-1), Config.Zones.Mihinspawnaat.Pos)

        exports['mythic_notify']:DoHudText('inform', 'Heräsit juuri sairaalalta. ~r~Et muista mitään mikä johti tähän tilanteeseen!')
    end)
end

function PayFine()
	ESX.TriggerServerCallback('esx_ambulancejob:payFine', function()
	RemoveItemsAfterRPDeath()
	end)
end

function OnPlayerDeath()
	IsDead = true
	IsDragged = false
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', 1)
	ESX.UI.Menu.CloseAll()
	
	if Config.ShowDeathTimer == true then
		ShowDeathTimer()
	end

--	StartRespawnTimer() tämäpaskalaittaa randomitimerin

	ClearPedTasksImmediately(GetPlayerPed(-1))
end

function TeleportFadeEffect(entity, coords)

	Citizen.CreateThread(function()

		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end

		ESX.Game.Teleport(entity, coords, function()
		end)

	end)

end

function WarpPedInClosestVehicle(ped)

	local coords = GetEntityCoords(ped)

	local vehicle, distance = ESX.Game.GetClosestVehicle({
		x = coords.x,
		y = coords.y,
		z = coords.z
	})

	if distance ~= -1 and distance <= 5.0 then

		local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
		local freeSeat = nil

		for i=maxSeats - 1, 0, -1 do
			if IsVehicleSeatFree(vehicle, i) then
				freeSeat = i
				break
			end
		end

		if freeSeat ~= nil then
			TaskWarpPedIntoVehicle(ped, vehicle, freeSeat)
		end

	else
		ESX.ShowNotification(_U('no_vehicles'))
	end

end

function OpenAmbulanceActionsMenu()

	local elements = {
		{label = _U('otatavara'), value = 'otto'},
		{label = _U('laitatavara'), value = 'laitto'}
	}

	if Config.EnablePlayerManagement and PlayerData.job.grade_name == 'boss' then
		table.insert(elements, {label = _U('boss_actions'), value = 'boss_actions'})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'ambulance_actions',
		{
			title		= _U('ambulance'),
			align		= 'bottom-left',
			elements	= elements
		},
		function(data, menu)

			if data.current.value == 'boss_actions' then
				TriggerEvent('esx_society:openBossMenu', 'ambulance', function(data, menu)
					menu.close()
				end, {wash = false})
			end
						
			if data.current.value == 'otto' then
				OpenGetStocksMenu()
			end
			
			if data.current.value == 'laitto' then
				OpenPutStocksMenu()
			end

		end,
		function(data, menu)

			menu.close()

			CurrentAction		= 'ambulance_actions_menu'
			CurrentActionMsg	= _U('open_menu')
			CurrentActionData	= {}

		end
	)

end

function OpenMobileAmbulanceActionsMenu()

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
	'default', GetCurrentResourceName(), 'mobile_ambulance_actions',
	{
		title		= _U('ambulance'),
		align		= 'bottom-left',
		elements	= {
			{label = _U('ems_menu'), value = 'citizen_interaction'},
		}
	}, function(data, menu)
		if data.current.value == 'citizen_interaction' then
			ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'citizen_interaction',
			{
				title		= _U('ems_menu_title'),
				align		= 'bottom-left',
				elements	= {
					{label = _U('ems_menu_revive'), value = 'revive'},
					{label = _U('ems_menu_small'), value = 'small'},
					{label = _U('ems_menu_big'), value = 'big'},
					{label = _U('drag'), value = 'drag'},
					{label = _U('ems_menu_putincar'), value = 'put_in_vehicle'},
					{label = 'Pikakyyti teholle', value = 'npc_nosto'},
					{label = _U('billing'), value = 'billing'},
				}
			}, function(data, menu)
				if IsBusy then return end
				if data.current.value == 'revive' then -- revive

					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players'))
					else
						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(qtty)
							if qtty > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health == 0 then
									local playerPed = GetPlayerPed(-1)

									IsBusy = true
									ESX.ShowNotification(_U('revive_inprogress'))
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
									TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
									IsBusy = false

									-- Show revive award?
									if Config.ReviveReward > 0 then
										ESX.ShowNotification(_U('revive_complete_award', GetPlayerName(closestPlayer), Config.ReviveReward))
									else
										ESX.ShowNotification(_U('revive_complete', GetPlayerName(closestPlayer)))
									end
								else
									ESX.ShowNotification(_U('player_not_unconscious'))
								end
							else
								ESX.ShowNotification(_U('not_enough_medikit'))
							end
						end, 'medikit')
					end
				elseif data.current.value == 'small' then

					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players'))
					else
						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(qtty)
							if qtty > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health > 0 then
									local playerPed = GetPlayerPed(-1)

									IsBusy = true
									ESX.ShowNotification(_U('heal_inprogress'))
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('esx_ambulancejob:removeItem', 'bandage')
									TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'small')
									ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
									IsBusy = false
								else
									ESX.ShowNotification(_U('player_not_conscious'))
								end
							else
								ESX.ShowNotification(_U('not_enough_bandage'))
							end
						end, 'bandage')
					end
				elseif data.current.value == 'big' then

					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players'))
					else
						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(qtty)
							if qtty > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health > 0 then
									local playerPed = GetPlayerPed(-1)

									IsBusy = true
									ESX.ShowNotification(_U('heal_inprogress'))
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
									TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'big')
									ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
									IsBusy = false
								else
									ESX.ShowNotification(_U('player_not_conscious'))
								end
							else
								ESX.ShowNotification(_U('not_enough_medikit'))
							end
						end, 'medikit')
					end
				elseif data.current.value == 'put_in_vehicle' then

					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_vehicles'))
					else
						menu.close()
						WarpPedInClosestVehicle(GetPlayerPed(closestPlayer))
					end
				elseif data.current.value == 'npc_nosto' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players'))
					else
						menu.close()
						ESX.ShowNotification('Kaveri pääsee teholle pikakyytiä')
						TriggerServerEvent('esx_ambulancejob:nollaa', GetPlayerServerId(closestPlayer))
					end
				elseif data.current.value == 'drag' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
					ESX.ShowNotification(_U('no_players'))
					else
					TriggerServerEvent('esx_ambulancejob:drag', GetPlayerServerId(closestPlayer))
					end
				elseif data.current.value == 'billing' then
					TriggerEvent('vihko1')
					ESX.UI.Menu.Open(
					  'dialog', GetCurrentResourceName(), 'billing',
					  {
						title = _U('invoice_amount')
					  },
					  function(data, menu)
						local amount = tonumber(data.value)
						if amount == nil or amount < 0 then
						  ESX.ShowNotification(_U('amount_invalid'))
						else
						  
						  local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						  if closestPlayer == -1 or closestDistance > 3.0 then
							ESX.ShowNotification(_U('no_players'))
						  else
							menu.close()
							TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_ambulance', _U('mechanic'), amount)
							ESX.ShowNotification(_U('lahetetty'))
						  end
						end
					  end,
					function(data, menu)
					  menu.close()
					end
					)
				end					
			end, function(data, menu)
				menu.close()
			end)
		end

	end, function(data, menu)
		menu.close()
	end)
end

function OpenCloakroomMenu()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'cloakroom',
		{
			title		= _U('cloakroom'),
			align		= 'bottom-left',
			elements = {
				{label = _U('ems_clothes_civil'), value = 'citizen_wear'},
				{label = _U('ems_clothes_ems'), value = 'ambulance_wear'},
			},
		},
		function(data, menu)

			menu.close()

			if data.current.value == 'citizen_wear' then

				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)

			end

			if data.current.value == 'ambulance_wear' then

				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)

					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
					else
						TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
					end

				end)

			end

			CurrentAction		= 'ambulance_actions_menu'
			CurrentActionMsg	= _U('open_menu')
			CurrentActionData	= {}

		end,
		function(data, menu)
			menu.close()
		end
	)

end

function OpenVehicleSpawnerMenu()

	ESX.UI.Menu.CloseAll()

	if Config.EnableSocietyOwnedVehicles then

		local elements = {}

		ESX.TriggerServerCallback('esx_society:getVehiclesInGarage', function(vehicles)

			for i=1, #vehicles, 1 do
				table.insert(elements, {label = GetDisplayNameFromVehicleModel(vehicles[i].model) .. ' [' .. vehicles[i].plate .. ']', value = vehicles[i]})
			end

			ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'vehicle_spawner',
			{
				title		= _U('veh_menu'),
				align		= 'bottom-left',
				elements = elements,
			}, function(data, menu)
				menu.close()

				local vehicleProps = data.current.value
				ESX.Game.SpawnVehicle(vehicleProps.model, Config.Zones.VehicleSpawnPoint.Pos, 350.0, function(vehicle)
					ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
					local playerPed = GetPlayerPed(-1)
					TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				end)
				TriggerServerEvent('esx_society:removeVehicleFromGarage', 'ambulance', vehicleProps)

			end, function(data, menu)
				menu.close()
				CurrentAction		= 'vehicle_spawner_menu'
				CurrentActionMsg	= _U('veh_spawn')
				CurrentActionData	= {}
			end
			)
		end, 'ambulance')

	else -- not society vehicles

		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'vehicle_spawner',
		{
			title		= _U('veh_menu'),
			align		= 'bottom-left',
			elements	= Config.AuthorizedVehicles
		}, function(data, menu)
			menu.close()
			ESX.Game.SpawnVehicle(data.current.model, Config.Zones.VehicleSpawnPoint.Pos, 350.0, function(vehicle)
				SetVehicleDirtLevel(vehicle, 0)
				SetVehicleLivery(vehicle, 0)
				local playerPed = GetPlayerPed(-1)
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			end)
		end, function(data, menu)
			menu.close()
			CurrentAction		= 'vehicle_spawner_menu'
			CurrentActionMsg	= _U('veh_spawn')
			CurrentActionData	= {}
		end
		)
	end
end

function OpenPharmacyMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
	'default', GetCurrentResourceName(), 'pharmacy',
	{
		title		= _U('pharmacy_menu_title'),
		align		= 'bottom-left',
		elements = {
			{label = _U('pharmacy_take') .. ' ' .. _('medikit'), value = 'medikit'},
			{label = _U('pharmacy_take') .. ' ' .. _('bandage'), value = 'bandage'}
		},
	}, function(data, menu)
		TriggerServerEvent('esx_ambulancejob:giveItem', data.current.value)

	end, function(data, menu)
		menu.close()
		CurrentAction		= 'pharmacy'
		CurrentActionMsg	= _U('open_pharmacy')
		CurrentActionData	= {}
	end
	)
end

AddEventHandler('playerSpawned', function()
	IsDead = false
	IsDragged = false

	if FirstSpawn then
		TriggerServerEvent('esx_ambulancejob:firstSpawn')
		exports.spawnmanager:setAutoSpawn(false) -- disable respawn
		FirstSpawn = false
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)

	local specialContact = {
	name		= 'Ambulance',
	number		= 'ambulance',
	base64Icon	= 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAABp5JREFUWIW1l21sFNcVhp/58npn195de23Ha4Mh2EASSvk0CPVHmmCEI0RCTQMBKVVooxYoalBVCVokICWFVFVEFeKoUdNECkZQIlAoFGMhIkrBQGxHwhAcChjbeLcsYHvNfsx+zNz+MBDWNrYhzSvdP+e+c973XM2cc0dihFi9Yo6vSzN/63dqcwPZcnEwS9PDmYoE4IxZIj+ciBb2mteLwlZdfji+dXtNU2AkeaXhCGteLZ/X/IS64/RoR5mh9tFVAaMiAldKQUGiRzFp1wXJPj/YkxblbfFLT/tjq9/f1XD0sQyse2li7pdP5tYeLXXMMGUojAiWKeOodE1gqpmNfN2PFeoF00T2uLGKfZzTwhzqbaEmeYWAQ0K1oKIlfPb7t+7M37aruXvEBlYvnV7xz2ec/2jNs9kKooKNjlksiXhJfLqf1PXOIU9M8fmw/XgRu523eTNyhhu6xLjbSeOFC6EX3t3V9PmwBla9Vv7K7u85d3bpqlwVcvHn7B8iVX+IFQoNKdwfstuFtWoFvwp9zj5XL7nRlPXyudjS9z+u35tmuH/lu6dl7+vSVXmDUcpbX+skP65BxOOPJA4gjDicOM2PciejeTwcsYek1hyl6me5nhNnmwPXBhjYuGC699OpzoaAO0PbYJSy5vgt4idOPrJwf6QuX2FO0oOtqIgj9pDU5dCWrMlyvXf86xsGgHyPeLos83Brns1WFXLxxgVBorHpW4vfQ6KhkbUtCot6srns1TLPjNVr7+1J0PepVc92H/Eagkb7IsTWd4ZMaN+yCXv5zLRY9GQ9xuYtQz4nfreWGdH9dNlkfnGq5/kdO88ekwGan1B3mDJsdMxCqv5w2Iq0khLs48vSllrsG/Y5pfojNugzScnQXKBVA8hrX51ddHq0o6wwIlgS8Y7obZdUZVjOYLC6e3glWkBBVHC2RJ+w/qezCuT/2sV6Q5VYpowjvnf/iBJJqvpYBgBS+w6wVB5DLEOiTZHWy36nNheg0jUBs3PoJnMfyuOdAECqrZ3K7KcACGQp89RAtlysCphqZhPtRzYlcPx+ExklJUiq0le5omCfOGFAYn3qFKS/fZAWS7a3Y2wa+GJOEy4US+B3aaPUYJamj4oI5LA/jWQBt5HIK5+JfXzZsJVpXi/ac8+mxWIXWzAG4Wb4g/jscNMp63I4U5FcKaVvsNyFALokSA47Kx8PVk83OabCHZsiqwAKEpjmfUJIkoh/R+L9oTpjluhRkGSPG4A7EkS+Y3HZk0OXYpIVNy01P5yItnptDsvtIwr0SunqoVP1GG1taTHn1CloXm9aLBEIEDl/IS2W6rg+qIFEYR7+OJTesqJqYa95/VKBNOHLjDBZ8sDS2998a0Bs/F//gvu5Z9NivadOc/U3676pEsizBIN1jCYlhClL+ELJDrkobNUBfBZqQfMN305HAgnIeYi4OnYMh7q/AsAXSdXK+eH41sykxd+TV/AsXvR/MeARAttD9pSqF9nDNfSEoDQsb5O31zQFprcaV244JPY7bqG6Xd9K3C3ALgbfk3NzqNE6CdplZrVFL27eWR+UASb6479ULfhD5AzOlSuGFTE6OohebElbcb8fhxA4xEPUgdTK19hiNKCZgknB+Ep44E44d82cxqPPOKctCGXzTmsBXbV1j1S5XQhyHq6NvnABPylu46A7QmVLpP7w9pNz4IEb0YyOrnmjb8bjB129fDBRkDVj2ojFbYBnCHHb7HL+OC7KQXeEsmAiNrnTqLy3d3+s/bvlVmxpgffM1fyM5cfsPZLuK+YHnvHELl8eUlwV4BXim0r6QV+4gD9Nlnjbfg1vJGktbI5UbN/TcGmAAYDG84Gry/MLLl/zKouO2Xukq/YkCyuWYV5owTIGjhVFCPL6J7kLOTcH89ereF1r4qOsm3gjSevl85El1Z98cfhB3qBN9+dLp1fUTco+0OrVMnNjFuv0chYbBYT2HcBoa+8TALyWQOt/ImPHoFS9SI3WyRajgdt2mbJgIlbREplfveuLf/XXemjXX7v46ZxzPlfd8YlZ01My5MUEVdIY5rueYopw4fQHkbv7/rZkTw6JwjyalBCHur9iD9cI2mU0UzD3P9H6yZ1G5dt7Gwe96w07dl5fXj7vYqH2XsNovdTI6KMrlsAXhRyz7/C7FBO/DubdVq4nBLPaohcnBeMr3/2k4fhQ+Uc8995YPq2wMzNjww2X+vwNt1p00ynrd2yKDJAVN628sBX1hZIdxXdStU9G5W2bd9YHR5L3f/CNmJeY9G8WAAAAAElFTkSuQmCC'
	}

	TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)

end)

AddEventHandler('esx:onPlayerDeath', function(reason)
	OnPlayerDeath()
end)

RegisterNetEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)

	Citizen.CreateThread(function()

		local formattedCoords = {
			x = ESX.Math.Round(coords.x, 1),
			y = ESX.Math.Round(coords.y, 1),
			z = ESX.Math.Round(coords.z, 1)
		}

		ESX.SetPlayerData('lastPosition', formattedCoords)

		TriggerServerEvent('esx:updateLastPosition', formattedCoords)

		RespawnPed(playerPed, formattedCoords, 0.0)

		StopScreenEffect('DeathFailOut')
	end)
end)


AddEventHandler('esx_ambulancejob:hasEnteredMarker', function(zone)

	if zone == 'Sairaalansisaankaynti1' then
		TeleportFadeEffect(GetPlayerPed(-1), Config.Zones.Sairaalanuloskaynti1.Pos)
	end
	
	if zone == 'Sairaalansisaankaynti2' then
		TeleportFadeEffect(GetPlayerPed(-1), Config.Zones.Sairaalanuloskaynti1.Pos)
	end
	
	if zone == 'Sairaalanuloskaynti1' then
		TeleportFadeEffect(GetPlayerPed(-1), Config.Zones.Sairaalansisaankaynti1.Pos)
	end

	if zone == 'HospitalInteriorEntering1' then
		TeleportFadeEffect(GetPlayerPed(-1), Config.Zones.HospitalInteriorInside1.Pos)
	end

	if zone == 'HospitalInteriorExit1' then
		TeleportFadeEffect(GetPlayerPed(-1), Config.Zones.HospitalInteriorOutside1.Pos)
	end

	if zone == 'HospitalInteriorEntering2' then
		TeleportFadeEffect(GetPlayerPed(-1), Config.Zones.HospitalInteriorInside2.Pos)
	end
	
	if zone == 'Kopterinotto' then
	
		local heli = Config.HelicopterSpawner
	
		if not IsAnyVehicleNearPoint(heli.SpawnPoint.x, heli.SpawnPoint.y, heli.SpawnPoint.z, 3.0) and PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' then
			ESX.Game.SpawnVehicle('polmav', {
				x = heli.SpawnPoint.x,
				y = heli.SpawnPoint.y,
				z = heli.SpawnPoint.z
			}, heli.Heading, function(vehicle)
				SetVehicleModKit(vehicle, 0)
				SetVehicleLivery(vehicle, 1)
			end)
		end
	end

	if zone == 'HospitalInteriorExit2' then
		TeleportFadeEffect(GetPlayerPed(-1), Config.Zones.HospitalInteriorOutside2.Pos)
	end

	if zone == 'ParkingDoorGoOutInside' then
		TeleportFadeEffect(GetPlayerPed(-1), Config.Zones.ParkingDoorGoOutOutside.Pos)
	end

	if zone == 'ParkingDoorGoInOutside' then
		TeleportFadeEffect(GetPlayerPed(-1), Config.Zones.ParkingDoorGoInInside.Pos)
	end

	if zone == 'StairsGoTopBottom' then
		CurrentAction		= 'fast_travel_goto_top'
		CurrentActionMsg	= _U('fast_travel')
		CurrentActionData	= {pos = Config.Zones.StairsGoTopTop.Pos}
	end

	if zone == 'StairsGoBottomTop' then
		CurrentAction		= 'fast_travel_goto_bottom'
		CurrentActionMsg	= _U('fast_travel')
		CurrentActionData	= {pos = Config.Zones.StairsGoBottomBottom.Pos}
	end

	if zone == 'AmbulanceActions' then
		CurrentAction		= 'ambulance_actions_menu'
		CurrentActionMsg	= _U('open_menu')
		CurrentActionData	= {}
	end

	if zone == 'VehicleSpawner' then
		CurrentAction		= 'vehicle_spawner_menu'
		CurrentActionMsg	= _U('veh_spawn')
		CurrentActionData	= {}
	end

	if zone == 'Pharmacy' then
		CurrentAction		= 'pharmacy'
		CurrentActionMsg	= _U('open_pharmacy')
		CurrentActionData	= {}
	end

	if zone == 'VehicleDeleter' then

		local playerPed = GetPlayerPed(-1)
		local coords	= GetEntityCoords(playerPed)

		if IsPedInAnyVehicle(playerPed, false) then

			local vehicle, distance = ESX.Game.GetClosestVehicle({
				x = coords.x,
				y = coords.y,
				z = coords.z
			})

			if distance ~= -1 and distance <= 2.0 then

				CurrentAction		= 'delete_vehicle'
				CurrentActionMsg	= _U('store_veh')
				CurrentActionData	= {vehicle = vehicle}

		end
		end
	end

	if zone == 'VehicleDeleter2' then
		local playerPed = PlayerPedId()
		local coords	= GetEntityCoords(playerPed)

		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle, distance = ESX.Game.GetClosestVehicle({
				x = coords.x,
				y = coords.y,
				z = coords.z
			})

			if distance ~= -1 and distance <= 6.0 then
				CurrentAction		= 'delete_vehicle'
				CurrentActionMsg	= _U('store_veh')
				CurrentActionData	= {vehicle = vehicle}
			end
		end
	end
	
	if zone == 'Kerays' then
		CurrentAction		= 'kerays_menu'
		CurrentActionMsg	= _U('open_kerays_menu')
		CurrentActionData	= {}
	end

end)

function FastTravel(pos)
		TeleportFadeEffect(GetPlayerPed(-1), pos)
end

AddEventHandler('esx_ambulancejob:hasExitedMarker', function(zone)

	if zone == 'Pharmacy' then
		TriggerServerEvent('esx_ambulancejob:stopCraft')
		TriggerServerEvent('esx_ambulancejob:stopCraft2')
		TriggerServerEvent('esx_ambulancejob:stopCraft3')
	end
	
	if zone == 'Kerays' then
		TriggerServerEvent('esx_ambulancejob:stopHarvest')
		TriggerServerEvent('esx_ambulancejob:stopHarvest2')
		TriggerServerEvent('esx_ambulancejob:stopHarvest3')
	end
	
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
		
end)

-- Create blips
Citizen.CreateThread(function()

	local blip = AddBlipForCoord(Config.Blip.Pos.x, Config.Blip.Pos.y, Config.Blip.Pos.z)

	SetBlipSprite(blip, Config.Blip.Sprite)
	SetBlipDisplay(blip, Config.Blip.Display)
	SetBlipScale(blip, Config.Blip.Scale)
	SetBlipColour(blip, Config.Blip.Colour)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_U('hospital'))
	EndTextCommandSetBlipName(blip)

end)

--[[ Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local coords = GetEntityCoords(GetPlayerPed(-1))
		for k,v in pairs(Config.Zones) do
			if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				if PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
				elseif k ~= 'AmbulanceActions' and k ~= 'VehicleSpawner' and k ~= 'VehicleDeleter' and k ~= 'Pharmacy' and k ~= 'StairsGoTopBottom' and k ~= 'StairsGoBottomTop' then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)]]--

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)

		local coords		= GetEntityCoords(GetPlayerPed(-1))
		local isInMarker	= false
		local currentZone	= nil
		for k,v in pairs(Config.Zones) do
			if PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' then
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.MarkerSize.x) then
					isInMarker	= true
					currentZone = k
				end
			elseif k ~= 'AmbulanceActions' and k ~= 'VehicleSpawner' and k ~= 'VehicleDeleter' and k ~= 'VehicleDeleter2' and k ~= 'Pharmacy' and k ~= 'StairsGoTopBottom' and k ~= 'StairsGoBottomTop' then
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.MarkerSize.x) then
					isInMarker	= true
					currentZone = k
				end
			end
		end
		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			lastZone				= currentZone
			TriggerEvent('esx_ambulancejob:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_ambulancejob:hasExitedMarker', lastZone)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(4)

		if CurrentAction ~= nil then

			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlJustReleased(0, Keys['E']) and PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' then

				if CurrentAction == 'ambulance_actions_menu' then
					OpenAmbulanceActionsMenu()
				end

				if CurrentAction == 'vehicle_spawner_menu' then
					OpenVehicleSpawnerMenu()
				end

				if CurrentAction == 'pharmacy' then
					OpenMecanoCraftMenu()
				end
				
				if CurrentAction == 'kerays_menu' then
					OpenMecanoHarvestMenu()
				end

				if CurrentAction == 'fast_travel_goto_top' or CurrentAction == 'fast_travel_goto_bottom' then
					FastTravel(CurrentActionData.pos)
				end

				if CurrentAction == 'delete_vehicle' then
					if Config.EnableSocietyOwnedVehicles then
						local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
						TriggerServerEvent('esx_society:putVehicleInGarage', 'ambulance', vehicleProps)
					end
					ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
				end

				CurrentAction = nil

			end

		end

		if IsControlJustReleased(0, Keys['F6']) and PlayerData.job ~= nil and PlayerData.job.name == 'ambulance' and not IsDead then
			OpenMobileAmbulanceActionsMenu()
		end

	end
end)

RegisterNetEvent('esx_ambulancejob:requestDeath')
AddEventHandler('esx_ambulancejob:requestDeath', function()
	if Config.AntiCombatLog then
		Citizen.Wait(5000)
		SetEntityHealth(GetPlayerPed(-1), 0)
		Citizen.Wait(5000)
		SetEntityHealth(GetPlayerPed(-1), 0)
		ESX.ShowNotification(_U('kuollut'))
		Citizen.Wait(5000)
		SetEntityHealth(GetPlayerPed(-1), 0)
		Citizen.Wait(5000)
		SetEntityHealth(GetPlayerPed(-1), 0)
		ESX.ShowNotification(_U('kuollut'))
		Citizen.Wait(5000)
		SetEntityHealth(GetPlayerPed(-1), 0)
		Citizen.Wait(5000)
		SetEntityHealth(GetPlayerPed(-1), 0)
	end
end)

if Config.LoadIpl then
	RequestIpl('Coroner_Int_on') -- Morgue
end

-- String string
function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

function OpenMecanoCraftMenu()
  if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name ~= 'recrue' then

    local elements = {
      {label = _U('burana'),  value = 'bura'},
      {label = _U('bandage'), value = 'band'},
      {label = _U('medikit'),   value = 'medi'}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'mecano_craft',
      {
        title    = _U('craft'),
        align    = 'bottom-left',
        elements = elements
      },
      function(data, menu)
        if data.current.value == 'bura' then
          menu.close()
          TriggerServerEvent('esx_ambulancejob:startCraft')
        end

        if data.current.value == 'band' then
          menu.close()
          TriggerServerEvent('esx_ambulancejob:startCraft2')
        end

        if data.current.value == 'medi' then
          menu.close()
          TriggerServerEvent('esx_ambulancejob:startCraft3')
        end

      end,
      function(data, menu)
        menu.close()
        CurrentAction     = 'mecano_craft_menu'
        CurrentActionMsg  = _U('craft_menu')
        CurrentActionData = {}
      end
    )
  else
    ESX.ShowNotification(_U('not_experienced_enough'))
  end
end

function OpenMecanoHarvestMenu()

  if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name ~= 'recrue' then
    local elements = {
      {label = _U('laakeaine'), value = 'laaa'},
      {label = _U('laaketarvike'), value = 'laat'}
      --{label = _U('body_work_tools'), value = 'caro_tool'}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'mecano_harvest',
      {
        title    = _U('harvest'),
        align    = 'bottom-left',
        elements = elements
      },
      function(data, menu)
        if data.current.value == 'laaa' then
          menu.close()
          TriggerServerEvent('esx_ambulancejob:startHarvest')
        end

        if data.current.value == 'laat' then
          menu.close()
          TriggerServerEvent('esx_ambulancejob:startHarvest2')
        end

        --if data.current.value == 'caro_tool' then
         -- menu.close()
          --TriggerServerEvent('esx_mecanojob:startHarvest3')
        --end

      end,
      function(data, menu)
        menu.close()
        CurrentAction     = 'kerays_menu'
        CurrentActionMsg  = _U('open_kerays_menu')
        CurrentActionData = {}
      end
    )
  else
    ESX.ShowNotification(_U('not_experienced_enough'))
  end
end

function OpenGetStocksMenu()

	ESX.TriggerServerCallback('esx_ambulancejob:getStockItems', function(items)

		local elements = {}

		for i=1, #items, 1 do
			table.insert(elements, {
				label = 'x' .. items[i].count .. ' ' .. items[i].label,
				value = items[i].name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu',
		{
			title    = _U('police_stock'),
			align    = 'bottom-left',
			elements = elements
		}, function(data, menu)

			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)

				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_ambulancejob:getStockItem', itemName, count)

					Citizen.Wait(300)
					OpenGetStocksMenu()
				end

			end, function(data2, menu2)
				menu2.close()
			end)

		end, function(data, menu)
			menu.close()
		end)

	end)

end

function OpenPutStocksMenu()

  ESX.TriggerServerCallback('esx_ambulancejob:getPlayerInventory', function(inventory)

    local elements = {}
	
    for i=1, #inventory.items, 1 do

      local item = inventory.items[i]
	  
      if item.count > 0 then
        table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
      end

    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'stocks_menu',
      {
        title    = _U('inventory'),
        align    = 'bottom-left',
        elements = elements
      },
      function(data, menu)

        local itemName = data.current.value

        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count',
          {
            title = _U('quantity')
          },
          function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil then
              ESX.ShowNotification(_U('quantity_invalid'))
            else
              menu2.close()
              menu.close()
              TriggerServerEvent('esx_ambulancejob:putStockItems', itemName, count)
              Citizen.Wait(300)
              OpenPutStocksMenu()
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

RegisterNetEvent('esx_ambulancejob:drag')
AddEventHandler('esx_ambulancejob:drag', function(cop)
	IsDragged = not IsDragged
	CopPed = tonumber(cop)
	if not IsDragged then
		DetachEntity(PlayerPedId(), true, false)
	end
end)

RegisterNetEvent('esx_ambulancejob:nollaa')
AddEventHandler('esx_ambulancejob:nollaa', function()
	saamennasairaalaan = true
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		if IsDragged then
			local ped = GetPlayerPed(GetPlayerFromServerId(CopPed))
			local myped = PlayerPedId()
			AttachEntityToEntity(myped, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
			if IsPedDeadOrDying(ped) then
				IsDragged = false
			end
--		else
--			if GetEntityHeightAboveGround(GetPlayerPed(-1)) < 1 then
--				DetachEntity(PlayerPedId(), true, false)
--			end
		end
	end
end)

Citizen.CreateThread(function()
    local Peds = {
        {vector3(-816.4927, -1237.666, 6.3374238), 50.70829, 1092080539},
    }

    for k in pairs(Peds) do

        RequestModel(Peds[k][3])

        while not HasModelLoaded(Peds[k][3]) do
            Wait(1)
        end

        local entity = CreatePed(4, Peds[k][3], Peds[k][1], Peds[k][2], false, true)

        SetEntityAsMissionEntity(entity, true, false)
        SetPedRelationshipGroupHash(entity, GetHashKey("PLAYER"))
        FreezeEntityPosition(entity, true)
        SetEntityInvincible(entity, true)
        DisablePedPainAudio(entity, true)
        StopPedSpeaking(entity, true)
        SetPedCombatMovement(entity, true)
        SetPedAsEnemy(entity, false)
        TaskSetBlockingOfNonTemporaryEvents(entity, true)
        SetPedDiesWhenInjured(entity, false)
        SetPedCanPlayAmbientAnims(entity, true)
        SetPedCanRagdollFromPlayerImpact(entity, false)
        TaskStartScenarioInPlace(entity, "CODE_HUMAN_MEDIC_TIME_OF_DEATH", 0, false)
        SetEntityHeading(entity, Peds[k][2])
    end
end)

Citizen.CreateThread(function()
	local Paikka = Config.Hoito.Check
	while true do
		local a = GetEntityMaxHealth(PlayerPedId())
		local v = PlayerPedId()
        local SleepThread = 200
        local PlayerPos = GetEntityCoords(PlayerPedId())
        local Distance = #(Paikka - PlayerPos)
        if Distance < 5.0 then
            if Distance < 0.5 then
                SleepThread = 5
				DrawMarker(2, -817.4868, -1236.78, 7.3374247, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.2, 255, 255, 255, 255, 0, 0, 0, 1, 0, 0, 0)
				exports['okokTextUI']:Open('[E] To talk', 'darkblue', 'left')
				if IsControlJustReleased(0, 38) then
					if timerr == 0 then
						timerr = 15
						ExecuteCommand('e leanbar3')
						TriggerEvent("mythic_progbar:client:progress", {
							name = "unique_action_name",
							duration = 3000,
							label = "Logging in...",
							useWhileDead = false,
							canCancel = true,
							controlDisables = {
								disableMovement = true,
								disableCarMovement = true,
								disableMouse = false,
								disableCombat = true,
							},
						}, function(status)
							SetEntityCoords(v, -809.4788, -1226.805, 8.2572364, false, false, false, true)
							SetEntityHeading(PlayerPedId(), 136.44982)
							Citizen.Wait(5)
							ExecuteCommand('e sunbathe')
							AnimpostfxPlay('DrugsMichaelAliensFight', 0, false)
							exports['okokTextUI']:Close()
							TriggerEvent("mythic_progbar:client:progress", {
								name = "unique_action_name",
								duration = 6000,
								label = "manage...",
								useWhileDead = false,
								canCancel = true,
								controlDisables = {
									disableMovement = true,
									disableCarMovement = true,
									disableMouse = false,
									disableCombat = true,
								},
							}, function(status)
								SetEntityCoords(v, -806.8598, -1237.666, 7.3374261, false, false, false, true)
								SetEntityHeading(PlayerPedId(), 45.109542)
								SetEntityHealth(PlayerPedId(), a)
								ExecuteCommand('stopemote')
								AnimpostfxStop('DrugsMichaelAliensFight')
								exports['okokNotify']:Alert("Nurse", "you are fine now", 3000, 'success')
							end)
						end)
					else
						ESX.ShowAdvancedNotification('Nurse:', 'reception', '~r~You have just logged in, please come back later.', 'CHAR_ANDREAS', 1, 150)
					end
				end
			else
				exports['okokTextUI']:Close()
			end
		end
		Citizen.Wait(SleepThread)
	end	
end)


