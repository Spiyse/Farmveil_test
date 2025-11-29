local assets = {}

function assets.load()
    assets.grassImage = love.graphics.newImage("assets/sprites/tile_stuff/grass_test.png")
    assets.dirtImage  = love.graphics.newImage("assets/sprites/tile_stuff/dirt_test.png")
    assets.seedsImage = love.graphics.newImage("assets/sprites/icons/seeds_test.png")

    assets.Sprinkler = love.graphics.newImage("assets/sprites/tile_stuff/sprinkler.png")


    assets.Button = love.graphics.newImage("assets/sprites/button/button.png")
    assets.ButtonActive = love.graphics.newImage("assets/sprites/button/button_active.png")
    assets.button = assets.Button
    assets.buttonActive = assets.ButtonActive

    local function loadCropSet(folder, prettyName)
        local base = "assets/sprites/" .. folder .. "/"
        local function img(file)
            return love.graphics.newImage(base .. file)
        end

        return {
            seed   = img("1 - " .. prettyName .. " Seed.png"),
            sprout = img("2 - " .. prettyName .. " Sprout.png"),
            mid    = img("3 - " .. prettyName .. " Mid.png"),
            full   = img("4 - " .. prettyName .. " Full.png"),
            wilt   = img("5 - " .. prettyName .. " Wilt.png")
        }
    end

    assets.cropSets = {
        wheat = loadCropSet("Wheat", "Wheat"),
        potato = loadCropSet("Potato", "Potato"),
        tomato = loadCropSet("Tomato", "Tomato"),
        pumpkin = loadCropSet("Pumpkin", "Pumpkin")
    }

    assets.wheatImage = assets.cropSets.wheat.full
    assets.flagImage = love.graphics.newImage("assets/sprites/tile_stuff/flag.png")
    assets.TileHoverLock = love.graphics.newImage("assets/sprites/tile_stuff/lock.png")
    assets.TileHoverOutline = love.graphics.newImage("assets/sprites/tile_stuff/hover_tile_outline.png")
    assets.WaterDrop = love.graphics.newImage("assets/sprites/tile_stuff/water_drop.png")

    assets.cursorNormal = love.graphics.newImage("assets/sprites/curosr/cursor.png")
    assets.cursorGray = love.graphics.newImage("assets/sprites/curosr/cursor_gray.png")
    assets.cursorHover = love.graphics.newImage("assets/sprites/curosr/cursor_yellowish.png")


    assets.MusicOnIcon = love.graphics.newImage("assets/sprites/icons/music_on_icon.png")
    assets.MusicOffIcon = love.graphics.newImage("assets/sprites/icons/music_off_icon_V2.png")
    assets.SfxOnIcon = love.graphics.newImage("assets/sprites/icons/sfx_on_icon.png")
    assets.SfxOffIcon = love.graphics.newImage("assets/sprites/icons/sfx_off_icon.png")

    assets.HotbarSlotSelected = love.graphics.newImage("assets/sprites/hotbar/hotbar_slot_selected.png")
    assets.HotbarSlot = love.graphics.newImage("assets/sprites/hotbar/hotbar_slot.png")
    assets.HoeIcon = love.graphics.newImage("assets/sprites/icons/hoe.png")
    assets.SeedsIcon = love.graphics.newImage("assets/sprites/icons/seeds_test.png")
    assets.WateringCanIcon = love.graphics.newImage("assets/sprites/icons/watering_can.png")
    assets.HandIcon = love.graphics.newImage("assets/sprites/icons/hand.png")
    assets.SprinklerIcon = love.graphics.newImage("assets/sprites/icons/sprinkler.png")
end

function assets.getCropImage(id, stage)
    stage = stage or "full"
    local set = assets.cropSets and assets.cropSets[id]
    if set and set[stage] then return set[stage] end
    if set and set.full then return set.full end
    return assets.wheatImage
end

return assets
