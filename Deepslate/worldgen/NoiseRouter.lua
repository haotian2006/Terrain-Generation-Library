
local Holder
local NormalNoise
local DensityFunction
local WorldgenRegistries
local hash
local a = false
if not a then 
    a = true
    Holder =require(script.Parent.Parent.core.Holder)
    hash = require(script.Parent.Parent.math.Hash)
end
local NoiseRouter = {}
function NoiseRouter:Init()
    NormalNoise = require(script.Parent.Parent.math.noise.NormalNoise)
    DensityFunction = require(script.Parent.DensityFunction)
    WorldgenRegistries = require(script.Parent.WorldgenRegistries)
end
local function fieldParser(obj)
    return DensityFunction:GetClass("HolderHolder").new(Holder.parser(WorldgenRegistries.DENSITY_FUNCTION, DensityFunction.Evaluate)(obj))
end

function NoiseRouter.Evaluate(obj)
    local root = obj or {}
    return {
        barrier = fieldParser(root.barrier),
        fluidLevelFloodedness = fieldParser(root.fluid_level_floodedness),
        fluidLevelSpread = fieldParser(root.fluid_level_spread),
        lava = fieldParser(root.lava),
        temperature = fieldParser(root.temperature),
        vegetation = fieldParser(root.vegetation),
        continents = fieldParser(root.continents),
        erosion = fieldParser(root.erosion),
        depth = fieldParser(root.depth),
        ridges = fieldParser(root.ridges),
        initialDensityWithoutJaggedness = fieldParser(root.initial_density_without_jaggedness),
        finalDensity = fieldParser(root.final_density),
        veinToggle = fieldParser(root.vein_toggle),
        veinRidged = fieldParser(root.vein_ridged),
        veinGap = fieldParser(root.vein_gap),
    }
end

function NoiseRouter.create(router)
    return {
        barrier = DensityFunction.Constant.ZERO,
        fluidLevelFloodedness = DensityFunction.Constant.ZERO,
        fluidLevelSpread = DensityFunction.Constant.ZERO,
        lava = DensityFunction.Constant.ZERO,
        temperature = DensityFunction.Constant.ZERO,
        vegetation = DensityFunction.Constant.ZERO,
        continents = DensityFunction.Constant.ZERO,
        erosion = DensityFunction.Constant.ZERO,
        depth = DensityFunction.Constant.ZERO,
        ridges = DensityFunction.Constant.ZERO,
        initialDensityWithoutJaggedness = DensityFunction.Constant.ZERO,
        finalDensity = DensityFunction.Constant.ZERO,
        veinToggle = DensityFunction.Constant.ZERO,
        veinRidged = DensityFunction.Constant.ZERO,
        veinGap = DensityFunction.Constant.ZERO,
        unpack(router),
    }
end

function NoiseRouter.mapAll(router, visitor)
    return {
        barrier = DensityFunction.Constant.ZERO,
        fluidLevelFloodedness = DensityFunction.Constant.ZERO,
        fluidLevelSpread = DensityFunction.Constant.ZERO,
        lava = DensityFunction.Constant.ZERO,
        temperature = router.temperature:mapAll(visitor),
        vegetation = router.vegetation:mapAll(visitor),
        continents = router.continents:mapAll(visitor),
        erosion = router.erosion:mapAll(visitor),
        depth = router.depth:mapAll(visitor),
        ridges = router.ridges:mapAll(visitor),
        initialDensityWithoutJaggedness = router.initialDensityWithoutJaggedness:mapAll(visitor),
        finalDensity =  DensityFunction.Constant.ZERO,--router.finalDensity:mapAll(visitor),
        veinToggle = DensityFunction.Constant.ZERO,
        veinRidged = DensityFunction.Constant.ZERO,
        veinGap = DensityFunction.Constant.ZERO,
    }
end

local noiseCache = {}
function NoiseRouter.instantiate(random, noise)
    local key = noise:key()
    if not key then
        error('Cannot instantiate noise from direct holder')
    end
    key = tostring(key)
    local cached = noiseCache[key]
    if cached[1] == random.seed then
        return cached[2]
    end

    local result = NormalNoise.new(random:FromHashOf(key), noise:value())
    noiseCache[key] = {random.seed,result}
    return result
end

return NoiseRouter
