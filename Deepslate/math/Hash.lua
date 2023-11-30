local hash = {}
local function simpleHash(str)
    local hash = 0
    local len = string.len(str)
    for i = 1, len do
        local byteValue = string.byte(str, i)
        hash = (hash * 31 + byteValue) % 2^32
    end
    return hash
end

-- Function to generate a new seed based on a string and a seed
function hash.generateSeedFromString(str, seed)
    seed = seed or 0
    local hashValue = simpleHash(str)
    local newSeed = bit32.bxor(seed, hashValue)
    return newSeed
end
return hash

