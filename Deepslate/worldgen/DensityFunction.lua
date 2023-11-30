local DensityFunctions ={Subtables = {},Children = {}}
local mathf 
local Holder 
local WorldgenRegistries 
local Identifier 
local NoiseParameters 
local CubicSpline 
local Started = false
local storage = require(script.Parent.Parent.core.Storage)

DensityFunctions ={Subtables = {},Children = {}}
if Started == false then
    mathf = require(script.Parent.Parent.math.Utils)
    Holder = require(script.Parent.Parent.core.Holder)
    Identifier = require(script.Parent.Parent.core.Identifier)
    CubicSpline = require(script.Parent.Parent.math.CubicSpline)
    Started = true
end
local lazyLerp3 = mathf.lazyLerp3
local sub = DensityFunctions.Subtables
local newcontext = Vector3.new
DensityFunctions.__index = DensityFunctions
DensityFunctions.__type = "DensityFunctions"
DensityFunctions.IsChildOfDensityFunction = true
function DensityFunctions:minValue()
    return -self:maxValue()
end
function DensityFunctions:mapAll(visitor)
    return visitor.map(self)
end
function DensityFunctions:IsA(type)
    if self.__type == type then return true end 
    if self.__parent then return self.__parent:IsA(type) end 
end
function DensityFunctions:GetClass(class)
    return self[class]
end
local function applySubtables(table)
    for i,v in table.Subtables do
        v.__index =  setmetatable(v,table)
        v.__type = i
        v.__parent = table
        if rawget(v,"Subtables") then
            applySubtables(v)
        end
        DensityFunctions[i] = v
    end
end
local NoiseParser
function DensityFunctions:Init()
    applySubtables(self)
    WorldgenRegistries = require(script.Parent.WorldgenRegistries)
    NoiseParameters = require(script.Parent.NoiseParameters)
    NoiseParser = Holder.parser(WorldgenRegistries.NOISE,NoiseParameters.Evaluate) 
    return self
end

sub.Transformer = {}
local Transformer = sub.Transformer
Transformer.Subtables = {} 
local Transformersub = Transformer.Subtables 
function Transformer.new(input)
    local data = setmetatable({input = input},Transformer)
    return data
end
function Transformer:compute(context)
    return self:transform(context,self.input:compute(context))
end


sub.Constant = {
}
local Constant = sub.Constant
function Constant.new(value)
    local data = setmetatable({value = value},Constant)
    return data
end
function Constant:compute()
    return self.value
end
function Constant:minValue()
    return self.value
end

function Constant:maxValue()
    return self.value
end
Constant.ZERO = Constant.new(0)
Constant.ONE = Constant.new(0)

Constant.Subtables = {}
local ConstantSub = Constant.Subtables 

sub.HolderHolder = {}
local HolderHolder = sub.HolderHolder
function HolderHolder.new(holder)
    local data = setmetatable({holder = holder},HolderHolder)
    return data
end
function HolderHolder:compute(context)
    return self.holder:value():compute(context)
end
function HolderHolder:minValue()
    return self.holder:value():minValue()
end

function HolderHolder:maxValue()
    return self.holder:value():maxValue()
end


ConstantSub.ConstantMinMax = {
}
local ConstantMinMax = ConstantSub.ConstantMinMax
function ConstantMinMax.new(value,min,max)
    local data = setmetatable(Constant.new(value),ConstantMinMax)
    data.min = min
    data.max = max
    return data
end
function ConstantMinMax:minValue()
    return self.min
end

function ConstantMinMax:maxValue()
    return self.max
end


sub.OldBlendedNoise = {}
local OldBlendedNoise = sub.OldBlendedNoise
function OldBlendedNoise.new(xzScale, yScale,xzFactor,yFactor,smearScaleMultiplier, blendedNoise)
    local data = setmetatable({xzScale=xzScale,yScale=yScale,yFactor=yFactor,xzFactor=xzFactor,smearScaleMultiplier=smearScaleMultiplier,blendedNoise=blendedNoise},OldBlendedNoise)
    return data
end
function OldBlendedNoise:compute(context)
    return self.blendedNoise and self.blendedNoise:sample(context.X, context.Y,context.Z) or 0
end
function OldBlendedNoise:maxValue()
    return self.blendedNoise and self.blendedNoise.maxValue or 0
end


sub.Wrapper = {}
local Wrapper = sub.Wrapper
Wrapper.Subtables = {}
local WrapperSub = Wrapper.Subtables
function Wrapper.new(wrapped)
    local data = setmetatable({wrapped = wrapped},Wrapper)
    return data
end
function Wrapper:minValue()
    return self.wrapped:minValue()
end 

function Wrapper:maxValue()
    return self.wrapped:maxValue()
end


WrapperSub.FlatCache = {}
local FlatCache = WrapperSub.FlatCache
FlatCache.lastValue = 0
function FlatCache.new(wrapped)
    local data =setmetatable(Wrapper.new(wrapped),FlatCache)
    return data
end
function FlatCache:compute(context)
    local qX = math.floor(context.X / 4)
    local qZ = math.floor(context.Z / 4)
    if (self.lastQuartX ~= qX or self.lastQuartZ ~= qZ) then
        self.lastValue = self.wrapped:compute(newcontext(qX*4, 0, qZ*4));
        self.lastQuartX = qX;
        self.lastQuartZ = qZ;
    end
    return self.lastValue;
end
function FlatCache:mapAll(visitor)
    return visitor.map(FlatCache.new(self.wrapped:mapAll(visitor)))
end


WrapperSub.CacheAllInCell = {}
local CacheAllInCell = WrapperSub.CacheAllInCell
function CacheAllInCell.new(wrapped)
    local data = setmetatable(Wrapper.new(wrapped),CacheAllInCell)
    return data
end
function CacheAllInCell:compute(context)
    return self.wrapped:compute(context)
end
function CacheAllInCell:mapAll(visitor)
    return visitor.map(self.new(self.wrapped:mapAll(visitor)))
end


WrapperSub.Cache2D = {}
local Cache2D = WrapperSub.Cache2D
function Cache2D.new(wrapped)
    local data = setmetatable(Wrapper.new(wrapped),Cache2D)
    return data
end
function Cache2D:compute(context)
    local qX =context.X 
    local qZ =context.Z
    if (self.lastBlockX ~= qX or self.lastBlockZ ~= qZ) then
        self.lastValue = self.wrapped:compute(context);
        self.lastBlockX = qX;
        self.lastBlockZ = qZ;
    end
    return self.lastValue;
end
function Cache2D:mapAll(visitor)
    return visitor.map(self.new(self.wrapped:mapAll(visitor)))
end

WrapperSub.CacheOnce = {}
local CacheOnce = WrapperSub.CacheOnce
function CacheOnce.new(wrapped)
    local data = setmetatable(Wrapper.new(wrapped),CacheOnce)
    return data
end
function CacheOnce:compute(context)
    if (self.lastBlockX ~= context.X or self.lastBlockZ ~= context.Z or self.lastBlockY ~= context.Y) then
        self.lastValue = self.wrapped:compute(context);
        self.lastBlockX = context.X;
        self.lastBlockZ = context.Z;
        self.lastBlockY = context.Y;
    end
    return self.lastValue;
end
function CacheOnce:mapAll(visitor)
    return visitor.map(self.new(self.wrapped:mapAll(visitor)))
end

WrapperSub.Interpolated = {}
local Interpolated = WrapperSub.Interpolated
Interpolated.cellWidth = 4 
Interpolated.cellHeight = 4 
function Interpolated.new(wrapped,cellWidth,cellHeight)
    local data = setmetatable(Wrapper.new(wrapped), Interpolated)
    data.cellWidth = cellWidth 
    data.cellHeight = cellHeight 
    data.values = {}
    return data
end
function Interpolated:compute(context)
    local w = self.cellWidth
    local h = self.cellHeight 
    local x = ((context.X % w + w) % w) / w
    local y = ((context.Y % h + h) % h) / h
    local z = ((context.Z % w + w) % w) / w
    local firstX = math.floor(context.X / w) * w
    local firstY = math.floor(context.Y / h) * h
    local firstZ = math.floor(context.Z / w) * w
    local noise000 = function()
        return self:computeCorner(firstX, firstY, firstZ)
    end
    local noise001 = function()
        return self:computeCorner(firstX, firstY, firstZ + w)
    end
    local noise010 = function()
        return self:computeCorner(firstX, firstY + h, firstZ)
    end
    local noise011 = function()
        return self:computeCorner(firstX, firstY + h, firstZ + w)
    end
    local noise100 = function()
        return self:computeCorner(firstX + w, firstY, firstZ)
    end
    local noise101 = function()
        return self:computeCorner(firstX + w, firstY, firstZ + w)
    end
    local noise110 = function()
        return self:computeCorner(firstX + w, firstY + h, firstZ)
    end
    local noise111 = function()
        return self:computeCorner(firstX + w, firstY + h, firstZ + w)
    end
    return lazyLerp3(x, y, z, noise000, noise100, noise010, noise110, noise001, noise101, noise011, noise111)
end
function Interpolated:computeCorner(x,y,z)
    local c = newcontext(x,y,z)
    if self.values[c] then
        return self.values[c]
    end
    local d = self.wrapped:compute(c);
    self.values[c] = d
    return d
end
function Interpolated:mapAll(visitor)
    return visitor.map(self.new(self.wrapped:mapAll(visitor)))
end
function Interpolated:withCellSize(cellWidth,cellHeight)
    return self.new(self.wrapped,cellWidth,cellHeight)
end


sub.Noise = {}
local Noise = sub.Noise
Noise.Subtables = {}
local Noisesub = Noise.Subtables
function Noise.new(xzScale,yScale,noiseData,noise)
    local data = setmetatable({xzScale=xzScale,yScale=yScale,noiseData=noiseData,noise=noise},Noise)
    return data
end
function Noise:compute(context)
    return self.noise and self.noise:sample(context.X*self.xzScale,context.Y*self.yScale,context.Z*self.xzScale) or 0
end
function Noise:maxValue()
    return self.noise and self.noise.maxValue or 2
end

--//todo: islands


Transformersub.WeirdScaledSampler = {}
local WeirdScaledSampler = Transformersub.WeirdScaledSampler
local RarityValueMapper = {'type_1', 'type_2'}
function WeirdScaledSampler.new(input,rarityValueMapper,noiseData,noise)
    local data = setmetatable(Transformersub.new(input),WeirdScaledSampler)
    data.rarityValueMapper = rarityValueMapper
    data.noiseData = noiseData
    data.noise = noise
    data.mapper = WeirdScaledSampler.ValueMapper[data.rarityValueMapper]
    return data
end
function WeirdScaledSampler:transform(context, density)
    if not self.noise then return 0 end
    local rarity = self.mapper(density)
    return rarity * math.abs(self.noise.sample(context.X/rarity,context.Y/rarity,context.Z/rarity))
end
function WeirdScaledSampler:mapAll(visitor)
    return visitor.map(self.new(self.input:mapAll(visitor),self.rarityValueMapper,self.noiseData,self.noise))
end
function WeirdScaledSampler:minValue()
    return 0
end
function WeirdScaledSampler:maxValue()
    return self.rarityValueMapper == "type_1" and 2 or 3
end
function WeirdScaledSampler:rarityValueMapper1(value)
    if (value < -0.5) then
        return 0.75;
    elseif (value < 0) then
        return 1;
    elseif (value < 0.5) then
        return 1.5;
    else 
        return 2;
    end
end
function WeirdScaledSampler:rarityValueMapper2(value)
    if (value < -0.75) then
        return 0.5;
    elseif (value < -0.5) then
        return 0.75;
    elseif (value < 0.5) then
        return 1;
    elseif (value < 0.75) then
        return 2;
    else 
        return 3;
    end
end
WeirdScaledSampler.ValueMapper = {
    type_1 = WeirdScaledSampler.rarityValueMapper1,
    type_2 = WeirdScaledSampler.rarityValueMapper2
}


Noisesub.ShiftedNoise = {}
local ShiftedNoise = Noisesub.ShiftedNoise
function ShiftedNoise.new(shiftX, shiftY, shiftZ, xzScale, yScale, noiseData, noise)
    local data = setmetatable(Noise.new(xzScale,yScale,noiseData,noise),ShiftedNoise)
    data.shiftX = shiftX
    data.shiftY = shiftY
    data.shiftZ = shiftZ
    return data
end
function ShiftedNoise:compute(context)
    local xx = context.X * self.xzScale + self.shiftX:compute(context)
    local yy = context.Y * self.yScale + self.shiftY:compute(context)
    local zz = context.Z * self.xzScale + self.shiftZ:compute(context)
    return self.noise and self.noise:sample(xx,yy,zz) or 0
end
function ShiftedNoise:mapAll(visitor)
    return visitor.map(ShiftedNoise.new(self.shiftX:mapAll(visitor),self.shiftY:mapAll(visitor),self.shiftZ:mapAll(visitor),self.xzScale,self.yScale,self.noiseData,self.noise))
end
sub.RangeChoice = {}
local RangeChoice = sub.RangeChoice
function RangeChoice.new(input, minInclusive, maxExclusive, whenInRange, whenOutOfRange)
    local data = setmetatable({input=input, minInclusive=minInclusive, maxExclusive=maxExclusive, whenInRange=whenInRange, whenOutOfRange=whenOutOfRange},RangeChoice)
    return data
end
function RangeChoice:compute(context)
    local x = self.input:compute(context);
    return (self.minInclusive <= x and x < self.maxExclusive)
            and self.whenInRange:compute(context)
            or self.whenOutOfRange:compute(context); 
end
function RangeChoice:mapAll(visitor)
    return visitor.map(self.new(self.input:mapAll(visitor), self.minInclusive, self.maxExclusive, self.whenInRange:mapAll(visitor), self.whenOutOfRange:mapAll(visitor)))
end
function RangeChoice:minValue()
    return math.min(self.whenInRange:minValue(), self.whenOutOfRange:minValue())
end
function RangeChoice:maxValue()
    return math.max(self.whenInRange:maxValue(), self.whenOutOfRange:maxValue());
end


sub.ShiftNoise = {}
local ShiftNoise = sub.ShiftNoise
ShiftNoise.Subtables = {}
local ShiftNoiseSub = ShiftNoise.Subtables
function ShiftNoise.new(noiseData,offsetNoise)
    local data = setmetatable({noiseData = noiseData,offsetNoise = offsetNoise},ShiftNoise)
    return data
end
function ShiftNoise:compute(context)
    return self.offsetNoise and self.offsetNoise:sample(context.X*.25,context.Y*.25,context.Z*.25) or 0
end
function ShiftNoise:maxValue()
    return (self.offsetNoise and self.offsetNoise.maxValue or 2)*4
end


ShiftNoiseSub.ShiftA = {}
local ShiftA = ShiftNoiseSub.ShiftA
function ShiftA.new(noiseData, offsetNoise)
    local data = setmetatable(ShiftNoise.new(noiseData, offsetNoise),ShiftA)
    return data
end
function ShiftA:compute(context)
    return ShiftNoise.compute(self,(newcontext(context.X,0,context.Z)))
end
function ShiftA:withNewNoise(newNoise)
    return self.new(self.noiseData,newNoise)
end

ShiftNoiseSub.ShiftB = {}
local ShiftB = ShiftNoiseSub.ShiftB
function ShiftB.new(noiseData, offsetNoise)
    local data = setmetatable(ShiftNoise.new(noiseData, offsetNoise),ShiftB)
    return data
end
function ShiftB:compute(context)
    return ShiftNoise.compute(self,(newcontext(context.Z,context.X,0)))
end
function ShiftB:withNewNoise(newNoise)
    return self.new(self.noiseData,newNoise)
end


ShiftNoiseSub.Shift = {}
local Shift = ShiftNoiseSub.Shift
function Shift.new(noiseData, offsetNoise)
    local data = setmetatable(ShiftNoise.new(noiseData, offsetNoise),Shift)
    return data
end
function Shift:withNewNoise(newNoise)
    return self.new(self.noiseData,newNoise)
end


Transformersub.BlendDensity = {}
local BlendDensity = Transformersub.BlendDensity
function BlendDensity.new(input)
    local data = setmetatable(Transformer.new(input),BlendDensity)
    return data
end
function BlendDensity:transform(context,density)
    return density
end
function BlendDensity:mapAll(visitor)
    return visitor.map(self.new(self.input:mapAll(visitor)))
end
function BlendDensity:minValue()
    return -math.huge
end
function BlendDensity:maxValue()
    return math.huge
end


Transformersub.Clamp = {}
local Clamp = Transformersub.Clamp
function Clamp.new(input,min,max)
    local data = setmetatable(Transformer.new(input),Clamp)
    data.min = min
    data.max = max
    return data
end
function Clamp:transform(context,density)
    return math.clamp(density,self.min, self.max)
end
function Clamp:mapAll(visitor)
    return visitor.map(self.new(self.input:mapAll(visitor),self.min,self.max))
end
function Clamp:minValue()
    return self.min
end
function Clamp:maxValue()
    return self.max
end


Transformersub.Mapped = {}
local Mapped = Transformersub.Mapped
local MappedType = {'abs', 'square', 'cube', 'half_negative', 'quarter_negative', 'squeeze'}
Mapped.MappedTypes = {
    abs = function(d) return math.abs(d) end,
    square = function(d) return d*d end,
    cube = function(d) return d*d*d end,
    half_negative = function(d) return d> 0 and d or d*.5 end,
    quarter_negative = function(d) return d>0 and d or d *.25 end,
    squeeze = function(d) 
        local c = math.clamp(d,-1,1)
        return c/2 -c *c *c/24
    end,
}
function Mapped.new(type,input,min,max)
    local data = setmetatable(Transformer.new(input),Mapped)
    data.type = type
    data.min = min
    data.max = max
    data.transformer = Mapped.MappedTypes[data.type]
    return data
end
function Mapped:transform(context,density)
    return self.transformer(density)
end
function Mapped:mapAll(visitor)
    return visitor.map(self.new(self.type,self.input:mapAll(visitor)))
end
function Mapped:minValue()
    return self.min or -math.huge
end
function Mapped:maxValue()
    return self.max or math.huge
end
function Mapped:withMinMax()
    local minInput = self.input:minValue()
    local min = self.transformer(minInput)
    local max = self.transformer(self.input:maxValue())
    if self.type == 'abs' or self.type == 'square' then
        max = math.max(min,max)
        min = math.max(0,minInput)
    end
    return self.new(self.type,self.input,min,max)
end


local Ap2Type = {'add', 'mul', 'min', 'max'}
sub.Ap2 = {}
local Ap2 = sub.Ap2
function Ap2.new(type,argument1,argument2,min,max)
    if max ~= max then
        error("nan")
    end
    local data = setmetatable({type = type,argument1=argument1,argument2=argument2,min=min,max=max},Ap2)
    return data
end
function Ap2:compute(context)
    local a = self.argument1:compute(context)
    if self.type =='add' then
        return a + self.argument2:compute(context)
    elseif self.type =='mul' then
        return a == 0 and 0 or a* self.argument2:compute(context)
    elseif self.type =='min' then
        return a < self.argument2:minValue() and a or math.min(a,self.argument2:compute(context))
    elseif self.type =='max' then
        return a > self.argument2:maxValue() and a or math.max(a,self.argument2:compute(context))
    end
end
function Ap2:mapAll(visitor) 
    return visitor.map(Ap2.new(self.type,self.argument1:mapAll(visitor),self.argument2:mapAll(visitor)))
end
function Ap2:minValue()
    return self.min or -math.huge
end
function Ap2:maxValue()
    return self.max or math.huge
end
local function isNan(x) return x == x and x end
function Ap2:withMinMax()
    local min1 = self.argument1:minValue()
    local min2 = self.argument2:minValue()
    local max1 = self.argument1:maxValue()
    local max2 = self.argument2:maxValue()
    if ((self.type == 'min' or self.type == 'max') and (min1 >= max2 or min2 >= max1)) then
        warn(`Creating a ${self.type} function between two non-overlapping inputs`);
        end
        local min, max

    if self.type == 'add' then
        min = min1 + min2
        max = max1 + max2
    elseif self.type == 'mul' then
        if min1 > 0 and min2 > 0 then
            min = isNan(min1 * min2) or 0
        elseif max1 < 0 and max2 < 0 then
            min = isNan(max1 * max2) or 0
        else
            min = math.min(isNan(min1 * max2) or 0, isNan(min2 * max1) or 0)
        end
        
        if min1 > 0 and min2 > 0 then
            max = isNan(max1 * max2) or 0
        elseif max1 < 0 and max2 < 0 then
            max = isNan(min1 * min2) or 0
        else
            max = math.max(isNan(min1 * min2) or 0, isNan(max1 * max2) or 0)
        end
    elseif self.type == 'min' then
        min = math.min(min1, min2)
        max = math.min(max1, max2)
    elseif self.type == 'max' then
        min = math.max(min1, min2)
        max = math.max(max1, max2)
    end
    return self.new(self.type,self.argument1,self.argument2,min,max)
end



sub.Spline = {}
local Spline = sub.Spline
function Spline.new(spline)
    local data = setmetatable({spline=spline},Spline)
    return data
end
function Spline:compute(context)
    return self.spline:compute(context)
end
function Spline:mapAll(visitor)
    local newCubicSpline = self.spline:mapAll(function(fn)
        if type(fn) == "table" and fn.IsChildOfDensityFunction then
            return fn:mapAll(visitor)
        end
        return fn
    end)
    newCubicSpline:calculateMinMax()
    return visitor.map(self.new(newCubicSpline))
end
function Spline:minValue()
    return self.spline:min()
end
function Spline:maxValue()
    return self.spline:max()
end


sub.YClampedGradient = {}
local YClampedGradient = sub.YClampedGradient
function YClampedGradient.new(fromY, toY, fromValue, toValue)
    local data = setmetatable({fromY=fromY, toY=toY,fromValue=fromValue,toValue=toValue},YClampedGradient)
    return data
end
function YClampedGradient:compute(context)
    return mathf.clampedMap(context.Y,self.fromY,self.toY,self.fromValue,self.toValue)
end
function YClampedGradient:minValue()
    return math.min(self.fromValue,self.toValue)
end
function YClampedGradient:maxValue()
    return math.max(self.fromValue,self.toValue)
end


sub.Reference = {}
local Reference = sub.Reference

function Reference.new(key,deafult)
    local data = setmetatable({key=key,deafult = deafult},Reference)
    return data
end
function Reference:compute()
    return storage.get(self.key) or self.deafult or 0
end
function Reference:maxValue()
    return self:compute()
end

sub.SharedReference = {}
local SharedReference = sub.SharedReference

function SharedReference.new(key,deafult)
    local data = setmetatable({key=key,deafult = deafult},SharedReference)
    return data
end
function SharedReference:compute()
    return storage.getShared(self.key) or self.deafult or 0
end
function SharedReference:maxValue()
    return self:compute()
end

WrapperSub.Set = {}
local Set = WrapperSub.Set
function Set.new(wrapped,key)
    local data =setmetatable(Wrapper.new(wrapped),Set)
    data.key = key or "defult"
    return data
end
function Set:compute(context)
    local value = self.wrapped:compute(context)
    storage.set(self.key,value)
    return value;
end
function Set:mapAll(visitor)
    return visitor.map(Set.new(self.wrapped:mapAll(visitor),self.key))
end

WrapperSub.SharedSet = {}
local SharedSet = WrapperSub.SharedSet
function SharedSet.new(wrapped,key)
    local data =setmetatable(Wrapper.new(wrapped),SharedSet)
    data.key = key or "defult"
    return data
end
function SharedSet:compute(context)
    local value = self.wrapped:compute(context)
    storage.setShared(self.key,value)
    return value;
end
function SharedSet:mapAll(visitor)
    return visitor.map(SharedSet.new(self.wrapped:mapAll(visitor),self.key))
end

function DensityFunctions.Evaluate(obj,inputParser)
    inputParser = inputParser or DensityFunctions.Evaluate
    if typeof(obj) == "string" then
        return HolderHolder.new(Holder.reference(WorldgenRegistries.DENSITY_FUNCTION,Identifier.parse(obj)))
    end
    if typeof(obj) == "number" then
        return Constant.new(obj)
    end
    local root = obj or {}
   -- Assuming Json.readString, Json.readNumber, and other functions are available
    local str = root.type or ""
    local type = (string.match(str, ":(.*)") or str):gsub("^%s*(.-)%s*$", "%1")
    local result
    if type == 'blend_alpha' then
        result = ConstantMinMax.new(1, 0, 1)
    elseif type == 'reference' then
        result = Reference.new(root.key,root.deafult)
    elseif type == 'shared_reference' then
        result = SharedReference.new(root.key,root.deafult)
    elseif type == "set" then
        result = Set.new(inputParser(root.argument),root.key)
    elseif type == "shared_set" then
        result = SharedSet.new(inputParser(root.argument),root.key)
    elseif type == 'blend_offset' then
        result = ConstantMinMax.new(0, -math.huge, math.huge)
    elseif type == 'beardifier' then
        result = ConstantMinMax.new(0, -math.huge, math.huge)
    elseif type == 'old_blended_noise' then
        result = OldBlendedNoise.new(root.xz_scale or 1, (root.y_scale) or 1, (root.xz_factor) or 80, (root.y_factor) or 160,(root.smear_scale_multiplier) or 8)
    elseif type == 'flat_cache' then
        result = FlatCache.new(inputParser(root.argument))
    elseif type == 'interpolated' then
        result = Interpolated.new(inputParser(root.argument))
    elseif type == 'cache_2d' then
        result = Cache2D.new(inputParser(root.argument))
    elseif type == 'cache_once' then
        result = CacheOnce.new(inputParser(root.argument))
    elseif type == 'cache_all_in_cell' then
        result = CacheAllInCell.new(inputParser(root.argument))
    elseif type == 'noise' then
        result = Noise.new((root.xz_scale) or 1, (root.y_scale) or 1, NoiseParser(root.noise))
    elseif type == 'end_islands' then
        result = nil
        error("end_islands not currently In")
    elseif type == 'weird_scaled_sampler' then
        result = WeirdScaledSampler(inputParser(root.input), root.rarity_value_mapper, NoiseParser(root.noise))
    elseif type == 'shifted_noise' then
        result = ShiftedNoise.new(inputParser(root.shift_x), inputParser(root.shift_y), inputParser(root.shift_z), (root.xz_scale) or 1, (root.y_scale) or 1, NoiseParser(root.noise))
    elseif type == 'range_choice' then
        result = RangeChoice.new(inputParser(root.input), (root.min_inclusive) or 0, (root.max_exclusive) or 1, inputParser(root.when_in_range), inputParser(root.when_out_of_range))
    elseif type == 'shift_a' then
        result = ShiftA.new(NoiseParser(root.argument))
    elseif type == 'shift_b' then
        result = ShiftB.new(NoiseParser(root.argument))
    elseif type == 'shift' then
        result = Shift.new(NoiseParser(root.argument))
    elseif type == 'blend_density' then
        result = BlendDensity.new(inputParser(root.argument))
    elseif type == 'clamp' then
        result = Clamp.new(inputParser(root.input), (root.min) or 0, (root.max) or 1)
    elseif type == 'abs' or type == 'square' or type == 'cube' or type == 'half_negative' or type == 'quarter_negative' or type == 'squeeze' then
        result = Mapped.new(type, inputParser(root.argument))
    elseif type == 'add' or type == 'mul' or type == 'min' or type == 'max' then
        result = Ap2.new((type), inputParser(root.argument1), inputParser(root.argument2))
    elseif type == 'spline' then
        result = Spline.new(CubicSpline.Evaluate(root.spline, inputParser))
    elseif type == 'constant' then
        result = Constant.new((root.argument) or 0)
    elseif type == 'y_clamped_gradient' then
        result = YClampedGradient.new((root.from_y) or -4064, (root.to_y) or 4062, (root.from_value) or -4064, (root.to_value) or 4062)
    else
        -- Default value if type doesn't match any cases
        result = Constant.ZERO
    end
    return result
end
return DensityFunctions