local storedWorth = {}
local Server = {
    UseFee = false, -- Use a percentage cut. (true = yes/ false = no). Percentage set below.
    Percentage = 10, -- Will deduct 10% of total worth.
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
    local Player = GetPlayer(src)
    local pos = GetEntityCoords(GetPlayerPed(src))
    local isNear = isNearLocation(pos)

    if not isNear then return false end

    local totalWorth = RemoveDirtyMoney(Player)

    if totalWorth > 0 then
        storedWorth[src] = totalWorth
        TriggerClientEvent('randol_moneywash:client:exchangeBills', src)
        DoNotification(src, ('Please wait. Exchanging $%s dirty money for clean cash.'):format(totalWorth))
        return true
    end

    return false
end)

lib.callback.register('randol_moneywash:server:returnCleanCash', function(source)
    local src = source
    local Player = GetPlayer(src)
    local totalWorth = storedWorth[src]

    if not totalWorth then return false end

    if Server.UseFee then
        local fee = percentageCut(Server.Percentage, totalWorth)
        local floored = math.floor(totalWorth - fee)
        AddCleanMoney(Player, 'cash', floored)
        DoNotification(src, ('You received $%s after the %s%s washing fee.'):format(floored, Server.Percentage, '%'), 'success')
    else
        AddCleanMoney(Player, 'cash', totalWorth)
        DoNotification(src, ('You received $%s in return.'):format(totalWorth), 'success')
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

function PlayerHasLoaded(source)
    local src = source
    SetTimeout(2000, function()
        TriggerClientEvent('randol_moneywash:client:cacheConfig', src, Server)
    end)
end
