local d = {}
for i,v in script:GetDescendants() do
    if  not v:IsA('ModuleScript') then continue end
    local a = require(v)
    if a.Init then
        a:Init()
    end
    d[v.Name] = a
end
return d 