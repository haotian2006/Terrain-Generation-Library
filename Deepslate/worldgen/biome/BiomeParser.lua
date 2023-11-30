local Biome = {}
local Settings = {}
local WorldgenRegistries = require(script.Parent.Parent.WorldgenRegistries)
local bh = require(game.ReplicatedStorage.BehaviorHandler)
local FeatureParaser = require(script.Parent.FeatureParser)
function Biome.parseBiome(info,SPECIAL)
    local bhFeatures = bh.Features or {}
    local Features = info.Features or {}
    info.noiseFunctions = {}
    for i,v in Features do
        if type(v) == "string" and not SPECIAL then
            v = bhFeatures[v] or warn(`'{v}' does not exist`)
        elseif not SPECIAL then
          v = FeatureParaser.EvaluateOne(v)  
        end
        Features[i] = v
        info.noiseFunctions[v.noiseSettings] = not SPECIAL and v.noiseFunction or true
    end
end
function Biome.Evaluate(data)
    for i,v in data do
        Biome.parseBiome(v)
    end
end
return Biome 