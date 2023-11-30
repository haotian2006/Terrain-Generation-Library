local WorldgenRegistries = {}
local Registry
local NoiseParameters
local NoiseGeneratorSettings
local DensityFunction
local Identifier 
local did = false
if not did then
    Registry = require(script.Parent.Parent.core.Registry)
    NoiseParameters = require(script.Parent.NoiseParameters)
    NoiseGeneratorSettings =  require(script.Parent.NoiseGeneratorSettings)
    DensityFunction = require(script.Parent.DensityFunction)
    Identifier = require(script.Parent.Parent.core.Identifier)
    did = true
end
function WorldgenRegistries.register(name, parser)
    local registry = Registry.new(Identifier.create(name), parser)
    Registry.REGISTRY:register(registry.key, registry)
    return registry
end
WorldgenRegistries.NOISE = WorldgenRegistries.register('worldgen/noise', NoiseParameters.Evaluate)
WorldgenRegistries.DENSITY_FUNCTION = WorldgenRegistries.register('worldgen/density_function',  DensityFunction.Evaluate)
WorldgenRegistries.NOISE_SETTINGS = WorldgenRegistries.register('worldgen/noise_settings', NoiseGeneratorSettings.Evaluate)
function WorldgenRegistries.createNoise(name, firstOctave, amplitudes)
    local noise = WorldgenRegistries.NOISE:register(Identifier.create(name), NoiseParameters.create(firstOctave, amplitudes), true)
    return noise
end
WorldgenRegistries.SURFACE_NOISE = WorldgenRegistries.createNoise('surface', -6, {1, 1, 1})
WorldgenRegistries.SURFACE_SECONDARY_NOISE = WorldgenRegistries.createNoise('surface_secondary', -6, {1, 1, 0, 1})
return WorldgenRegistries 