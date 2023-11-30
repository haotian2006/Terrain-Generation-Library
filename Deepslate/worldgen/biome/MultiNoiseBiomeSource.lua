local climate = require(script.Parent.Climate)
local MultiNoiseBiomeSource = {}
MultiNoiseBiomeSource.__index = MultiNoiseBiomeSource
local Identifier = require(script.Parent.Parent.Parent.core.Identifier)
function MultiNoiseBiomeSource.new(entries)
    return setmetatable({parameters = climate:GetClass("Parameters").new(entries)},MultiNoiseBiomeSource)
end

function MultiNoiseBiomeSource:getBiome(x,y,z,climateSampler)
    local target = climateSampler.sample(x,y,z)
    return self.parameters:find(target)
end
function MultiNoiseBiomeSource:getBiomeFromTarget(target)
    return self.parameters:find(target)
end

function MultiNoiseBiomeSource.Evaluate(obj)
    obj = obj or {}
   local entries = {}
   for i,b in obj do
    if type(b) ~= "table" then continue end 
        b = b or {}
        local d = Identifier.parse(b.biome or 'plains')
        table.insert(entries,{climate:GetClass("ParamPoint").Evaluate(b.parameters), function()
            return  d
        end
    })
   end
   return MultiNoiseBiomeSource.new(entries)
end
return MultiNoiseBiomeSource