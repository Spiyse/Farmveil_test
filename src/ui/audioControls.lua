local audioControls = {}

local audio = require("src/systems/audio")
local CustomCursor = require("src/ui/customCursor")
local assets = require("src/systems/assets")

local BUTTON_SIZE = 32
local BUTTON_SPACING = 4
local PANEL_PADDING = 2

local NUM_BUTTONS = 2


local PANEL_W = BUTTON_SIZE + PANEL_PADDING * 2
local PANEL_H = PANEL_PADDING * 2 + BUTTON_SIZE * NUM_BUTTONS + BUTTON_SPACING * (NUM_BUTTONS - 1)
local PANEL_MARGIN = 4

local function getPanelRect()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local x = sw - PANEL_W - PANEL_MARGIN
    local y = sh - PANEL_H - PANEL_MARGIN
    return x, y, PANEL_W, PANEL_H
end

local function getButtonRect(rowIndex)
    local panelX, panelY = getPanelRect()
    local x = panelX + PANEL_PADDING
    local y = panelY + PANEL_PADDING + (rowIndex - 1) * (BUTTON_SIZE + BUTTON_SPACING)
    return x, y, BUTTON_SIZE, BUTTON_SIZE
end

local function isPointInRect(px, py, x, y, w, h)
    return px >= x and px <= x + w and py >= y and py <= y + h
end

function audioControls.load() end

function audioControls.update(dt)
    local mx, my = love.mouse.getPosition()

    local over = false
    for row = 1, NUM_BUTTONS do
        local bx, by, bw, bh = getButtonRect(row)
        if isPointInRect(mx, my, bx, by, bw, bh) then
            over = true
            break
        end
    end

    CustomCursor.setHover(over)
end

function audioControls.draw()
    love.graphics.push()
    love.graphics.origin()


    local musicOn = not audio.isMusicMuted()
    local sfxOn = not audio.isSfxMuted()

    local mx, my = love.mouse.getPosition()

    for row = 1, NUM_BUTTONS do
        local bx, by, bw, bh = getButtonRect(row)
        local hovered = isPointInRect(mx, my, bx, by, bw, bh)

        if hovered then
            love.graphics.setColor(1, 1, 1, 0.1)
            love.graphics.rectangle("fill", bx, by, bw, bh, 4, 4)
            love.graphics.setColor(1, 1, 1, 1)
        end

        local icon
        if row == 1 then
            icon = musicOn and assets.MusicOnIcon or assets.MusicOffIcon
        elseif row == 2 then
            icon = sfxOn and assets.SfxOnIcon or assets.SfxOffIcon
        end

        if icon then
            local iw, ih = icon:getWidth(), icon:getHeight()
            local drawX = bx + (bw - iw) / 2
            local drawY = by + (bh - ih) / 2
            love.graphics.draw(icon, drawX, drawY)
        end
    end

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function audioControls.mousepressed(mx, my, button)
    if button ~= 1 then return false end

    local px, py, pw, ph = getPanelRect()
    if not isPointInRect(mx, my, px, py, pw, ph) then
        return false
    end

    do
        local bx, by, bw, bh = getButtonRect(1)
        if isPointInRect(mx, my, bx, by, bw, bh) then
            audio.toggleMusicMute()
            return true
        end
    end
    do
        local bx, by, bw, bh = getButtonRect(2)
        if isPointInRect(mx, my, bx, by, bw, bh) then
            audio.toggleSfxMute()
            return true
        end
    end

    return true
end

return audioControls
