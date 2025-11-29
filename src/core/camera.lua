local Camera = {}
Camera.__index = Camera

local push = require("libs/push")

function Camera.new()
    local self = setmetatable({}, Camera)
    self.x = 0
    self.y = 0
    self.scale = 1
    self.minScale = 0.25
    self.maxScale = 4
    self.dragging = false
    self.dragStartMouse = {0,0}
    self.dragStartCam = {0,0}
    return self
end

function Camera:attach()
    local sw, sh = push:getWidth(), push:getHeight()
    love.graphics.push()
    love.graphics.translate(sw/2, sh/2)
    love.graphics.scale(self.scale, self.scale)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:detach()
    love.graphics.pop()
end

function Camera:screenToWorld(sx, sy)
    local sw, sh = push:getWidth(), push:getHeight()
    local wx = (sx - sw/2) / self.scale + self.x
    local wy = (sy - sh/2) / self.scale + self.y
    return wx, wy
end

function Camera:worldToScreen(wx, wy)
    local sw, sh = push:getWidth(), push:getHeight()
    local sx = (wx - self.x) * self.scale + sw/2
    local sy = (wy - self.y) * self.scale + sh/2
    return sx, sy
end


function Camera:mousepressed(x, y, button)
    if button == 2 then
        self.dragging = true
        self.dragStartMouse[1], self.dragStartMouse[2] = x, y
        self.dragStartCam[1], self.dragStartCam[2] = self.x, self.y
    end
end

function Camera:mousereleased(x, y, button)
    if button == 2 then
        self.dragging = false
    end
end

function Camera:mousemoved(x, y, dx, dy)
    if self.dragging then

        local sx0, sy0 = self.dragStartMouse[1], self.dragStartMouse[2]
        local sx, sy = x, y
        local worldDx = (sx0 - sx) / self.scale
        local worldDy = (sy0 - sy) / self.scale
        self.x = self.dragStartCam[1] + worldDx
        self.y = self.dragStartCam[2] + worldDy
    end
end


function Camera:wheelmoved(wx, wy)
    if wy == 0 then return end
    local oldScale = self.scale
    local zoomFactor = 1.06
    if wy > 0 then
        self.scale = math.min(self.scale * zoomFactor, self.maxScale)
    else
        self.scale = math.max(self.scale / zoomFactor, self.minScale)
    end
    local sw, sh = push:getWidth(), push:getHeight()
    local mx, my = push:toGame(love.mouse.getPosition())
    if not mx then
        mx, my = sw/2, sh/2
    end
    
    local worldBeforeX = (mx - sw/2) / oldScale + self.x
    local worldBeforeY = (my - sh/2) / oldScale + self.y
    
    self.x = worldBeforeX - (mx - sw/2) / self.scale
    self.y = worldBeforeY - (my - sh/2) / self.scale
end

return {
    new = Camera.new
}
