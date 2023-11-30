--local BlockState = require('../core/index').BlockState
local NoiseRouter 
local NoiseSettings 
local a = false
if not a then 
    a = true
     NoiseRouter = require(script.Parent.NoiseRouter)
     NoiseSettings = require((script.Parent.NoiseSettings)).NoiseSettings
end
--local SurfaceRule = require('./SurfaceSystem').SurfaceRule

local NoiseGeneratorSettings = {}

function NoiseGeneratorSettings.Evaluate(obj)
    local root = obj or {}
    return {
        -- surfaceRule = SurfaceRule.Evaluate(root.surface_rule),
        noise = NoiseSettings.Evaluate(root.noise),
        -- defaultBlock = BlockState.Evaluate(root.default_block),
        -- defaultFluid = BlockState.Evaluate(root.default_fluid),
        noiseRouter = NoiseRouter.Evaluate(root.noise_Router),
        seaLevel = root.sea_level or 0,
        disableMobGeneration = root.disable_mob_generation or false,
        aquifersEnabled = root.aquifers_enabled or false,
        oreVeinsEnabled = root.ore_veins_enabled or false,
        legacyRandomSource = root.legacy_random_source or false,
        biome_source = root.biome_source or {}
    }
end

function NoiseGeneratorSettings.create(settings)
    return {
        -- surfaceRule = SurfaceRule.NOOP,
        noise = NoiseSettings.create({}),
        -- defaultBlock = BlockState.STONE,
        -- defaultFluid = BlockState.WATER,
        biome_source = {},
        noiseRouter = NoiseRouter.create({}),
        seaLevel = 0,
        disableMobGeneration = false,
        aquifersEnabled = false,
        oreVeinsEnabled = false,
        legacyRandomSource = false,
       unpack(settings),
    }
end

return NoiseGeneratorSettings
