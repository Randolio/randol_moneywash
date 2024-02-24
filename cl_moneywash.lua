local Config = {}
local MW_PED = {}
local storedPoints = {}

function deleteAllPeds()
    for point, _ in pairs(storedPoints) do
        if storedPoints[point] then
            storedPoints[point]:remove()
        end
    end
    for ped, _ in pairs(MW_PED) do
        if DoesEntityExist(MW_PED[ped]) then
            DeleteEntity(MW_PED[ped])
            exports['qb-target']:RemoveTargetEntity(MW_PED[ped], "Exchange")
        end
    end
    table.wipe(MW_PED)
    table.wipe(storedPoints)
    table.wipe(Config)
end

local function spawnPed(point)
    if not DoesEntityExist(MW_PED[point.index]) then
        local data = point.pedData
        local model = joaat(data.model)
        lib.requestModel(model, 5000)
        
        MW_PED[point.index] = CreatePed(6, model, data.coords.x, data.coords.y, data.coords.z - 1.0, data.coords.w, false, true)
        SetEntityAsMissionEntity(MW_PED[point.index])
        SetPedFleeAttributes(MW_PED[point.index], 0, 0)
        SetBlockingOfNonTemporaryEvents(MW_PED[point.index], true)
        SetEntityInvincible(MW_PED[point.index], true)
        FreezeEntityPosition(MW_PED[point.index], true)

        if data.dict then
            lib.requestAnimDict(data.dict, 5000)        
            TaskPlayAnim(MW_PED[point.index], data.dict, data.anim, 8.0, 1.0, -1, 01, 0, 0, 0, 0)
        elseif data.scenario then
            TaskStartScenarioInPlace(MW_PED[point.index], data.scenario, 0, true)
        end

        exports['qb-target']:AddTargetEntity(MW_PED[point.index], { -- ox-target supports qb-target conversion for qb and esx
            options = {
                {
                    icon = 'fa-solid fa-sack-dollar',
                    label = 'Exchange',
                    action = function()
                        local success = lib.callback.await('randol_moneywash:server:checkBills', false)
                        if not success then
                            DoNotification("You don't have any dirty money.", "error")
                        end
                    end,
                },
            },
            distance = 1.5,
        })
    end
end

local function yeetPed(point)
    if DoesEntityExist(MW_PED[point.index]) then
        DeleteEntity(MW_PED[point.index])
        exports['qb-target']:RemoveTargetEntity(MW_PED[point.index], "Exchange")
        MW_PED[point.index] = nil
    end
end

local function createPoints()
    for id, data in pairs(Config.locations) do
        storedPoints[id] = lib.points.new({
        coords = data.coords,
        distance = 30,
        index = id,
        pedData = data,
        onEnter = spawnPed,
        onExit = yeetPed,
        })
    end
end

RegisterNetEvent('randol_moneywash:client:exchangeBills', function()
    if GetInvokingResource() then return end
    TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_WINDOW_SHOP_BROWSE", 0, true)
    if lib.progressCircle({
        duration = 10000,
        position = 'bottom',
        label = 'Exchanging marked bills..',
        useWhileDead = true,
        canCancel = false,
        disable = { move = true, car = true, mouse = false, combat = true, },
    }) then
        ClearPedTasksImmediately(cache.ped)
        lib.callback.await('randol_moneywash:server:returnCleanCash', false)
    end
end)

RegisterNetEvent('randol_moneywash:client:cacheConfig', function(data)
    if GetInvokingResource() or not hasPlyLoaded() then return end
    Config = data
    createPoints()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        deleteAllPeds()
    end
end)
