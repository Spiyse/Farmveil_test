local input = {}

local config = require("src/config")
local hotbar = require("src/ui/hotbar")
local shop = require("src/ui/seedShop")
local sellUI = require("src/ui/sellUI")
local push = require("libs/push")
local farm = nil

function input.init(farmModule)
    farm = farmModule
end

function input.keypressed(key)
    if not farm then return end
    
    for _, tool in ipairs(config.TOOLS) do
        if key == tool.key then
            farm.setTool(tool.id)
            hotbar.selectTool(tool.id)
            return
        end
    end

    if key == "b" then
        shop.toggle()
        return
    end

    if key == "v" then
        sellUI.toggle()
        return
    end
end

return input
