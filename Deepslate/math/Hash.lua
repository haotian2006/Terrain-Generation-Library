local hash = {}
local function jenkins_hash(key)
    local hash = 0
    for i = 1, #key do
        hash = hash + string.byte(key, i)
        hash = hash + bit32.lshift(hash, 10)
        hash = bit32.bxor(hash, bit32.rshift(hash, 6))
    end
    hash = hash + bit32.lshift(hash, 3)
    hash = bit32.bxor(hash, bit32.rshift(hash, 11))
    hash = hash + bit32.lshift(hash, 15)
    return hash
end

function hash.generateSeedFromString(str, seed)
    seed = seed or 0
    return jenkins_hash(`{str}_{seed}`)
end
return hash

