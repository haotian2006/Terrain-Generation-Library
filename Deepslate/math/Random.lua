local myRandom = {}
myRandom.__index = myRandom

local Hash = require(script.Parent.Parent.math.Hash)
function myRandom.new(seed,obj)
    local self = setmetatable({}, myRandom)
    self.random = obj or Random.new(seed)
    self.seed = seed
    return self
end

function myRandom:NextNumber(...)
    return self.random:NextNumber(...)
end
function myRandom:NextInteger(...)
    return self.random:NextInteger(...)
end
function myRandom:Consume(x)
    local new = self:Fork()
    for i = 1,x do
        new:NextNumber()
    end
    return new
end
function myRandom:Clone()
    local rc = self.random:Clone()
    return self.new(self.seed,rc)
end
function myRandom:Fork()
    return self.new(self.seed)
end
function myRandom:FromHashOf(hash)
    return self.new(Hash.generateSeedFromString(hash,self.seed))
end

return myRandom
