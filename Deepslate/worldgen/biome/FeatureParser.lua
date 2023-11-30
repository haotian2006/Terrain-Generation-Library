local WorldgenRegistries = require(script.Parent.Parent.WorldgenRegistries)
local indentifier = require(script.Parent.Parent.Parent.core.Identifier)
local NN = require(script.Parent.Parent.Parent.math.noise.NormalNoise)
local Perline = require(script.Parent.Parent.Parent.math.noise.PerlineNoise)
local Radomlib = require(script.Parent.Parent.Parent.math.RandomObject)
local blockPool = require(game.ReplicatedStorage.Libarys.BlockPool)
local Random 
local noises = {

}
local Feature = {}
local function evalNoise(noise)
    if type(noise) =="string" then
        local str =noise
        if noises[str] then return noises[str],noise end 
        local settings =   WorldgenRegistries.NOISE:get(indentifier.parse(noise))
        local useNormal = settings.useNormal
        local offset = settings.offset
        local obj
        local rand =Random
        if offset then
            local seed= Random.seed
            rand = Radomlib.new(seed + offset)
        end
        if useNormal then           
            obj =  NN.new(rand,settings)
        else
             obj = Perline.new(rand,settings.firstOctave,settings.amplitudes)
        end
        noises[str] = obj 
        return obj,noise 
    elseif type(noise) == "table" then
        local setting = noise.noiseSettings 
        local Super =   type(setting) =="string" and WorldgenRegistries.NOISE:get(indentifier.parse(setting)) or setting
        local offset =  noise.offset
        if type(setting) =="table" then
            setting = table.concat(setting.firstOctave',').. table.concat(setting.amplitudes'|')
        end
        local s = `{setting}{not noise.useNormal}{offset or 0}`
        Super.offset = offset
        Super.useNormal = noise.useNormal
        WorldgenRegistries.NOISE:register(indentifier.parse(s),Super)
            
        return evalNoise(s)
        -- local rand =Random
        -- if offset then
        --     local seed= Random.seed
        --     rand = Radomlib.new(seed + offset)
        -- end
        -- if type(setting) == "string" then
        --     local data = evalNoise(setting,noise.useNormal,offset)
        -- elseif noise.amplitudes then
        --     if useNormal then
        --         return NN.new(rand,noise)
        --     end
        --     return Perline.new(rand,noise.firstOctave,noise.amplitudes)
        -- else
        --     if useNormal then
        --         return NN.new(rand,setting)
        --     end
        --     return Perline.new(rand,setting.firstOctave,setting.amplitudes)
        -- end
    end
end
local function EvaluateStructure(data)
    for i,v in data.key do
        if type(v) == "table" then
            data.key[i] = blockPool.createStrFromTable(v)
        end
    end
end
local function  Evaluate(feature)
    if not feature.noiseSettings then warn(`{feature.name} is missing noiseSettings`) end
    local func,name =  evalNoise(feature.noiseSettings)
    feature.noiseFunction,feature.noiseSettings = func,name
    if feature.structure then
        EvaluateStructure(feature.structure)
    end
    local mul = feature.noise_Range.multiplier or 1 
    feature.noise_Range.multiplier = nil
    for i,v in feature.noise_Range do
        local m = (v.multiplier or 1) *mul
        v.min/=m
        v.max/=m
        v.multiplier = nil
    end
    return feature
end
function Feature.Evaluate(info,rand)
    Random = Random or rand
    for i,v in info do
        Evaluate(v)
    end
end
function Feature.EvaluateOne(info)
   return Evaluate(info)
end
return Feature