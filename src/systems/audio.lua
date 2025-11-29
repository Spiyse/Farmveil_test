local audio = {}

local sounds = {}
local music = nil
local musicMuted = false
local sfxMuted = false
local MUSIC_VOLUME = 0.5

function audio.load()
    audio.loadSound("hoeDirt", "assets/audio/sfx/hoe_dirt.wav")
    audio.loadSound("plantSeeds", "assets/audio/sfx/plant_seed.wav")
    audio.loadSound("pickup", "assets/audio/sfx/pickup_wheat.wav")
    music = love.audio.newSource("assets/audio/music/just_farming_lofi.mp3", "stream")
    music:setLooping(true)
    music:setVolume(MUSIC_VOLUME)
    music:play()
end

function audio.loadSound(id, path)
    if love.filesystem.getInfo(path) then
        sounds[id] = love.audio.newSource(path, "static")
    end
end

function audio.play(id)
    if sfxMuted then return end
    local snd = sounds[id]
    if snd then
        snd:stop()
        snd:play()
    end
end

function audio.stop(id)
    local snd = sounds[id]
    if snd then
        snd:stop()
    end
end

function audio.toggleMusicMute()
    musicMuted = not musicMuted
    if music then
        if musicMuted then
            music:setVolume(0)
        else
            music:setVolume(MUSIC_VOLUME)
        end
    end
end

function audio.toggleSfxMute()
    sfxMuted = not sfxMuted
end

function audio.isMusicMuted()
    return musicMuted
end

function audio.isSfxMuted()
    return sfxMuted
end

return audio
