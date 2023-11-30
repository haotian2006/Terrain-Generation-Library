local math = require(script.Parent.Parent.Parent.math.Utils)
local PerlinNoise = require(script.Parent.PerlineNoise)
local BlendedNoise = {}
BlendedNoise.__index = BlendedNoise

function BlendedNoise.new(random, xzScale, yScale, xzFactor, yFactor, smearScaleMultiplier)
    local self = setmetatable({}, BlendedNoise)
    self.xzScale = xzScale
    self.yScale = yScale
    self.xzFactor = xzFactor
    self.yFactor = yFactor
    self.random = random
    self.smearScaleMultiplier = smearScaleMultiplier
    self.minLimitNoise = PerlinNoise.new(random, -15, {1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0})
    self.maxLimitNoise = PerlinNoise.new(random, -15, {1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0})
    self.mainNoise = PerlinNoise.new(random, -7, {1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0})
    self.xzMultiplier = 684.412 * xzScale
    self.yMultiplier = 684.412 * yScale
    self.maxValue = self.minLimitNoise:edgeValue(yScale + 2)  
    return self
end

function BlendedNoise:sample(x, y, z)
    local scaledX = x * self.xzMultiplier
    local scaledY = y * self.yMultiplier
    local scaledZ = z * self.xzMultiplier
    local factoredX = scaledX / self.xzFactor
    local factoredY = scaledY / self.yFactor
    local factoredZ = scaledZ / self.xzFactor
    local smear = self.yMultiplier * self.smearScaleMultiplier
    local factoredSmear = smear / self.yFactor
    local noise
    local value = 0
    local factor = 1
    for i = 0, 7 do
        noise = self.mainNoise:getOctaveNoise(i)
        if noise then
            local xx = PerlinNoise.wrap(factoredX * factor)
            local yy = PerlinNoise.wrap(factoredY * factor)
            local zz = PerlinNoise.wrap(factoredZ * factor)
            value += noise:sample(xx,yy,zz,factoredSmear*factor,factoredY*factor) / factor
        end
        factor = factor / 2
    end
    value = (value / 10 + 1) / 2
    factor = 1
    local min = 0
    local max = 0
    for i = 0, 15 do
        local xx = PerlinNoise.wrap(scaledX * factor)
        local yy = PerlinNoise.wrap(scaledY * factor)
        local zz = PerlinNoise.wrap(scaledZ * factor)
        local smearsmear = smear * factor
        if value < 1 then
            noise = self.minLimitNoise:getOctaveNoise(i)
            if noise then
                min += noise:sample(xx,yy,zz,smearsmear,scaledY*factor)/factor
            end
        end
        
        if value > 0 then
            noise = self.maxLimitNoise:getOctaveNoise(i)
            if noise then
                max +=   noise:sample(xx,yy,zz,smearsmear,scaledY*factor)/factor
            end
        end
        factor = factor / 2
    end
    return math.clampedLerp(min / 512, max / 512, value) / 128
end
return BlendedNoise