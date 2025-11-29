local config = require("src/config")
local farm = require("src/core/farm")
local assets = require("src/systems/assets")
local CustomCursor = require("src/ui/customCursor")
local hotbar = {}

function hotbar.load(opts)
    opts = opts or {}

    hotbar.slots = #config.TOOLS
    hotbar.size = 48
    hotbar.margin = 12
    hotbar.spacing = 8
    hotbar.top = hotbar.margin

    hotbar.selected = 1
    hotbar.items = {}

    local tools = config.TOOLS
    if tools then
        for i = 1, hotbar.slots do
            hotbar.items[i] = tools[i]
        end
    end

    hotbar.updateLayout()
end

function hotbar.updateLayout()
    local sw = love.graphics.getWidth()
    local totalW = hotbar.slots * hotbar.size + (hotbar.slots - 1) * hotbar.spacing
    hotbar.x = math.floor(sw - hotbar.margin - totalW + 0.5)
    hotbar.y = hotbar.top
end

function hotbar.update(dt)
    local mx, my = love.mouse.getPosition()
    local panelW = hotbar.slots * hotbar.size + (hotbar.slots - 1) * hotbar.spacing + 12
    local panelX = hotbar.x - 6
    local panelY = hotbar.y - 6
    local panelH = hotbar.size + 12

    if mx >= panelX and mx <= panelX + panelW and my >= panelY and my <= panelY + panelH then
        for i = 1, hotbar.slots do
            local x = hotbar.x + (i - 1) * (hotbar.size + hotbar.spacing)
            local y = hotbar.y
            local w = hotbar.size
            local h = hotbar.size
            local item = hotbar.items[i]
            if item and mx >= x and mx <= x + w and my >= y and my <= y + h then
                CustomCursor.setHover(true)
                return
            end
        end
    end
end

function hotbar.draw()
    love.graphics.push()
    love.graphics.origin()

    local panelW = hotbar.slots * hotbar.size + (hotbar.slots - 1) * hotbar.spacing + 12
    love.graphics.setColor(0.2, 0.2, 0.2, 0.6)
    love.graphics.rectangle("fill", hotbar.x - 6, hotbar.y - 6, panelW, hotbar.size + 12, 6, 6)
    love.graphics.setColor(1, 1, 1, 1)

    for i = 1, hotbar.slots do
        local x = hotbar.x + (i - 1) * (hotbar.size + hotbar.spacing)
        local y = hotbar.y
        local isSel = (i == hotbar.selected)

        if assets.HotbarSlot then
            local iw, ih = assets.HotbarSlot:getWidth(), assets.HotbarSlot:getHeight()
            local slotScale = math.min(hotbar.size / iw, hotbar.size / ih)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(assets.HotbarSlot, x + hotbar.size / 2, y + hotbar.size / 2, 0, slotScale, slotScale, iw / 2, ih / 2)
        end

        if isSel and assets.HotbarSlotSelected then
            local iw2, ih2 = assets.HotbarSlotSelected:getWidth(), assets.HotbarSlotSelected:getHeight()
            local selScale = math.min(hotbar.size / iw2, hotbar.size / ih2)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(assets.HotbarSlotSelected, x + hotbar.size / 2, y + hotbar.size / 2, 0, selScale, selScale, iw2 / 2, ih2 / 2)
        end

        local item = hotbar.items[i]
        if item then
            if item.icon and type(item.icon) == "userdata" then
                local iw, ih = item.icon:getWidth(), item.icon:getHeight()
                local maxSize = hotbar.size - 8
                local iconScale = math.min(maxSize / iw, maxSize / ih)
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(item.icon, x + hotbar.size / 2, y + hotbar.size / 2, 0, iconScale, iconScale, iw / 2, ih / 2)

            end
        end


        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.print(tostring(i), x + 4, y + 4)

        if isSel and item and item.name then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(item.name, x, y + hotbar.size + 4)
        end
    end

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function hotbar.setItem(slot, item)
    if slot >= 1 and slot <= hotbar.slots then
        hotbar.items[slot] = item
    end
end

function hotbar.getSelected()
    return hotbar.selected, hotbar.items[hotbar.selected]
end

function hotbar.selectTool(toolId)
    if not toolId then return end
    for i = 1, hotbar.slots do
        local item = hotbar.items[i]
        if item and item.id == toolId then
            hotbar.selected = i
            if farm and farm.setTool then farm.setTool(toolId) end
            break
        end
    end
end

function hotbar.mousepressed(mx, my, button)
    if button ~= 1 then return false end

    local panelW = hotbar.slots * hotbar.size + (hotbar.slots - 1) * hotbar.spacing + 12
    local panelX = hotbar.x - 6
    local panelY = hotbar.y - 6
    local panelH = hotbar.size + 12
    if mx >= panelX and mx <= panelX + panelW and my >= panelY and my <= panelY + panelH then
        for i = 1, hotbar.slots do
            local x = hotbar.x + (i - 1) * (hotbar.size + hotbar.spacing)
            local y = hotbar.y
            local w = hotbar.size
            local h = hotbar.size
            if mx >= x and mx <= x + w and my >= y and my <= y + h then
                local item = hotbar.items[i]
                if item and item.id then
                    hotbar.selected = i
                    if farm and farm.setTool then farm.setTool(item.id) end
                end
                return true
            end
        end
        return true
    end
    return false
end

return hotbar
