local math = {}
for i,v in script:GetChildren() do
    for i,v in require(v) do
        math[i] = v
    end
end
return math