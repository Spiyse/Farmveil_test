local gridUtils = {}

local config = require("src/config")

local function centerIndex()
    return math.floor(config.GRID_WIDTH / 2) + 1, math.floor(config.GRID_HEIGHT / 2) + 1
end

function gridUtils.isInside(i, j)
    if not i or not j then return false end
    local ci, cj = centerIndex()
    local dx = i - ci
    local dy = j - cj
    return (dx * dx + dy * dy) <= (config.RADIUS * config.RADIUS)
end

function gridUtils.gridToScreen(i, j)
    local ci, cj = centerIndex()
    local x = (i - ci) * config.TILE_SIZE - config.TILE_SIZE / 2
    local y = (j - cj) * config.TILE_SIZE - config.TILE_SIZE / 2
    return x, y
end

function gridUtils.screenToGrid(x, y)
    local ci, cj = centerIndex()
    local i = ci + math.floor((x + config.TILE_SIZE / 2) / config.TILE_SIZE)
    local j = cj + math.floor((y + config.TILE_SIZE / 2) / config.TILE_SIZE)
    if i < 1 or i > config.GRID_WIDTH or j < 1 or j > config.GRID_HEIGHT then
        return nil, nil
    end
    if not gridUtils.isInside(i, j) then
        return nil, nil
    end
    return i, j
end

function gridUtils.isValidTile(i, j)
    if not i or not j then return false end
    if i < 1 or i > config.GRID_WIDTH or j < 1 or j > config.GRID_HEIGHT then
        return false
    end
    return gridUtils.isInside(i, j)
end

return gridUtils
