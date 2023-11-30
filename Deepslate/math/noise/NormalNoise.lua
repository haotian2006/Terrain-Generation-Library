local NormalNoise = {}
local PerlinNoise = require(script.Parent.PerlineNoise)
NormalNoise.INPUT_FACTOR = 1.0181268882175227
NormalNoise.__index = NormalNoise
local size = require(script.Parent.Parent.Utils).Size
function NormalNoise.new(random, options)
    local newObj = {}
    setmetatable(newObj, NormalNoise)


    newObj.first = PerlinNoise.new(random, options.firstOctave, options.amplitudes)
    newObj.second = PerlinNoise.new(random, options.firstOctave, options.amplitudes)
    
    local min = math.huge
    local max = -math.huge
    for i = 1, size(options.amplitudes) do
        if options.amplitudes[i] ~= 0 then
            min = math.min(min, i)
            max = math.max(max, i)
        end
    end
    
    local expectedDeviation = 0.1 * (1 + 1 / (max - min + 1))
    newObj.valueFactor = (1 / 6) / expectedDeviation
    newObj.maxValue = (newObj.first.maxValue + newObj.second.maxValue) * newObj.valueFactor
    
    return newObj
end

function NormalNoise:sample(x, y, z)
    local x2 = x * NormalNoise.INPUT_FACTOR
    local y2 = y * NormalNoise.INPUT_FACTOR
    local z2 = z * NormalNoise.INPUT_FACTOR
    return (self.first:sample(x, y, z) + self.second:sample(x2, y2, z2)) * self.valueFactor
end
return NormalNoise