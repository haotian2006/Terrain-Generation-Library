local Identifier = {}
Identifier.DEFAULT_NAMESPACE = 'c'
Identifier.SEPARATOR = ':'
Identifier.__index = Identifier
function Identifier.new(namespace, path)
    local newObj = {
        namespace = namespace,
        path = path or ""
    }
    path = path or ""
    setmetatable(newObj, Identifier)
    -- if not namespace:match('^[a-z0-9._-]*$') then
    --     error('Non [a-z0-9._-] character in namespace of ' .. namespace .. Identifier.SEPARATOR .. path)
    -- end
    -- if not path:match('^[a-z0-9/._-]*$') then
    --     error('Non [a-z0-9/._-] character in path of ' .. namespace .. Identifier.SEPARATOR .. path)
    -- end
    return newObj
end

function Identifier:__eq(other)
    return self.namespace == other.namespace and self.path == other.path
end

function Identifier:__tostring()
    return `{self.namespace}{Identifier.SEPARATOR}{self.path}`
end

function Identifier:withPrefix(prefix)
    return Identifier.new(self.namespace, prefix .. self.path)
end

function Identifier.create(path)
    return Identifier.new(Identifier.DEFAULT_NAMESPACE, path)
end

function Identifier.parse(id)
    local sep = id:find(Identifier.SEPARATOR)
    if sep then
        local namespace = sep >= 1 and id:sub(1, sep-1  ) or Identifier.DEFAULT_NAMESPACE
        local path = id:sub(sep + 1)
        return Identifier.new(namespace, path)
    end
    return Identifier.new(Identifier.DEFAULT_NAMESPACE, id)
end

return Identifier
