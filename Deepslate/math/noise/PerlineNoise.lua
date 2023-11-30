local PerlinNoise = {}
PerlinNoise.__index = PerlinNoise
local hash = require(script.Parent.Parent.Parent.math.Hash)
local ImprovedNoise = require(script.Parent.ImprovedNoise)
local size = require(script.Parent.Parent.Utils).Size
function PerlinNoise.new(random, firstOctave, amplitudes)
    local self = {
        noiseLevels = {},
        amplitudes = amplitudes,
        lowestFreqInputFactor = 2 ^ firstOctave,
        lowestFreqValueFactor = (2 ^ (size(amplitudes) - 1)) / (2 ^ size(amplitudes) - 1),
    }
    local Forked = random:Fork()
    for i = 1, size(amplitudes) do
        if amplitudes[i] ~= 0.0 then
            local octave = firstOctave + i 
            self.noiseLevels[i] = ImprovedNoise.new(Forked:FromHashOf('octave_'..octave))
        end
    end
    setmetatable(self, PerlinNoise)
    self.maxValue = self:edgeValue(2)
    return self
end

function PerlinNoise.sample(self, x, y, z, yScale, yLimit, fixY)
    local value = 0
    local inputF = self.lowestFreqInputFactor
    local valueF = self.lowestFreqValueFactor
    yScale = yScale or 0 
    yLimit = yLimit or 0
    fixY = fixY or false
    for i = 1, size(self.noiseLevels) do
        local noise = self.noiseLevels[i]
        if noise then
            value = value + self.amplitudes[i] * valueF * noise:sample(
                PerlinNoise.wrap(x * inputF),
                fixY and -noise.yo or PerlinNoise.wrap(y * inputF),
                PerlinNoise.wrap(z * inputF),
                yScale * inputF,
                yLimit * inputF
            )
           -- print(n, self.seed+x * inputF, self.seed+y * inputF, self.seed+z * inputF)
        end
        inputF = inputF * 2
        valueF = valueF / 2
    end

    return value
end
function PerlinNoise:getOctaveNoise(i) 
    return self.noiseLevels[size(self.noiseLevels) - i];
end
function PerlinNoise:edgeValue( x)
    local value = 0
    local valueF = self.lowestFreqValueFactor

    for i = 1, size(self.noiseLevels) do
        local noise = self.noiseLevels[i]
        if noise then
            value = value + self.amplitudes[i] * x * valueF
        end
        valueF = valueF / 2
    end

    return value
end

function PerlinNoise.wrap(value)
    return value - math.floor(value / 33554432 + 0.5) * 33554432
end

return PerlinNoise
