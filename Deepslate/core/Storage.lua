local Storage = {}
local GlobalRefrences = game:GetService("SharedTableRegistry"):GetSharedTable("SharedRefrences")
Storage.Values = {}

function Storage.set(key,value)
    Storage.Values[key] = value
end
function Storage.remove(key)
    Storage.Values[key] = nil
end
function Storage.get(key)
    return Storage.Values[key] 
end

function Storage.setShared(key,value)
    GlobalRefrences[key] = value
end
function Storage.removeShared(key)
    GlobalRefrences[key] = nil
end
function Storage.getShared(key)
    return GlobalRefrences[key] 
end
return Storage