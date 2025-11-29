local inventory = {}

local player = require("src/core/player")
local config = require("src/config")
local CustomCursor = require("src/ui/customCursor")

function inventory.load()
end

function inventory.update(dt)
    local mx, my = love.mouse.getPosition()
    local x = 12
    local y = love.graphics.getHeight() - 180
    local w = 240
    local h = 168
    if mx < x or mx > x + w or my < y or my > y + h then
        return
    end

    local rowY = y + 48
    for _, s in ipairs(config.SEED_TYPES) do
        local rx = x + 6
        local ry = rowY - 2
        local rw = w - 12
        local rh = 22
        if mx >= rx and mx <= rx + rw and my >= ry and my <= ry + rh then
            CustomCursor.setHover(true)
            return
        end
        rowY = rowY + 22
    end
end

function inventory.draw()
    love.graphics.push()
    love.graphics.origin()
    local x = 12
    local y = love.graphics.getHeight() - 180
    local w = 240
    local h = 168
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", x, y, w, h, 6, 6)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Coins: " .. tostring(player.coins), x + 8, y + 8)
    love.graphics.print("Seeds:", x + 8, y + 28)

    local rowY = y + 48
    local idx = 0
    for _, s in ipairs(config.SEED_TYPES) do
        local label = s.name .. " (" .. tostring(player.seeds[s.id] or 0) .. ")"
        local isActive = (player.activeSeed == s.id)
        if isActive then
            love.graphics.setColor(0.95, 0.85, 0.2, 0.95)
            love.graphics.rectangle("fill", x + 6, rowY - 2, w - 12, 22, 4, 4)
            love.graphics.setColor(0.08, 0.08, 0.08)
            love.graphics.print(label, x + 12, rowY)
        else
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(label, x + 12, rowY)
        end
        rowY = rowY + 22
        idx = idx + 1
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Sprinklers: " .. tostring(player.sprinklers or 0), x + 8, y + h - 24)

  
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function inventory.mousepressed(mx, my, button)
    if button ~= 1 then return false end
    local x = 12
    local y = love.graphics.getHeight() - 180
    local w = 240
    local h = 168
    if mx < x or mx > x + w or my < y or my > y + h then
        return false
    end

    local rowY = y + 48
    for _, s in ipairs(config.SEED_TYPES) do
        local rx = x + 6
        local ry = rowY - 2
        local rw = w - 12
        local rh = 22
        if mx >= rx and mx <= rx + rw and my >= ry and my <= ry + rh then
            player.setActiveSeed(s.id)
            return true
        end
        rowY = rowY + 22
    end

    return true
end

return inventory
