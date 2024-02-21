if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

function GetPlayer(id)
    return ESX.GetPlayerFromId(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('esx:showNotification', src, text, nType)
end

function GetPlyIdentifier(xPlayer)
    return xPlayer.identifier
end

function GetCharacterName(xPlayer)
    return xPlayer.getName()
end

function RemoveDirtyMoney(xPlayer)
    local totalWorth = 0
    local balance = xPlayer.getAccount('black_money').money

    if balance > 0 then
        totalWorth = balance
        xPlayer.removeAccountMoney('black_money', totalWorth)
    end

    return totalWorth
end

function AddCleanMoney(xPlayer, account, amount)

    if account == 'cash' then account = 'money' end
    xPlayer.addAccountMoney(account, amount, "cleaning")
end

AddEventHandler('esx:playerLoaded', function(source)
    PlayerHasLoaded(source)
end)