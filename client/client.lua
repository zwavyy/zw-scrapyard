local currentJob
local mylescoords = Config.Npcspawn
local mylesheading = Config.Npcheading
local vehicle

for id, location in pairs(Config.Locations) do
  local blip = AddBlipForCoord(location.x, location.y, location.z)
  SetBlipSprite(blip, 380)
  SetBlipDisplay(blip, 4)
  SetBlipScale(blip, 0.7)
  SetBlipAsShortRange(blip, true)
  SetBlipColour(blip, 9)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentSubstringPlayerName(tostring(Config.Blipname))
  EndTextCommandSetBlipName(blip)
end

CreateThread(function()
  local ped, pedSpawned = nil, false
  local sleep = 1500
  local animDict = 'mini@strip_club@idles@bouncer@base'
  local pedModel = 's_m_y_dockwork_01'

  while true do
    local playerPed = cache.ped
    local coords = GetEntityCoords(playerPed)
    local dist = #(coords - mylescoords)

    if dist <= 30 and not pedSpawned then
      lib.requestAnimDict(animDict, 1000)
      lib.requestModel(pedModel, 1000)

      ped = CreatePed(28, pedModel, mylescoords.x, mylescoords.y, mylescoords.z, mylesheading, false, false)
      FreezeEntityPosition(ped, true)
      SetEntityInvincible(ped, true)
      SetBlockingOfNonTemporaryEvents(ped, true)
      SetEntityAsMissionEntity(ped, true, true)
      SetPedComponentVariation(ped, 0, 1)
      SetPedComponentVariation(ped, 1, 0)

      TaskPlayAnim(ped, animDict, 'base', 8.0, 0.0, -1, 1, 0, 0, 0, 0)

      local options = {
        {
          name = 'startquest',
          icon = 'far fa-comment-dots',
          label = "Start Quest",
          onSelect = function(entity)
            if not currentJob then
              TriggerServerEvent('zw-scrapyard:start')
              currentJob = true
            else
              lib.notify({ title = "Failed to start quest", description = "You've already started this objective." })
            end
          end,
          distance = 1.5,
        },
        {
          name = 'endquest',
          icon = 'far fa-comment-dots',
          label = "Stop Quest",
          onSelect = function(entity)
            TriggerEvent('zw-scrapyard:end')
          end,
          distance = 1.5,
        },
      }
      exports.ox_target:addLocalEntity(NetworkGetNetworkIdFromEntity(ped), options)
      pedSpawned = true
    elseif dist >= 31 and pedSpawned then
      local model = GetEntityModel(ped)
      SetModelAsNoLongerNeeded(model)
      DeletePed(ped)
      SetPedAsNoLongerNeeded(ped)
      RemoveAnimDict(animDict)
      pedSpawned = false
    end
    Wait(sleep)
  end
end)

RegisterNetEvent('zw-scrapyard:startquest')
AddEventHandler('zw-scrapyard:startquest', function()
  acitveMission = true
  local randomIndex = math.random(1, #Config.Vehicles)
  local randomVehicle = Config.Vehicles[randomIndex]
  local coordsFound = false
  local coords

  while not coordsFound do
    Citizen.Wait(200)
    local randomCoordsIndex = math.random(1, #Config.spawnCoords)
    coords = Config.spawnCoords[randomCoordsIndex]
    local closestVehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)

    if closestVehicle == 0 then
      coordsFound = true
    end
  end

  local car = GetHashKey(randomVehicle)
  RequestModel(car)
  while not HasModelLoaded(car) do
    Citizen.Wait(100)
  end

  vehicle = CreateVehicle(car, coords.x, coords.y, coords.z, 90.0, true, false)
  SetBlockingOfNonTemporaryEvents(vehicle, true)
  SetEntityAsMissionEntity(vehicle, true, true)
  FreezeEntityPosition(vehicle, true)
  lib.notify({ title = 'Started quest', description = 'A vehicle has been placed, demolish for a reward.' })
  TriggerEvent('zw-scrapyard:demolish')
end)


RegisterNetEvent('zw-scrapyard:demolish')
AddEventHandler('zw-scrapyard:demolish', function()
  local options = {
    {
      icon = "fa-solid fa-car-side",
      label = "Demolish hood",
      bones = 'bonnet',
      onSelect = function()
        TriggerEvent('zw-scrapyard:removeDoor', 'hood')
      end,
      distance = 1
    },
    {
      icon = "fa-solid fa-car-side",
      label = "Demolish right front door",
      bones = 'door_pside_f',
      onSelect = function()
        TriggerEvent('zw-scrapyard:removeDoor', 'frdoor')
      end,
      distance = 1
    },
    {
      icon = "fa-solid fa-car-side",
      label = "Demolish left front door",
      bones = 'door_dside_f',
      onSelect = function()
        TriggerEvent('zw-scrapyard:removeDoor', 'fldoor')
      end,
      distance = 1
    },
    {
      icon = "fa-solid fa-car-side",
      label = "Demolish right back door",
      bones = 'door_pside_r',
      onSelect = function()
        TriggerEvent('zw-scrapyard:removeDoor', 'brdoor')
      end,
      distance = 1
    },
    {
      icon = "fa-solid fa-car-side",
      label = "Demolish left back door",
      bones = 'door_dside_r',
      onSelect = function()
        TriggerEvent('zw-scrapyard:removeDoor', 'bldoor')
      end,
      distance = 1
    },
    {
      icon = "fa-solid fa-car-side",
      label = "Demolish trunk",
      bones = 'boot',
      onSelect = function()
        TriggerEvent('zw-scrapyard:removeDoor', 'trunk')
      end,
      distance = 1
    },
  }

  exports.ox_target:addEntity(NetworkGetNetworkIdFromEntity(vehicle), options)
end)

local doorArray = {}

function addDoorToArray(door)
  for _, value in ipairs(doorArray) do
    if value == door then
      return false
    end
  end

  table.insert(doorArray, door)
  return true
end

local count = 0
local demolishSucess = 0

AddEventHandler('zw-scrapyard:removeDoor', function(door)
  local result = addDoorToArray(door)

  if result == false then
    lib.notify({ title = 'Failed to demolish', description = 'You have already demolished this part' })
  else
    if lib.skillCheckActive() or lib.progressActive() then
      lib.notify({ title = 'Failed to demolish', description = 'You are currently demolishing' })
    else
      local success = lib.skillCheck({ 'easy', 'easy', 'easy', 'easy' },
        { 'w', 'a', 's', 'd' })
      if success then
        if lib.progressBar({
              duration = Config.Demolish,
              label = 'Demolishing door',
              useWhileDead = false,
              disable = {
                move = true,
              },
              anim = {
                scenario = 'WORLD_HUMAN_WELDING',
              },
            }) then
          demolishSucess = demolishSucess + 1
        end
      else
        lib.notify({ title = 'Demolish failed', description = 'Failed to demolish part' })
      end
      count = count + 1
    end
  end
  if count == 6 then
    TriggerEvent('zw-scrapyard:end', demolishSucess)
    count = 0
  end
end)


RegisterNetEvent('zw-scrapyard:end')
AddEventHandler('zw-scrapyard:end', function(demolishSucess)
  lib.notify({ title = 'Quest Ended', description = 'You ended the quest.' })
  DeleteVehicle(vehicle)
  TriggerServerEvent('zw-scrapyard:reward', demolishSucess)
  currentJob = false
end)
