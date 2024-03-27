if GetResourceState('ND_Core') ~= 'started' then return end

if GetResourceState('ox_inventory') ~= 'started' then
    return lib.print.error('ox inventory is required for ND bridge unless you make the changes yourself.')
end

local NDCore = exports.ND_Core

function GetPlayer(id)
    return NDCore:getPlayer(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('ox_lib:notify', src, { type = nType, description = text })
end

function GetPlyIdentifier(player)
    return player?.id
end

function GetCharacterName(player)
    return player?.fullname
end

function RemoveDirtyMoney(player)
    local totalWorth = 0
    local balance = exports.ox_inventory:GetItemCount(player.source, 'black_money')

    if balance > 0 then
        totalWorth = balance
        exports.ox_inventory:RemoveItem(player.source, 'black_money', totalWorth)
    end

    return totalWorth
end

function AddCleanMoney(player, account, amount)
    player.addMoney(account, amount)
end

AddEventHandler("ND:characterLoaded", function(player)
    PlayerHasLoaded(player.source)
end)