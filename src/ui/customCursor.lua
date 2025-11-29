local CustomCursor = {}

local config = require("src/config")
local assets = require("src/systems/assets")

local mouseX, mouseY = 0, 0
local clickTimer = 0
local hovering = false
local hoverRequested = false
local activeCursor = nil

local CURSOR_CLICK_DURATION = 0.1

function CustomCursor.load()
    love.mouse.setVisible(false)
    activeCursor = assets.cursorNormal
end

function CustomCursor.update(dt)
    mouseX, mouseY = love.mouse.getPosition()
    if clickTimer > 0 then
        clickTimer = clickTimer - dt
        if clickTimer <= 0 then
            clickTimer = 0
            activeCursor = assets.cursorNormal
        end
    end

    hovering = hoverRequested
    hoverRequested = false
end

function CustomCursor.draw()
    local img = activeCursor
    local r, g, b = 1, 1, 1
    if clickTimer <= 0 then
        if hovering then
            if assets.cursorHover then
                img = assets.cursorHover
            else
                r, g, b = 1, 0.9, 0.3
                img = assets.cursorNormal
            end
        else
            img = assets.cursorNormal
        end
    end
    love.graphics.setColor(r, g, b, 1)
    love.graphics.draw(img, mouseX, mouseY)
    love.graphics.setColor(1, 1, 1, 1)
end

function CustomCursor.mousepressed(x, y, button)
    if button ~= 1 then return end
    if assets.cursorGray then activeCursor = assets.cursorGray end
    clickTimer = CURSOR_CLICK_DURATION
end

function CustomCursor.setHover(isHover)
    hoverRequested = hoverRequested or not not isHover
end

return CustomCursor
