local NoiseSettings = {}
local math = require(script.Parent.Parent.math.Utils)
function NoiseSettings.Evaluate(obj)
    obj = obj or {}
    return {
        minY = obj.min_y or 0,
        height = obj.height or 256,
        xzSize = obj.size_horizontal or 1,
        ySize = obj.size_vertical or 1,
    }
end

function NoiseSettings.create(settings)
    return {
        minY = 0,
        height = 256,
        xzSize = 1,
        ySize = 1,
        unpack(settings),  -- Spread the settings table if provided
    }
end

function NoiseSettings.cellHeight(settings)
    return settings.ySize * 4
end

function NoiseSettings.cellWidth(settings)
    return settings.xzSize * 4
end

function NoiseSettings.cellCountY(settings)
    return settings.height / NoiseSettings.cellHeight(settings)
end

function NoiseSettings.minCellY(settings)
    return math.floor(settings.minY / NoiseSettings.cellHeight(settings))
end

local NoiseSlideSettings = {}

function NoiseSlideSettings.Evaluate(obj)
    local obj = obj or {}
    return {
        target = obj.target or 0,
        size = obj.size or 0,
        offset = obj.offset or 0,
    }
end

function NoiseSlideSettings.apply(slide, density, y)
    if slide.size <= 0 then
        return density
    end
    local t = (y - slide.offset) / slide.size
    return math.clampedLerp(slide.target, density, t)
end
return {NoiseSettings = NoiseSettings, NoiseSlideSettings = NoiseSlideSettings}