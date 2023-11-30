local SimplexNoise = {}

SimplexNoise.GRADIENT = {
    {1, 1, 0}, {-1, 1, 0}, {1, -1, 0}, {-1, -1, 0},
    {1, 0, 1}, {-1, 0, 1}, {1, 0, -1}, {-1, 0, -1},
    {0, 1, 1}, {0, -1, 1}, {0, 1, -1}, {0, -1, -1},
    {1, 1, 0}, {0, -1, 1}, {-1, 1, 0}, {0, -1, -1}
}
SimplexNoise.F2 = 0.5 * (math.sqrt(3.0) - 1.0)
SimplexNoise.G2 = (3.0 - math.sqrt(3.0)) / 6.0
SimplexNoise.__index = SimplexNoise
function SimplexNoise.new(random)
    local obj = {
        xo = random:NextNumber() * 256,
        yo = random:NextNumber() * 256,
        zo = random:NextNumber() * 256,
        p = {}
    }

    for i = 1, 256 do
        obj.p[i] = i - 1
    end
    for i = 1, 256 do
        local j = random:NextInteger(0,256 - i)
        local b = obj.p[i]
        obj.p[i] = obj.p[i + j]
        obj.p[i + j] = b
    end
    setmetatable(obj, SimplexNoise)
    return obj
end

function SimplexNoise:sample2D(d, d2)
    local d3, n3, d4
    local d6 = (d + d2) * SimplexNoise.F2
    local n4 = math.floor(d + d6)
    n3 = math.floor(d2+d6)
    d3 = (n4+(n3))
    local d7 = n4 - (d3)*SimplexNoise.G2
    local d8 = d - d7
    local a, b
    d4 = d2 - (n3 - d3)
    if d8 > d4 then
        a, b = 1, 0
    else
        a, b = 0, 1
    end
    local d9 = d8 - a + SimplexNoise.G2
    local d10 = d4 - b + SimplexNoise.G2
    local d11 = d8 - 1.0 + 2.0 * SimplexNoise.G2
    local d12 = d4 - 1.0 + 2.0 * SimplexNoise.G2
    local n5 = bit32.band(n4, 0xFF)
    local n6 = bit32.band(n3, 0xFF)
    local n7 = self:P(n5 + self:P(n6)) % 12
    local n8 = self:P(n5 + a + self:P(n6 + b)) % 12
    local n9 = self:P(n5 + 1 + self:P(n6 + 1)) % 12
    local d13 = self:getCornerNoise3D(n7, d8, d4, 0.0, 0.5)
    local d14 = self:getCornerNoise3D(n8, d9, d10, 0.0, 0.5)
    local d15 = self:getCornerNoise3D(n9, d11, d12, 0.0, 0.5)
    return 70.0 * (d13 + d14 + d15)
end

function SimplexNoise:sample(x, y, z)
    local d5 = (x + y + z) * 0.3333333333333333
    local x2 = math.floor(x + d5)
    local y2 = math.floor(y + d5)
    local z2 = math.floor(z + d5)
    local d7 = (x2 + y2 + z2) * 0.16666666666666666
    local x3 = x - (x2 - d7)
    local y3 = y - (y2 - d7)
    local z3 = z - (z2 - d7)
    local a, b, c, d, e, f
    if x3 >= y3 then
        if y3 >= z3 then
            a, b, c, d, e, f = 1, 0, 0, 1, 1, 0
        elseif x3 >= z3 then
            a, b, c, d, e, f = 1, 0, 0, 1, 0, 1
        else
            a, b, c, d, e, f = 0, 0, 1, 1, 0, 1
        end
    elseif y3 < z3 then
        a, b, c, d, e, f = 0, 0, 1, 0, 1, 1
    elseif x3 < z3 then
        a, b, c, d, e, f = 0, 1, 0, 0, 1, 1
    else
        a, b, c, d, e, f = 0, 1, 0, 1, 1, 0
    end
    local x4 = x3 - a + 0.16666666666666666
    local y4 = y3 - b + 0.16666666666666666
    local z4 = z3 - c + 0.16666666666666666
    local x5 = x3 - d + 0.3333333333333333
    local y5 = y3 - e + 0.3333333333333333
    local z5 = z3 - f + 0.3333333333333333
    local x6 = x3 - 0.5
    local y6 = y3 - 0.5
    local z6 = z3 - 0.5
    local x7 = bit32.band(x2, 0xFF)
    local y7 = bit32.band(y2, 0xFF)
    local z7 = bit32.band(z2, 0xFF)
    local g = self:P(x7 + self:P(y7 + self:P(z7))) % 12
    local h = self:P(x7 + a + self:P(y7 + b + self:P(z7 + c))) % 12
    local i = self:P(x7 + d + self:P(y7 + e + self:P(z7 + f))) % 12
    local j = self:P(x7 + 1 + self:P(y7 + 1 + self:P(z7 + 1))) % 12
    local k = self:getCornerNoise3D(g, x3, y3, z3, 0.6)
    local l = self:getCornerNoise3D(h, x4, y4, z4, 0.6)
    local m = self:getCornerNoise3D(i, x5, y5, z5, 0.6)
    local n = self:getCornerNoise3D(j, x6, y6, z6, 0.6)
    return 32.0 * (k + l + m + n)
end

function SimplexNoise:P(i)
    return self.p[bit32.band(i, 0xFF)+1 ]--+1
end

function SimplexNoise:getCornerNoise3D(i, a, b, c, d)
    local f
    local e = d - a * a - b * b - c * c
    if e < 0.0 then
        f = 0.0
    else
        e = e * e
        f = e * e * SimplexNoise.gradDot(i, a, b, c)
    end
    return f
end

function SimplexNoise.gradDot(a, b, c, d)
    local grad = SimplexNoise.GRADIENT[bit32.band(a, 15) +1]--+1
    return grad[1] * b + grad[2] * c + grad[3] * d
end

return SimplexNoise
