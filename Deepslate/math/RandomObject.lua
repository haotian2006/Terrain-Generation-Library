local RandomObj = {}
RandomObj.__index = RandomObj

local Hash = require(script.Parent.Parent.math.Hash)
function RandomObj.new(seed,obj)
    local self = setmetatable({}, RandomObj)
    self.random = obj or Random.new(seed)
    self.seed = seed
    return self
end

function RandomObj:NextNumber(...)
    return self.random:NextNumber(...)
end
function RandomObj:NextInteger(...)
    return self.random:NextInteger(...)
end
function RandomObj:Consume(x)
    local new = self:Fork()
    for i = 1,x do
        new:NextNumber()
    end
    return new
end
function RandomObj:Clone()
    local rc = self.random:Clone()
    return self.new(self.seed,rc)
end
function RandomObj:Fork()
    return self.new(self.seed)
end
function RandomObj:FromHashOf(hash)
    return self.new(Hash.generateSeedFromString(hash,self.seed))
end

return RandomObj
