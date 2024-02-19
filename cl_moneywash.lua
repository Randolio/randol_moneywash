local Config = {}
local pedTable = {}

local function deleteAllPeds()
    for i = 1, #pedTable do
        if DoesEntityExist(pedTable[i]) then
            DeleteEntity(pedTable[i])
        end
    end
    table.wipe(pedTable)
    table.wipe(Config)
end

local function spawnPeds()
    for i = 1, #Config.locations do
        local data = Config.locations[i]
        local model = joaat(data.model)
        lib.requestModel(model, 5000)

        local MW_PED = CreatePed(6, model, data.coords.x, data.coords.y, data.coords.z - 1.0, data.coords.w, false, true)
        SetEntityAsMissionEntity(MW_PED)
        SetPedFleeAttributes(MW_PED, 0, 0)
        SetBlockingOfNonTemporaryEvents(MW_PED, true)
        SetEntityInvincible(MW_PED, true)
        FreezeEntityPosition(MW_PED, true)

        if data.dict then
            lib.requestAnimDict(data.dict, 5000)        
            TaskPlayAnim(MW_PED, data.dict, data.anim, 8.0, 1.0, -1, 01, 0, 0, 0, 0)
        elseif data.scenario then
            TaskStartScenarioInPlace(MW_PED, data.scenario, 0, true)
        end

        exports['qb-target']:AddTargetEntity(MW_PED, {
            options = {
                {
                    icon = 'fa-solid fa-sack-dollar',
                    label = 'Exchange Bills',
                    action = function()
                        lib.callback.await('randol_moneywash:server:checkBills', false)
                    end,
                    item = 'markedbills',
                },
            },
            distance = 1.5,
        })
        pedTable[#pedTable+1] = MW_PED
    end
end

RegisterNetEvent('randol_moneywash:client:exchangeBills', function()
    if GetInvokingResource() then return end
    TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_WINDOW_SHOP_BROWSE", 0, true)
    QBCore.Functions.Progressbar("cleanbills", "Exchanging marked bills..", 10000, false, false, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        ClearPedTasksImmediately(cache.ped)
        lib.callback.await('randol_moneywash:server:returnCleanCash', false)
    end)
end)

RegisterNetEvent('randol_moneywash:client:cacheConfig', function(data)
    if GetInvokingResource() then return end
    if LocalPlayer.state.isLoggedIn then
        Config = data
        spawnPeds()
    end
end)

AddEventHandler('onResourceStop', function(resourceName) 
	if GetCurrentResourceName() == resourceName then
        deleteAllPeds()
	end 
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    deleteAllPeds()
end)