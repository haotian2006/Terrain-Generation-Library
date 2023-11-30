local ImprovedNoise = {}
ImprovedNoise.__index = ImprovedNoise
local SimplexNoise = require(script.Parent.SimplexNoise)
local utils = require(script.Parent.Parent.Parent.math.Utils)
local lerp3 = utils.lerp3
local smoothstep = utils.smoothstep
function ImprovedNoise.new(random)
    local instance = setmetatable({}, ImprovedNoise)

    instance.xo = random:NextNumber() * 256
    instance.yo = random:NextNumber() * 256
    instance.zo = random:NextNumber() * 256
    --[[
    instance.p = {}

    for i = 1, 256 do
        instance.p[i] = i > 127 and i - 256 or i
    end

    for i = 1, 255 do
        local j = random:NextInteger(1,256 - i)
        local b = instance.p[i]
        instance.p[i] = instance.p[i + j]
        instance.p[i + j] = b
    end
    ]]
    return instance
end

function ImprovedNoise:sample(x, y, z, yScale, yLimit)
    if not (yScale or yLimit) then
        return math.noise(x+self.xo,y+self.yo,z+self.zo)
    end
    local x2 = x + self.xo
    local y2 = y + self.yo
    local z2 = z + self.zo
    local x3 = math.floor(x2)
    local y3 = math.floor(y2)
    local z3 = math.floor(z2)
    local x4 = x2 - x3
    local y4 = y2 - y3
    local z4 = z2 - z3
    yScale = yScale or 0
    yLimit = yLimit or 0
    local y6 = 0
    if yScale ~= 0 then
        local t = yLimit >= 0 and yLimit < y4 and yLimit or y4
        y6 = math.floor(t / yScale + 1e-7) * yScale
    end
    
    local noiseValue = math.noise(x2, y2 - y6, z2) 
    return noiseValue
end
--[[
function ImprovedNoise:sampleAndLerp(a, b, c, d, e, f, g)
    local h = self:P(a)
    local i = self:P(a + 1)
    local j = self:P(h + b)
    local k = self:P(h + b + 1)
    local l = self:P(i + b)
    local m = self:P(i + b + 1)

    local n = SimplexNoise.gradDot(self:P(j + c), d, e, f)
    local o = SimplexNoise.gradDot(self:P(l + c), d - 1.0, e, f)
    local p = SimplexNoise.gradDot(self:P(k + c), d, e - 1.0, f)
    local q = SimplexNoise.gradDot(self:P(m + c), d - 1.0, e - 1.0, f)
    local r = SimplexNoise.gradDot(self:P(j + c + 1), d, e, f - 1.0)
    local s = SimplexNoise.gradDot(self:P(l + c + 1), d - 1.0, e, f - 1.0)
    local t = SimplexNoise.gradDot(self:P(k + c + 1), d, e - 1.0, f - 1.0)
    local u = SimplexNoise.gradDot(self:P(m + c + 1), d - 1.0, e - 1.0, f - 1.0)

    local v = smoothstep(d)
    local w = smoothstep(g)
    local x = smoothstep(f)

    return lerp3(v, w, x, n, o, p, q, r, s, t, u)
end

function ImprovedNoise:P(i)
    print("used")
    return bit32.band(self.p[bit32.band(i, 0xFF)+1], 0xFF)--+1
end
]]
return ImprovedNoise
