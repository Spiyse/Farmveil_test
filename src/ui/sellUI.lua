local sellUI = {}

local player = require("src/core/player")
local config = require("src/config")
local CustomCursor = require("src/ui/customCursor")
local assets = require("src/systems/assets")

local CLICK_FLASH_TIME = 0.12

sellUI.open = false
sellUI.hoveredButton = nil
sellUI.pressedButton = nil
sellUI.pressedTimer = 0

local function buttonSize()
    if assets.Button and assets.Button.getWidth then
        return assets.Button:getWidth(), assets.Button:getHeight()
    end
    return 80, 25
end

local function drawButton(x, y, label, isHovered, isPressed)
    local sprite = assets.Button
    if isPressed and assets.ButtonActive then
        sprite = assets.ButtonActive
    end

    if sprite then
        local iw, ih = sprite:getWidth(), sprite:getHeight()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(sprite, x, y)
        if isHovered and not isPressed then
            love.graphics.setColor(1, 1, 1, 0.08)
            love.graphics.rectangle("fill", x, y, iw, ih, 4, 4)
        end
    else
        local w, h = buttonSize()
        local r, g, b = 0.9, 0.7, 0.2
        if isPressed then
            r, g, b = 0.6, 0.45, 0.12
        elseif isHovered then
            r, g, b = 1, 0.82, 0.3
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", x, y, w, h, 4, 4)
    end

    love.graphics.setColor(0, 0, 0, 1)
    local w, h = buttonSize()
    love.graphics.printf(label, x, y + (h - love.graphics.getFont():getHeight()) / 2, w, "center")
    love.graphics.setColor(1, 1, 1, 1)
end

function sellUI.toggle()
    sellUI.open = not sellUI.open
end

function sellUI.isOpen() return sellUI.open end

function sellUI.load() end
function sellUI.update(dt)
    if sellUI.pressedTimer > 0 then
        sellUI.pressedTimer = sellUI.pressedTimer - dt
        if sellUI.pressedTimer <= 0 then
            sellUI.pressedTimer = 0
            sellUI.pressedButton = nil
        end
    end

    if not sellUI.open then
        sellUI.hoveredButton = nil
        return
    end

    sellUI.hoveredButton = nil
    local mx, my = love.mouse.getPosition()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local w, h = 300, 200
    local x, y = sw - w - 12, 12
    local bw, bh = buttonSize()
    local sx = x + 12
    local sy = y + h - 36

    if mx >= sx and mx <= sx + bw and my >= sy and my <= sy + bh then
        sellUI.hoveredButton = "sellAll"
    end

    CustomCursor.setHover(sellUI.hoveredButton ~= nil)
end

function sellUI.draw()
    if not sellUI.open then return end
    love.graphics.push()
    love.graphics.origin()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local w, h = 300, 200
    local x, y = sw - w - 12, 12
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x, y, w, h, 6, 6)
    love.graphics.setColor(0.4, 0.4, 0.4, 0.7)
    love.graphics.rectangle("fill",x + 8, y + 8, 30, 15 , 4)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Sell", x + 8, y + 8)


    local rowY = y + 54
    for _, s in ipairs(config.SEED_TYPES) do
        local count = player.crops[s.id] or 0
        local label = string.format("%s  x%d  (%d ea)", s.name, count, s.sellPrice or 0)
        love.graphics.print(label, x + 12, rowY)
        rowY = rowY + 22
    end

    local hovered = sellUI.hoveredButton == "sellAll"
    local pressed = sellUI.pressedButton == "sellAll"
    drawButton(x + 12, y + h - 36, "Sell All", hovered, pressed)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function sellUI.mousepressed(mx, my, button)
    if not sellUI.open or button ~= 1 then return false end
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local w, h = 300, 200
    local x, y = sw - w - 12, 12
    if mx < x or mx > x + w or my < y or my > y + h then
        return false
    end
    local bw, bh = buttonSize()
    local sx = x + 12
    local sy = y + h - 36
    if mx >= sx and mx <= sx + bw and my >= sy and my <= sy + bh then
        local priceMap = config.getSellPriceMap()
        sellUI.pressedButton = "sellAll"
        sellUI.pressedTimer = CLICK_FLASH_TIME
        player.sellAllCrops(priceMap)
        return true
    end
    return true
end

return sellUI
