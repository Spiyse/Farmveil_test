local player = {}
local config = require("src/config")

player.coins = 10
player.seeds = {wheat = 1 }
player.crops = {}
player.activeSeed = "wheat"
player.sprinklers = 0
player.sprinklerPurchases = 0

function player.addCoins(amount)
    player.coins = player.coins + (amount or 0)
end

function player.spendCoins(amount)
    if player.coins >= amount then
        player.coins = player.coins - amount
        return true
    end
    return false
end

function player.spendWithReserve(amount, reserve)
    reserve = reserve or (config.MIN_COIN_RESERVE or 0)
    if (player.coins - amount) >= reserve then
        player.coins = player.coins - amount
        return true
    end
    return false
end

function player.addSeeds(id, count)
    if not id then return end
    player.seeds[id] = (player.seeds[id] or 0) + (count or 0)
end

function player.consumeSeed(id)
    local c = player.seeds[id] or 0
    if c > 0 then
        player.seeds[id] = c - 1
        return true
    end
    return false
end

function player.addCrop(id, count)
    if not id then return end
    player.crops[id] = (player.crops[id] or 0) + (count or 0)
end

function player.addSprinklers(count)
    player.sprinklers = player.sprinklers + (count or 0)
end

function player.buySprinklers(count)
    count = count or 0
    if count <= 0 then return end
    player.sprinklers = player.sprinklers + count
    player.sprinklerPurchases = player.sprinklerPurchases + count
end

function player.getSprinklerPurchases()
    return player.sprinklerPurchases or 0
end

function player.consumeSprinkler()
    if player.sprinklers > 0 then
        player.sprinklers = player.sprinklers - 1
        return true
    end
    return false
end

function player.sellAllCrops(priceMap)
    local total = 0
    for id, count in pairs(player.crops) do
        local price = priceMap and priceMap[id] or 0
        total = total + price * count
        player.crops[id] = 0
    end
    player.addCoins(total)
    return total
end

function player.setActiveSeed(id)
    if id then player.activeSeed = id end
end 

return player
