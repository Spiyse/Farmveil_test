local hoverOver = {}

local config = require("src/config")
local gridUtils = require("src/utils/gridUtils")
local assets = require("src/systems/assets")


local farm = nil
local mouseX, mouseY = 0, 0
local TOOLTIP_PADDING = 6
local TOOLTIP_OFFSET_X = 12
local TOOLTIP_OFFSET_Y = 12

function hoverOver.init(farmModule)
    farm = farmModule
end

function hoverOver.load()
    
end

function hoverOver.update(dt)
    mouseX, mouseY = love.mouse.getPosition()
end

function hoverOver.drawWorld()
    if not farm then return end

    local i, j = farm.hoverTileX, farm.hoverTileY
    if not (i and j) then return end

    local hx, hy = gridUtils.gridToScreen(i, j)
    local tile = farm.getTile(i, j)
    if not tile then return end


    if tile.unlocked == true then
        love.graphics.setColor(1, 1, 1, 0.95)
    elseif tile.unlocked == false then
        love.graphics.setColor(1, 1, 1, 0.95)
        if assets.TileHoverLock then love.graphics.draw(assets.TileHoverLock, hx, hy) end
        love.graphics.setColor(1, 0.2, 0.1, 0.95)
    end
    if assets.TileHoverOutline then
        love.graphics.draw(assets.TileHoverOutline, hx, hy)
    end

    love.graphics.setColor(1,1,1,1)
end


function hoverOver.drawUI()
    if not farm then return end

    local i, j = farm.hoverTileX, farm.hoverTileY
    if not (i and j) then return end

    local tile = farm.getTile(i, j)
    if not tile then return end

    
    local text
    if tile.state == "ready" then
        text = "Ready"
    elseif tile.state == "planted" then
        local growth = tile.growth or 0
        local def = tile.crop and config.getSeedById(tile.crop)
        local growTime = (def and def.growTime) or config.GROW_TIME
        local remaining = math.max(0, growTime - growth)
        text = string.format("%.1fs", remaining)
    elseif tile.unlocked == false then
        local dx = (farm.hoverTileX - config.CENTER_X)
        local dy = (farm.hoverTileY - config.CENTER_Y)
        local dist = math.sqrt(dx*dx + dy*dy)
        local base = 10
        local mult = 5
        local cost = base + math.floor(dist) * mult
        text = "Locked - Buy: " .. tostring(cost)
    elseif tile.centerTile then
        text = "Center"
    end

    if not text then return end

    love.graphics.push()
    love.graphics.origin()
    love.graphics.setScissor()
    love.graphics.setColor(1,1,1,1)

    local padding = TOOLTIP_PADDING
    local font = love.graphics.getFont()
    local w = (font and font:getWidth(text) or 30) + padding * 2
    local h = (font and font:getHeight() or 12) + padding * 2
    local rectX = mouseX + (TOOLTIP_OFFSET_X)
    local rectY = mouseY + (TOOLTIP_OFFSET_Y)

    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    if rectX + w > sw then rectX = mouseX - w - 12 end
    if rectY + h > sh then rectY = mouseY - h - 12 end

    rectX = math.floor(rectX + 0.5)
    rectY = math.floor(rectY + 0.5)

    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", rectX, rectY, w, h, 4, 4)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", rectX + 0.5, rectY + 0.5, w - 1, h - 1, 4, 4)

    love.graphics.print(text, rectX + padding, rectY + padding)

    love.graphics.pop()
    love.graphics.setColor(1,1,1,1)
end

return hoverOver
