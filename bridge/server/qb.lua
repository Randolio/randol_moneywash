if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

function GetPlayer(id)
    return QBCore.Functions.GetPlayer(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('QBCore:Notify', src, text, nType)
end

function GetPlyIdentifier(Player)
    return Player.PlayerData.citizenid
end

function GetCharacterName(Player)
    return Player.PlayerData.charinfo.firstname.. ' ' ..Player.PlayerData.charinfo.lastname
end

function RemoveDirtyMoney(Player)
    local totalWorth, amount = 0, 0

    local ox_inventory = GetResourceState('ox_inventory') == 'started'

    for slot, data in pairs(Player.PlayerData.items) do
        if data and data.name == 'markedbills' then

            local worth = ox_inventory and data.metadata.worth or data.info.worth
            local count = ox_inventory and data.count or data.amount

            if worth and count then
                totalWorth += (worth * count)
                amount += count
                Player.Functions.RemoveItem('markedbills', count, slot)
            end
        end
    end

    if totalWorth > 0 and amount > 0 then
        if not ox_inventory then 
            TriggerClientEvent('inventory:client:ItemBox', Player.PlayerData.source, QBCore.Shared.Items['markedbills'], "remove", amount)
        end
        return totalWorth
    end

    return 0, lib.print.error('No item metadata found for markedbills.')
end

function AddCleanMoney(Player, account, amount)
    Player.Functions.AddMoney(account, amount)
end

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    PlayerHasLoaded(source)
end)