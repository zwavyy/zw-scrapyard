local triggerCounts = {}
local identifier

RegisterNetEvent('zw-scrapyard:start')
AddEventHandler('zw-scrapyard:start', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	identifier = xPlayer.getIdentifier()
	if not triggerCounts[identifier] then
		triggerCounts[identifier] = 1
	else
		triggerCounts[identifier] = triggerCounts[identifier] + 1
	end

	if triggerCounts[identifier] <= Config.Maxperday then
		TriggerClientEvent('zw-scrapyard:startquest', source)
	else
		TriggerClientEvent('ox_lib:notify', source, { title = 'Max quests', description = 'You have reached maximu quests.' })
	end
end)

RegisterServerEvent('zw-scrapyard:reward')
AddEventHandler('zw-scrapyard:reward', function(demolishSucess)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local stolemoney = math.random(Config.Minreward, Config.Maxreward)
	if demolishSucess > 6 then
		-- Do anything you want here, if it excceeds the maximum (6) it means they are exploting.
	else
		xPlayer.addAccountMoney('black_money', (stolemoney * demolishSucess))
	end
end)
