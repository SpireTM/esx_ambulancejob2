ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
--[[
----- Revive ftili 
RegisterServerEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function(target) -- paska rivi kusee
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local societyAccount
    local societyMoney = 1000 --lanssin tilille tuleva raha per revaus
    local targetPlayer = ESX.GetPlayerFromId(target)

    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_ambulance', function(account)
        societyAccount = account
    end)

------ ]]

-- take money
RegisterServerEvent('esx_ambulancejob:hoitoon')
AddEventHandler('esx_ambulancejob:hoitoon', function(_source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.getMoney(1500)
	xPlayer.removeMoney(1500)
end)


RegisterServerEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function(target)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.addMoney(Config.ReviveReward)
	TriggerClientEvent('esx_ambulancejob:revive', target)
end)

RegisterServerEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(target, type)
	TriggerClientEvent('esx_ambulancejob:heal', target, type)
end)

RegisterServerEvent('esx_ambulancejob:putInVehicle')
AddEventHandler('esx_ambulancejob:putInVehicle', function(target)

	TriggerClientEvent('esx_ambulancejob:putInVehicle', target)
end)

TriggerEvent('esx_phone:registerNumber', 'ambulance', _U('alert_ambulance'), true, true)

TriggerEvent('esx_society:registerSociety', 'ambulance', 'Ambulance', 'society_ambulance', 'society_ambulance', 'society_ambulance', {type = 'public'})

ESX.RegisterServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.RemoveCashAfterRPDeath then
		if xPlayer.getMoney() > 0 then
			xPlayer.removeMoney(xPlayer.getMoney())
		end

		if xPlayer.getAccount('black_money').money > 0 then
			xPlayer.setAccountMoney('black_money', 0)
		end
	end

	if Config.RemoveItemsAfterRPDeath then
		for i=1, #xPlayer.inventory, 1 do
			if xPlayer.inventory[i].count > 0 then
				xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
			end
		end
	end

	local playerLoadout = {}
	if Config.RemoveWeaponsAfterRPDeath then
		for i=1, #xPlayer.loadout, 1 do
			xPlayer.removeWeapon(xPlayer.loadout[i].name)
		end
	else -- save weapons & restore em' since spawnmanager removes them
		for i=1, #xPlayer.loadout, 1 do
			table.insert(playerLoadout, xPlayer.loadout[i])
		end

		-- give back wepaons after a couple of seconds
		Citizen.CreateThread(function()
			Citizen.Wait(5000)
			for i=1, #playerLoadout, 1 do
				if playerLoadout[i].label ~= nil then
					xPlayer.addWeapon(playerLoadout[i].name, playerLoadout[i].ammo)
				end
			end
		end)
	end

	cb()
end)

if Config.EarlyRespawn and Config.EarlyRespawnFine then
	ESX.RegisterServerCallback('esx_ambulancejob:checkBalance', function(source, cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		local bankBalance = xPlayer.getAccount('bank').money

		cb(bankBalance >= Config.EarlyRespawnFineAmount)
	end)

	ESX.RegisterServerCallback('esx_ambulancejob:payFine', function(source, cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('respawn_fine', Config.EarlyRespawnFineAmount))
		xPlayer.removeAccountMoney('bank', Config.EarlyRespawnFineAmount)

		cb()
	end)
end

ESX.RegisterServerCallback('esx_ambulancejob:getItemAmount', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local quantity = xPlayer.getInventoryItem(item).count

	cb(quantity)
end)

RegisterServerEvent('esx_ambulancejob:removeItem')
AddEventHandler('esx_ambulancejob:removeItem', function(item)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem(item, 1)

	if item == 'bandage' then
		TriggerClientEvent('esx:showNotification', _source, _U('used_bandage'))
	elseif item == 'medikit' then
		TriggerClientEvent('esx:showNotification', _source, _U('used_medikit'))
	end
end)

RegisterServerEvent('esx_ambulancejob:giveItem')
AddEventHandler('esx_ambulancejob:giveItem', function(itemName)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local item = xPlayer.getInventoryItem(itemName)
	local count = 1

	if item.limit ~= -1 then
		count = item.limit - item.count
	end

	if item.count < item.limit then
		xPlayer.addInventoryItem(itemName, count)
	else
		TriggerClientEvent('esx:showNotification', _source, _U('max_item'))
	end
end)

TriggerEvent('es:addGroupCommand', 'revive', 'admin', function(source, args, user)
	if args[1] ~= nil then
		if GetPlayerName(tonumber(args[1])) ~= nil then
			print('esx_ambulancejob: ' .. GetPlayerName(source) .. ' is reviving a player!')
			TriggerClientEvent('esx_ambulancejob:revive', tonumber(args[1]))
		end
	else
		TriggerClientEvent('esx_ambulancejob:revive', source)
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, { help = _U('revive_help'), params = { { name = 'id' } } })

ESX.RegisterUsableItem('medikit', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeInventoryItem('medikit', 1)
	TriggerClientEvent('esx_ambulancejob:heal', _source, 'big')
	TriggerClientEvent('esx:showNotification', _source, 'K??ytit ~g~Ensiapupakkauksen~s~')
end)

ESX.RegisterUsableItem('bandage', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeInventoryItem('bandage', 1)
	TriggerClientEvent('esx_ambulancejob:heal', _source, 'big')
	TriggerClientEvent('esx:showNotification', _source, 'K??ytit ~g~Sideharson~s~')
end)
  
ESX.RegisterUsableItem('burana', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeInventoryItem('burana', 1)
	TriggerClientEvent('esx_ambulancejob:heal', _source, 'small')
	TriggerClientEvent('esx:showNotification', _source, 'S??it ~g~Buranan~s~')
end)

RegisterServerEvent('esx_ambulancejob:firstSpawn')
AddEventHandler('esx_ambulancejob:firstSpawn', function()
	local _source    = source
	local identifier = GetPlayerIdentifiers(_source)[1]
	MySQL.Async.fetchScalar('SELECT isDead FROM users WHERE identifier=@identifier',
	{
		['@identifier'] = identifier
	}, function(isDead)
		if isDead == 1 then
			print('esx_ambulancejob: ' .. GetPlayerName(_source) .. ' (' .. identifier .. ') attempted combat logging!')
			TriggerClientEvent('esx_ambulancejob:requestDeath', _source)
		end
	end)
end)

RegisterServerEvent('esx_ambulancejob:setDeathStatus')
AddEventHandler('esx_ambulancejob:setDeathStatus', function(isDead)
	local _source = source
	MySQL.Sync.execute("UPDATE users SET isDead=@isDead WHERE identifier=@identifier",
	{
		['@identifier'] = GetPlayerIdentifiers(_source)[1],
		['@isDead'] = isDead
	})
end)

TriggerEvent('es:addGroupCommand', 'revive', 'admin', function(source, args, user)
	if args[1] ~= nil then
		if GetPlayerName(tonumber(args[1])) ~= nil then
			--print(('esx_ambulancejob: %s used admin revive'):format(GetPlayerIdentifiers(source)[1]))
			TriggerClientEvent('esx_ambulancejob:revive', tonumber(args[1]))
			TriggerClientEvent('chatMessage', source, " REPORT ", {255, 0, 0}, "^3"..os.date("%X").."^0 | ^1"..GetPlayerName(source).."^0 nosti henkil??n ^1"..GetPlayerName(args[1]))
				TriggerEvent("es:getPlayers", function(pl)
		for k,v in pairs(pl) do
			TriggerEvent("es:getPlayerFromId", k, function(user)
				if(user.getPermissions() > 0 and k ~= source)then
			TriggerClientEvent('chatMessage', k, " REPORT ", {255, 0, 0}, "^3"..os.date("%X").."^0 | ^1"..GetPlayerName(source).."^0 nosti henkil??n ^1"..GetPlayerName(args[1]))
				end
			end)
		end
	end)
		end
	else
		TriggerClientEvent('esx_ambulancejob:revive', source)
			TriggerClientEvent('chatMessage', source, " REPORT ", {255, 0, 0}, "^3"..os.date("%X").."^0 | ^1"..GetPlayerName(source).."^0 nostit ^1itsesi^0.")
				TriggerEvent("es:getPlayers", function(pl)
			end)
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, { help = _U('revive_help'), params = {{ name = 'id' }} })

TriggerEvent('es:addGroupCommand', 'heal', 'admin', function(source, args, user)
	if args[1] then
		local target = tonumber(args[1])
		if target ~= nil then
			if GetPlayerName(target) then
				TriggerClientEvent('esx_ambulancejob:heal2', target)
			else
				TriggerClientEvent('chatMessage', source, "TIEDOITUS", {255, 0, 0}, "Virheellinen ID")
			end
		else
			TriggerClientEvent('chatMessage', source, "HEAL", {255, 0, 0}, "Virheellinen ID")
		end
	else
		TriggerClientEvent('esx_ambulancejob:heal2', source)
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "HEAL", {255, 0, 0}, "Sinulla ei ole oikeuksia t??h??n.")
end, {help = "Paranna pelaaja."})

RegisterServerEvent('esx_ambulancejob:nollaa')
AddEventHandler('esx_ambulancejob:nollaa', function(source)
  TriggerClientEvent('esx_ambulancejob:nollaa', source)
end)