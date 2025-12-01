local assets = require("src/systems/assets")
local config = {}


config.TILE_SIZE = 32
config.RADIUS = 24
config.GRID_WIDTH = config.RADIUS * 2 + 1
config.GRID_HEIGHT = config.RADIUS * 2 + 1
config.GRID_OFFSET_X = 4
config.GRID_OFFSET_Y = 4

config.CENTER_X = math.floor(config.GRID_WIDTH / 2) + 1
config.CENTER_Y = math.floor(config.GRID_HEIGHT / 2) + 1

config.CENTER_ON_SCREEN = true
config.START_UNLOCK_RADIUS = 2


config.GROW_TIME = 5
config.WATERED_GROWTH_MULTIPLIER = 2
config.MIN_COIN_RESERVE = 5
config.SPRINKLER_PRICE = 300
config.SPRINKLER_PRICE_GROWTH = 1.5
config.SPRINKLER_COOLDOWN = 3
config.SPRINKLER_RADIUS = 1
config.WATER_COOLDOWN = 2

local function tryLoad(path)
    if not love or not love.graphics then return nil end
    local ok, img = pcall(love.graphics.newImage, path)
    return ok and img or nil
end

config.SEED_TYPES = {
    { id = "wheat",   name = "Wheat",   price = 5,  sellPrice = 10, growTime = 7 },
    { id = "potato",  name = "Potato",  price = 15,  sellPrice = 21, growTime = 8 },
    { id = "tomato",  name = "Tomato",  price = 24, sellPrice = 31, growTime = 9 },
    { id = "pumpkin", name = "Pumpkin", price = 36, sellPrice = 46, growTime = 11 },
}

function config.getSeedById(id)
    for _, s in ipairs(config.SEED_TYPES) do
        if s.id == id then return s end
    end
    return nil
end

function config.getSellPriceMap()
    local m = {}
    for _, s in ipairs(config.SEED_TYPES) do
        m[s.id] = s.sellPrice or 0
    end
    return m
end

function config.getSprinklerPrice(boughtCount)
    boughtCount = boughtCount or 0
    local price = config.SPRINKLER_PRICE * ((config.SPRINKLER_PRICE_GROWTH or 1) ^ boughtCount)
    return math.floor(price + 0.5)
end



config.TOOLS = {
    { id = "hoe", name = "Hoe", iconKey = "HoeIcon", key = "1" },
    { id = "seed", name = "Seed", iconKey = "SeedsIcon", key = "2" },
    { id = "water", name = "Watering Can", iconKey = "WateringCanIcon", key = "3" },
    { id = "hand", name = "Hand", iconKey = "HandIcon", key = "4" },
    { id = "sprinkler", name = "Sprinkler", iconKey = "SprinklerIcon", key = "5" }
}

function config.resolveToolIcons()
    for _, tool in ipairs(config.TOOLS) do
        if tool.iconKey and assets[tool.iconKey] then
            tool.icon = assets[tool.iconKey]
        end
    end
end



return config

