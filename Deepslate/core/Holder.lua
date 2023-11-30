local Holder = {}
local Identifier = require(script.Parent.Identifier)
function Holder.parser(registry, directParser)
    return function(obj)
        if type(obj) == 'string' then
            return Holder.reference(registry, Identifier.parse(obj))
        else
            return Holder.direct(directParser(obj))
        end
    end
end

function Holder.direct(value, id)
    return {
        value = function()
            return value
        end,
        key = function()
            return id
        end
    }
end

function Holder.reference(registry, id)
    return {
        value = function()
            return registry:getOrThrow(id)
        end,
        key = function()
            return id
        end
    }
end

return Holder
