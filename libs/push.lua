local push = {}

local safeFloor = math.floor

local gameW, gameH = 320, 180
local winW, winH = 320, 180
local scaleX, scaleY = 1, 1
local offsetX, offsetY = 0, 0
local borderColor = {0, 0, 0, 1}
local pixelperfect = true
local stretched = false
local native = false

local function recompute()
    if native then
        gameW, gameH = winW, winH
        scaleX, scaleY = 1, 1
        offsetX, offsetY = 0, 0
        return
    end
    if stretched then
        scaleX = winW / gameW
        scaleY = winH / gameH
        offsetX, offsetY = 0, 0
        return
    end
    local sx = winW / gameW
    local sy = winH / gameH
    local s
    if pixelperfect then
        s = math.max(1, math.floor(math.min(sx, sy)))
    else
        s = math.min(sx, sy)
    end
    scaleX, scaleY = s, s
    local drawW = gameW * scaleX
    local drawH = gameH * scaleY
    offsetX = safeFloor((winW - drawW) / 2)
    offsetY = safeFloor((winH - drawH) / 2)
end

function push:setupScreen(gw, gh, ww, wh, opts)
    gameW, gameH = gw, gh
    winW, winH = ww, wh
    opts = opts or {}
    pixelperfect = opts.pixelperfect ~= false
    stretched = opts.stretched == true
    native = opts.native == true
    recompute()
end

function push:start()
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scaleX, scaleY)
end

function push:finish()
    love.graphics.pop()
    if not stretched and not native and (offsetX > 0 or offsetY > 0) then
        love.graphics.push()
        love.graphics.origin()
        love.graphics.setColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
        -- left
        love.graphics.rectangle("fill", 0, 0, offsetX, winH)
        -- right
        love.graphics.rectangle("fill", winW - offsetX, 0, offsetX, winH)
        -- top
        love.graphics.rectangle("fill", offsetX, 0, winW - offsetX * 2, offsetY)
        -- bottom
        love.graphics.rectangle("fill", offsetX, winH - offsetY, winW - offsetX * 2, offsetY)
        love.graphics.pop()
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function push:apply(op)
    if op == "start" then return self:start() end
    if op == "end" or op == "finish" then return self:finish() end
end

function push:resize(w, h)
    winW, winH = w, h
    if native then
        gameW, gameH = winW, winH
    end
    recompute()
end

function push:getDimensions()
    return gameW, gameH
end

function push:getWidth() return gameW end
function push:getHeight() return gameH end

function push:setBorderColor(r, g, b, a)
    if type(r) == "table" then
        borderColor = r
    else
        borderColor = {r or 0, g or 0, b or 0, a or 1}
    end
end

function push:toGame(x, y)
    local gx = (x - offsetX) / scaleX
    local gy = (y - offsetY) / scaleY
    if gx < 0 or gy < 0 or gx > gameW or gy > gameH then return nil, nil end
    return gx, gy
end

function push:toReal(x, y)
    local rx = x * scaleX + offsetX
    local ry = y * scaleY + offsetY
    return rx, ry
end

function push:getWindowDimensions()
    return winW, winH
end

function push:isNative()
    return native
end


return push

