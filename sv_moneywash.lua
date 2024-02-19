local storedWorth = {}
local Server = {
    useFee = false, -- Use a percentage cut. (true = yes/ false = no). Percentage set below.
    percentage = 10, -- Will deduct 10% of total worth.
    locations = {
        {model = 'u_m_m_streetart_01', coords = vec4(721.41, -1203.5, 27.25, 180.74), dict = 'timetable@ron@ig_3_couch', anim = 'base'},
        {model = 'a_m_m_hasjew_01', coords = vec4(-489.54, -2228.88, 6.78, 233.56), scenario = 'WORLD_HUMAN_STAND_MOBILE', },
    }
}

local function percentageCut(percent, value)
    if tonumber(percent) and tonumber(value) then
        return (value*percent)/100
    end
    return false
end

local function isNearLocation(pos)
    for i = 1, #Server.locations do
        local coords = Server.locations[i].coords
        if #(pos - coords.xyz) < 5.0 then
            return true
        end
    end
    return false
end

lib.callback.register('randol_moneywash:server:checkBills', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local pos = GetEntityCoords(GetPlayerPed(src))
    local totalWorth = 0
    local amount = 0
    local isNear = isNearLocation(pos)

    if not isNear then return false end

    for slot, data in pairs(Player.PlayerData.items) do
        if data and data.name == 'markedbills' then
            totalWorth += (data.info.worth * data.amount)
            amount += data.amount
            Player.Functions.RemoveItem('markedbills', data.amount, slot)
        end
    end

    if totalWorth > 0 and amount > 0 then
        storedWorth[src] = totalWorth
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "remove", amount)
        TriggerClientEvent('randol_moneywash:client:exchangeBills', src)
        TriggerClientEvent('QBCore:Notify', src, ('Please wait. Exchanging %sx marked bills for clean cash.'):format(amount))
        return true
    end

    return false
end)

lib.callback.register('randol_moneywash:server:returnCleanCash', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local totalWorth = storedWorth[src]

    if not totalWorth then return false end

    if Server.UseFee then
        local fee = percentageCut(Server.Percentage, totalWorth)
        local floored = math.floor(totalWorth - fee)
        Player.Functions.AddMoney('cash', floored)
        TriggerClientEvent('QBCore:Notify', src, ('You received $%s after the %s%s washing fee.'):format(floored, Server.Percentage, '%'), 'success')
    else
        Player.Functions.AddMoney('cash', totalWorth)
        TriggerClientEvent('QBCore:Notify', src, ('You received $%s in return.'):format(totalWorth), 'success')
    end
    storedWorth[src] = nil
    return true
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    SetTimeout(2000, function()
        TriggerClientEvent('randol_moneywash:client:cacheConfig', -1, Server)
    end)
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    SetTimeout(2000, function()
        TriggerClientEvent('randol_moneywash:client:cacheConfig', src, Server)
    end)
end)
