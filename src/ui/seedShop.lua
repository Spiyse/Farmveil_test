local shop = {}

local player = require("src/core/player")
local config = require("src/config")
local CustomCursor = require("src/ui/customCursor")
local assets = require("src/systems/assets")

local CLICK_FLASH_TIME = 0.12

shop.open = false
shop.hoveredButton = nil
shop.pressedButton = nil
shop.pressedTimer = 0

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
        local r, g, b = 0.2, 0.8, 0.3
        if isPressed then
            r, g, b = 0.12, 0.55, 0.18
        elseif isHovered then
            r, g, b = 0.28, 0.88, 0.38
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", x, y, w, h, 4, 4)
    end

    love.graphics.setColor(0, 0, 0, 1)
    local w, h = buttonSize()
    love.graphics.printf(label, x, y + (h - love.graphics.getFont():getHeight()) / 2, w, "center")
    love.graphics.setColor(1, 1, 1, 1)
end

function shop.toggle()
    shop.open = not shop.open
end

function shop.isOpen()
    return shop.open
end

function shop.load()
end

function shop.update(dt)
    if shop.pressedTimer > 0 then
        shop.pressedTimer = shop.pressedTimer - dt
        if shop.pressedTimer <= 0 then
            shop.pressedTimer = 0
            shop.pressedButton = nil
        end
    end

    if not shop.open then
        shop.hoveredButton = nil
        return
    end

    shop.hoveredButton = nil
    local mx, my = love.mouse.getPosition()
    local sw = love.graphics.getWidth()
    local x = 12
    local y = 12
    local w = math.min(300, sw - 24)

    local bw, bh = buttonSize()
    local rowY = y + 54
    for _, s in ipairs(config.SEED_TYPES) do
        local bx = x + w - bw - 12
        local by = rowY - 2
        if mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
            shop.hoveredButton = "seed:" .. s.id
            break
        end
        rowY = rowY + 26
    end

    if not shop.hoveredButton then
        rowY = rowY + 8
        local btnY = rowY + 22
        local sbx = x + w - bw - 12
        local sby = btnY - 2
        if mx >= sbx and mx <= sbx + bw and my >= sby and my <= sby + bh then
            shop.hoveredButton = "sprinkler"
        end
    end

    CustomCursor.setHover(shop.hoveredButton ~= nil)
end

function shop.draw()
    if not shop.open then return end
    love.graphics.push()
    love.graphics.origin()
    local sw = love.graphics.getWidth()
    local x = 12
    local y = 12
    local w = math.min(300, sw - 24)
    local h = 230
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x, y, w, h, 6, 6)
    love.graphics.setColor(0.4, 0.4, 0.4, 0.7)
    love.graphics.rectangle("fill",x + 8, y + 8, 35, 15, 4 )
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Shop", x + 8, y + 8)

    local rowY = y + 54
    for _, s in ipairs(config.SEED_TYPES) do
        local label = s.name .. " - " .. tostring(s.price) .. " coins"
        love.graphics.print(label, x + 12, rowY)
        local btnId = "seed:" .. s.id
        local hovered = shop.hoveredButton == btnId
        local pressed = shop.pressedButton == btnId
        local bw, bh = buttonSize()
        drawButton(x + w - bw - 12, rowY - 2, "Buy", hovered, pressed)
        rowY = rowY + 26
    end

    rowY = rowY + 8
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Sprinklers", x + 8, rowY)
    rowY = rowY + 22
    local sprinklerPrice = config.getSprinklerPrice(player.getSprinklerPurchases())
    local sprinklerLabel = "Basic Sprinkler - " .. tostring(sprinklerPrice) .. " coins"
    love.graphics.print(sprinklerLabel, x + 12, rowY)
    local sHovered = shop.hoveredButton == "sprinkler"
    local sPressed = shop.pressedButton == "sprinkler"
    local bw, bh = buttonSize()
    drawButton(x + w - bw - 12, rowY - 2, "Buy", sHovered, sPressed)
    love.graphics.print("Owned: " .. tostring(player.sprinklers or 0), x + 12, rowY + 20)

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function shop.mousepressed(mx, my, button)
    if not shop.open or button ~= 1 then return false end
    local sw = love.graphics.getWidth()
    local x = 12
    local y = 12
    local w = math.min(300, sw - 24)
    local h = 230
    if mx < x or mx > x + w or my < y or my > y + h then
        return false
    end
    local bw, bh = buttonSize()
    local rowY = y + 54
    for _, s in ipairs(config.SEED_TYPES) do
        local bx = x + w - bw - 12
        local by = rowY - 2
        if mx >= bx and mx <= bx + bw and my >= by and my <= by + bh then
            shop.pressedButton = "seed:" .. s.id
            shop.pressedTimer = CLICK_FLASH_TIME
            if player.spendCoins(s.price) then
                player.addSeeds(s.id, 1)
            end
            return true
        end
        rowY = rowY + 26
    end

    rowY = rowY + 8
    local btnY = rowY + 22
    local sbx = x + w - bw - 12
    local sby = btnY - 2
    if mx >= sbx and mx <= sbx + bw and my >= sby and my <= sby + bh then
        local sprinklerPrice = config.getSprinklerPrice(player.getSprinklerPurchases())
        shop.pressedButton = "sprinkler"
        shop.pressedTimer = CLICK_FLASH_TIME
        if player.spendCoins(sprinklerPrice) then
            player.buySprinklers(1)
        end
        return true
    end

    return true
end

return shop
