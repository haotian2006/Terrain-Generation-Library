

local RandomState = {}
RandomState.__index = RandomState
local SurfaceSystem
local NoiseRouter = require(script.Parent.NoiseRouter)
local NoiseSettings = require(script.Parent.NoiseSettings).NoiseSettings
local NoiseParameters = require(script.Parent.NoiseParameters)
local Climate = require(script.Parent.biome.Climate)
local NormalNoise =require(script.Parent.Parent.math.noise.NormalNoise)
local DensityFunction = require(script.Parent.DensityFunction)
local hash = require(script.Parent.Parent.math.Hash)
local BlendedNoise = require(script.Parent.Parent.math.noise.BlendedNoise)
local Registry = require(script.Parent.Parent.core.Registry)
local Identifier = require(script.Parent.Parent.core.Identifier)
local randomobj = require(script.Parent.Parent.math.RandomObject)
function RandomState.new(settings,seed)
    local a = setmetatable({},RandomState)
    a.seed = seed
    a.noiseCache = {} 
    a.randomCache = {}
    a.random = randomobj.new(seed):Fork()
    a.SurfaceSystem = SurfaceSystem --//TODO
    a.router = NoiseRouter.mapAll(settings.noiseRouter,a:createVisitor(settings.noise,settings.legacyRandomSource))
    a.biomes = settings.biome_source or {}
    a.sample = Climate:GetClass("Sampler").fromRouter(a.router)
    return a
end 
function RandomState:getNoise(noise,legacyRandom)
    local key = noise:key()
    if key == nil then
        error('Cannot create noise without key')
    end
    if legacyRandom then
        local random = self.random
        if key ==  Identifier.create("temperature") then
            return NormalNoise.new(random.new(self.seed+0), NoiseParameters.create(-7, {1, 1}))
        elseif key == Identifier.create('vegetation') then
            return NormalNoise.new(random.new(self.seed+1), NoiseParameters.create(-7, {1, 1}))
        elseif key == Identifier.create('offset') then
            return NormalNoise.new(random:FromHashOf('offset'), NoiseParameters.create(0, {0}))
        end
    end
    return self:getOrCreateNoise(key)
end
function RandomState:createVisitor(noiseSettings,legacyRandom)
    local mapped = {}
    local visitor = {

    }
    visitor.map = function(fn)
        if fn:IsA("HolderHolder") then
            local key =  fn.holder:key()
            key = key and tostring(key)
            if key ~= nil and mapped[key] then
                return mapped[key]
            else
                local value = fn.holder:value():mapAll(visitor)
                if key ~= nil then
                    mapped[key] = value
                end
                return value
            end
        end
        if fn:IsA("Interpolated") then
            return fn:withCellSize(NoiseSettings.cellWidth(noiseSettings), NoiseSettings.cellHeight(noiseSettings))
        end
        if fn:IsA("ShiftedNoise") then
            return DensityFunction.ShiftedNoise.new(fn.shiftX, fn.shiftY, fn.shiftZ, fn.xzScale, fn.yScale, fn.noiseData, self:getNoise(fn.noiseData,legacyRandom))
        end
        if fn:IsA("Noise") then
            return DensityFunction.Noise.new(fn.xzScale, fn.yScale, fn.noiseData, self:getNoise(fn.noiseData,legacyRandom))
        end
        if fn:IsA("ShiftNoise") then
            return fn:withNewNoise(self:getNoise(fn.noiseData,legacyRandom))
        end
        if fn:IsA("WeirdScaledSampler") then
            return DensityFunction.WeirdScaledSampler.new(fn.input, fn.rarityValueMapper, fn.noiseData, self:getNoise(fn.noiseData,legacyRandom))
        end
        if fn:IsA("OldBlendedNoise") then
            return DensityFunction.OldBlendedNoise.new(fn.xzScale, fn.yScale, fn.xzFactor, fn.yFactor, fn.smearScaleMultiplier, BlendedNoise.new(self.random:FromHashOf('terrain'), fn.xzScale, fn.yScale, fn.xzFactor, fn.yFactor, fn.smearScaleMultiplier))
        end
        if fn:IsA("EndIslands") then
            --return DensityFunction.EndIslands:new(self.seed)
            error("NO ENDISLAND RIGHT NOW")
            return nil --//TODO
        end
        if fn:IsA("Mapped") then
            return fn:withMinMax()
        end
        if fn:IsA("Ap2") then
            return fn:withMinMax()
        end
        return fn
    end
    return visitor
end
local function computeIfAbsent(map, key, getter) 
    local existing = map[key];
    if (existing) then
        return existing;
    end
    local value = getter(key);
    map[key] = value
    return value;
end
function RandomState:getOrCreateNoise(id)
    local noises = Registry.REGISTRY:getOrThrow(Identifier.create('worldgen/noise'))
    return computeIfAbsent(self.noiseCache,tostring(id),function(key)
        return NormalNoise.new(self.random:FromHashOf(key),noises:getOrThrow(id))
    end)
end

function RandomState:getOrCreateRandom(id)
    return computeIfAbsent(self.randomCache,tostring(id),function(key)
        return self.random:FromHashOf(key):Fork()
    end)
end
return RandomState