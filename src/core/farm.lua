local farm = {}

local config = require("src/config")
local gridUtils = require("src/utils/gridUtils")
local assets = require("src/systems/assets")
local audio = require("src/systems/audio")
local player = require("src/core/player")

local function drawCentered(img, x, y)
    if not img then return end
    local iw, ih = img:getWidth(), img:getHeight()
    local ox = math.floor((config.TILE_SIZE - iw) / 2)
    local oy = math.floor((config.TILE_SIZE - ih) / 2)
    love.graphics.draw(img, x + ox, y + oy)
end

function farm.load()
    farm.tiles = {}
    farm.waterCooldown = 0

    for j = 1, config.GRID_HEIGHT do
        farm.tiles[j] = {}
        for i = 1, config.GRID_WIDTH do
            local dx = i - config.CENTER_X
            local dy = j - config.CENTER_Y
            local dist2 = dx * dx + dy * dy
            local unlocked = dist2 <= (config.START_UNLOCK_RADIUS * config.START_UNLOCK_RADIUS)
            local centerI, centerJ = config.CENTER_X, config.CENTER_Y
            local isCenter = (i == centerI and j == centerJ)

            farm.tiles[j][i] = {
                state = isCenter and "center" or "empty",
                timer = 0,
                crop = nil,
                growth = 0,
                watered = false,
                sprinkler = false,
                unlocked = unlocked,
                centerTile = isCenter
            }
        end
    end

    farm.selectedTool = "hoe"
    farm.hoverTileX = nil
    farm.hoverTileY = nil
end

function farm.setTool(toolName)
    farm.selectedTool = toolName
end

function farm.getTile(i, j)
    if not gridUtils.isValidTile(i, j) then
        return nil
    end
    return farm.tiles[j][i]
end

function farm.update(dt)
    farm.waterCooldown = math.max(0, (farm.waterCooldown or 0) - dt)

    for j = 1, config.GRID_HEIGHT do
        for i = 1, config.GRID_WIDTH do
            if not gridUtils.isValidTile(i, j) then goto continue end

            local tile = farm.tiles[j][i]
            if tile.state == "planted" then
                local speed = tile.watered and config.WATERED_GROWTH_MULTIPLIER or 1
                local def = tile.crop and config.getSeedById(tile.crop)
                local growTime = (def and def.growTime) or config.GROW_TIME
                tile.growth = tile.growth + dt * speed
                if tile.growth >= growTime then
                    tile.state = "ready"
                    tile.growth = growTime
                    tile.watered = false
                end
            end

            ::continue::
        end
    end

    farm.applySprinklers(dt)
end

function farm.draw()
    for j = 1, config.GRID_HEIGHT do
        for i = 1, config.GRID_WIDTH do
            if not gridUtils.isValidTile(i, j) then goto continue end

            local tile = farm.tiles[j][i]
            local x, y = gridUtils.gridToScreen(i, j)

            local alt = ((i + j) % 2 == 0)
            if alt then
                love.graphics.setColor(0, 0, 0, 0.03)
                love.graphics.rectangle("fill", x, y, config.TILE_SIZE, config.TILE_SIZE)
                
            end

            if tile.unlocked then
                love.graphics.setColor(1, 1, 1, 1)
            else
                love.graphics.setColor(0.6, 0.6, 0.6, 0.95)
            end
            if tile.state == "empty" then
                love.graphics.draw(assets.grassImage, x, y)
            elseif tile.state == "hoed" then
                love.graphics.draw(assets.dirtImage, x, y)
            elseif tile.state == "planted" then
                love.graphics.draw(assets.dirtImage, x, y)
                local def = tile.crop and config.getSeedById(tile.crop)
                local stage = farm.getGrowthStage(tile, def)
                local img = assets.getCropImage(tile.crop, stage) or assets.seedsImage
                drawCentered(img, x, y)
            elseif tile.state == "ready" then
                love.graphics.draw(assets.dirtImage, x, y)
                local img = assets.getCropImage(tile.crop, "full")
                drawCentered(img, x, y)
                love.graphics.setColor(1, 1, 1)
            end

            if tile.sprinkler then
                love.graphics.setColor(0.7, 0.9, 1, 1)
                drawCentered(assets.Sprinkler, x, y)
                love.graphics.setColor(1, 1, 1)
            end

            if tile.centerTile then
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(assets.dirtImage, x, y)
                drawCentered(assets.flagImage, x, y)
            end

            if tile.watered then
                drawCentered(assets.WaterDrop, x, y)
            end


            love.graphics.setLineWidth(1)
            love.graphics.setColor(0, 0, 0, 0.15)
            love.graphics.rectangle("line", x, y, config.TILE_SIZE, config.TILE_SIZE)
            love.graphics.setLineWidth(1)


            ::continue::
        end
    end
end

function farm.mousepressed(x, y, button)
    if button ~= 1 then return end

    local i, j = gridUtils.screenToGrid(x, y)
    if not i then return end

    local tile = farm.getTile(i, j)
    if not tile or tile.centerTile then return end

    if farm.selectedTool == "hoe" then
        farm.useHoe(tile)
    elseif farm.selectedTool == "seed" then
        farm.useSeed(tile)
    elseif farm.selectedTool == "water" then
        farm.useWater(tile)
    elseif farm.selectedTool == "sprinkler" then
        farm.useSprinkler(tile)
    elseif farm.selectedTool == "hand" then
        if tile.unlocked == false then
            local dx = (i - config.CENTER_X)
            local dy = (j - config.CENTER_Y)
            local dist = math.sqrt(dx*dx + dy*dy)
            local base = 10
            local mult = 5
            local cost = base + math.floor(dist) * mult
            if player.spendWithReserve(cost) then
                tile.unlocked = true
            end
        else
            farm.useHand(tile)
        end
    end
end

function farm.mousemoved(x, y, dx, dy)
    local i, j = gridUtils.screenToGrid(x, y)
    farm.hoverTileX = i
    farm.hoverTileY = j
end


function farm.useHoe(tile)
    if tile.sprinkler then
        audio.play("hoeDirt")
        tile.sprinkler = false
        tile.sprinklerCooldown = nil
        player.addSprinklers(1)
        return
    end

    if tile.state == "empty" and tile.unlocked == true then
        audio.play("hoeDirt")
        tile.state = "hoed"
        tile.crop = nil
        tile.growth = 0
        tile.watered = false
    end
end

function farm.useSeed(tile)
    if tile.sprinkler then return end
    if tile.state == "hoed" and not tile.crop then
        local seedId = player.activeSeed
        if player.consumeSeed(seedId) then
            audio.play("plantSeeds")
            tile.state = "planted"
            tile.crop = seedId
            tile.growth = 0
            tile.watered = false
        end
    end
end

function farm.useWater(tile)
    if (farm.waterCooldown or 0) > 0 then return end
    if tile.state ~= "planted" then return end
    tile.watered = true
    farm.waterCooldown = config.WATER_COOLDOWN
end

function farm.useHand(tile)
    if tile.sprinkler then
        player.addSprinklers(1)
        tile.sprinkler = false
        return
    end

    if tile.state == "ready" then
        audio.play("pickup")
        if tile.crop then
            player.addCrop(tile.crop, 1)
        end
        tile.state = "empty"
        tile.crop = nil
        tile.growth = 0
        tile.watered = false
    end
end

function farm.useSprinkler(tile)
    if not tile.unlocked or tile.centerTile then return end
    if tile.sprinkler then return end
    if tile.state ~= "empty" and tile.state ~= "hoed" then return end
    if player.consumeSprinkler() then
        tile.sprinkler = true
        tile.sprinklerCooldown = 0
    end
end

function farm.getGrowthStage(tile, def)
    if not tile or not tile.crop then return "seed" end
    if tile.state == "ready" then return "full" end

    local growTime = (def and def.growTime) or config.GROW_TIME
    local progress = math.min(1, math.max(0, tile.growth / growTime))

    if progress < 0.2 then
        return "seed"
    elseif progress < 0.5 then
        return "sprout"
    elseif progress < 0.85 then
        return "mid"
    else
        return "full"
    end
end

function farm.waterArea(cx, cy, radius)
    radius = radius or 1
    for dj = -radius, radius do
        for di = -radius, radius do
            local ti = cx + di
            local tj = cy + dj
            local tile = farm.getTile(ti, tj)
            if tile and tile.state == "planted" then
                tile.watered = true
            end
        end
    end
end

function farm.applySprinklers(dt)
    dt = dt or 0
    for j = 1, config.GRID_HEIGHT do
        for i = 1, config.GRID_WIDTH do
            local tile = farm.tiles[j][i]
            if tile and tile.sprinkler then
                tile.sprinklerCooldown = (tile.sprinklerCooldown or 0) - dt
                if tile.sprinklerCooldown <= 0 then
                    farm.waterArea(i, j, config.SPRINKLER_RADIUS or 1)
                    tile.sprinklerCooldown = config.SPRINKLER_COOLDOWN or 2
                end
            end
        end
    end
end

return farm
