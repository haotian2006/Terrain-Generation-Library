local ss = game:GetService("SharedTableRegistry")
local holder = require(script.Parent.Holder)
local Identifier = require(script.Parent.Identifier)
local Registry = {
}
Registry.__index = Registry
function Registry.new(key,parser)
    return setmetatable({key = key,parser = parser,storage = {},builtin = {}},Registry)
end
Registry.REGISTRY = Registry.new(Identifier.create("root"))
function Registry:register(id,value,builtin)
    if builtin then self.builtin[tostring(id)] = value end 
    self.storage[tostring(id)] = value
    return holder.reference(self,id)
end
function Registry:delete(id)
    self.storage[tostring(id)] = nil
    self.builtin[tostring(id)] = nil
end
function Registry:keys()
    local k = {}
    for i in self.storage do table.insert(k,Identifier.parse(i)) end 
    return k
end
function Registry:has(id)
    return self.storage[tostring(id)]
end
function Registry:get(id)
    return self.storage[tostring(id)]
end
function Registry:getOrThrow(id)
    if not self.storage[tostring(id)] then
        error(`Missing key in ${self.key}: ${tostring(id)}`)
    end
    return self.storage[tostring(id)]
end
function Registry:parase(obj)
    if(not self.parser)then
        error(`No parser exists for ${tostring(self.key)}`)
    end
    return self.parser(obj)
end
function Registry:clear()
    table.clear(self.storage)
    for i,v in self.builtin do
        self.storage[i] = v
    end
    return self
end
function Registry:assign(other)
    if self.key ~= other.key then
        error(`Cannot assign registry of type ${tostring(other.key)} to registry of type ${tostring(self.key)}`)
    end
    for _,i in other:keys() do
        self.storage[tostring(i)] = other:getOrThrow(i)
    end
    return self
end
function Registry:forEach(fn)
    for i,v in self.storage do
        fn(Identifier.parse(i),v,self)
    end
end
function Registry:map(fn)
    local results = {}
    for key, value in pairs(self.storage) do
        local result = fn(Identifier.parse(key), value, self)
        table.insert(results, result)
    end
    return results
end
return Registry