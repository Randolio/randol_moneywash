local QBCore = exports['qb-core']:GetCoreObject()


function PercentageCut(percent, value)
    if tonumber(percent) and tonumber(value) then
        return (value*percent)/100
    end
    return false
end


RegisterNetEvent("randol_moneywash:server:checkforbills")
AddEventHandler("randol_moneywash:server:checkforbills", function()
    local ServerDataWorth = 0
    local amount = 0
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    for slot, data in pairs(Player.PlayerData.items) do
        if data ~= nil then
            if data.name == 'markedbills' then
                ServerDataWorth = ServerDataWorth + (data.info.worth * data.amount)
                amount = amount + data.amount
                Player.Functions.RemoveItem('markedbills', data.amount, slot)
            end
        end
    end

    CreateThread(function()
        if ServerDataWorth > 0 and amount > 0 then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "remove", amount)
            TriggerClientEvent('randol_moneywash:client:exchangebills', src, ServerDataWorth)
            TriggerClientEvent('QBCore:Notify', src, 'Please wait. Exchanging '..amount..' marked bills for clean cash.')
        end
    end)

end)


RegisterNetEvent("randol_moneywash:server:returncleancash")
AddEventHandler("randol_moneywash:server:returncleancash", function(ServerDataWorth)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local finalworth = ServerDataWorth
    local fee = PercentageCut(Config.Percentage, finalworth)
    local floored = math.floor(finalworth - fee)

    if Config.UseFee then
        Player.Functions.AddMoney('cash', floored)
        TriggerClientEvent('QBCore:Notify', src, 'You received $'..floored..' after the '..Config.Percentage..'% washing fee.', 'success')
    else
        Player.Functions.AddMoney('cash', finalworth)
        TriggerClientEvent('QBCore:Notify', src, 'You received $'..finalworth..' in return.', 'success')
    end
end)