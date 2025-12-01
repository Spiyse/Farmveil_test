local push = require("libs/push")
local assets = require("src/systems/assets")
local audio = require("src/systems/audio")
local farm = require("src/core/farm")
local input = require("src/systems/input")
local config = require("src/config")
local player = require("src/core/player")

local customCursor = require("src/ui/customCursor")
local hoverOver = require("src/ui/hoverOver")
local hotbar = require("src/ui/hotbar")
local inventory = require("src/ui/inventory")
local seedShop = require("src/ui/seedShop")
local sellUI = require("src/ui/sellUI")
local audioControls = require("src/ui/audioControls")

local Camera = require("src/core/camera")
local camera = Camera.new()

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local gw, gh = love.graphics.getWidth(), love.graphics.getHeight()
    local ww, wh = love.graphics.getWidth(), love.graphics.getHeight()
    push:setupScreen(gw, gh, ww, wh, { resizable = true, native = true })
    assets.load()
    config.resolveToolIcons()
    audio.load()
    farm.load()
    
    
    hoverOver.init(farm)
    input.init(farm)

    camera.x, camera.y = 0, 0

    hotbar.load()
    inventory.load()
    seedShop.load()
    sellUI.load()
    audioControls.load()
    customCursor.load()
    
end

function love.update(dt)
    local mx, my = love.mouse.getPosition()
    local gx, gy = push:toGame(mx, my)
    if gx then
        local wx, wy = camera:screenToWorld(gx, gy)
        farm.mousemoved(wx, wy, 0, 0)
    end
    farm.update(dt)
    hoverOver.update(dt)
    hotbar.update(dt)
    inventory.update(dt)
    seedShop.update(dt)
    sellUI.update(dt)
    audioControls.update(dt)
    customCursor.update(dt)
    
end

function love.draw()
    push:start()
    camera:attach()
    farm.draw()
    hoverOver.drawWorld()
    camera:detach()
    push:finish()

    hoverOver.drawUI()
    hotbar.draw()
    inventory.draw()
    seedShop.draw()
    sellUI.draw()
    audioControls.draw()
    customCursor.draw()
    love.graphics.setColor(1,1,1,0.85)
    love.graphics.print("B: Shop   V: Sell", 12, 12)
    love.graphics.setColor(1,1,1,1)
    
end

function love.mousepressed(x, y, button)
    local uiHandled = false
    if audioControls.mousepressed(x, y, button) then uiHandled = true end
    if not uiHandled and hotbar.mousepressed(x, y, button) then uiHandled = true end
    if not uiHandled and inventory.mousepressed(x, y, button) then uiHandled = true end
    if not uiHandled and seedShop.mousepressed(x, y, button) then uiHandled = true end
    if not uiHandled and sellUI.mousepressed(x, y, button) then uiHandled = true end
    customCursor.mousepressed(x, y, button)
    if uiHandled then return end

    local gx, gy = push:toGame(x, y)
    if not gx then return end
    camera:mousepressed(gx, gy, button)
    local wx, wy = camera:screenToWorld(gx, gy)
    farm.mousepressed(wx, wy, button)
end

function love.mousereleased(x, y, button)
    camera:mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    local gx, gy = push:toGame(x, y)
    if not gx then return end
    camera:mousemoved(gx, gy, dx, dy)
    local wx, wy = camera:screenToWorld(gx, gy)
    farm.mousemoved(wx, wy, dx, dy)
end

function love.keypressed(key)
    input.keypressed(key)
end

function love.resize(w, h)
    push:resize(w, h)
    hotbar.updateLayout()
end

function love.wheelmoved(x, y)
    camera:wheelmoved(x, y)
end
