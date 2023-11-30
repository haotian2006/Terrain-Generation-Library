-- MinMaxNumberFunction
local utils = require(script.Parent.Utils)
local binarySearch = utils.binarySearch
local lerp = utils.lerp
local size = utils.Size
-- MinMaxNumberFunction
local MinMaxNumberFunction = {}
function MinMaxNumberFunction.is(obj)
    return type(obj) == "table" and obj.minValue ~= nil and obj.maxValue ~= nil
end

-- CubicSpline
local CubicSpline = {}

-- Constant
CubicSpline.Constant = {}
local Constant = CubicSpline.Constant
Constant.__index = Constant
function Constant.new(value)
    local newObj = {
        value = value
    }
    return setmetatable(newObj, Constant)
end
function Constant:compute()
    return self.value
end
function Constant:min()
    return self.value
end
function Constant:max()
    return self.value
end
function Constant:mapAll()
    return self
end
function Constant:calculateMinMax()
end

-- MultiPoint
CubicSpline.MultiPoint = {}
local MultiPoint = CubicSpline.MultiPoint
MultiPoint.__index = MultiPoint
function MultiPoint.new(coordinate, locations, values, derivatives)
    local newObj = {
        coordinate = coordinate,
        locations = locations or {},
        values = values or {},
        derivatives = derivatives or {},
        calculatedMin = -math.huge,
        calculatedMax = math.huge
    }
    return setmetatable(newObj, MultiPoint)
end
function MultiPoint:compute(c)
    local coordinate = self.coordinate:compute(c)
    local i = binarySearch(1, #(self.locations), function(n) return coordinate < self.locations[n] end) - 1
    local n = #(self.locations)
    if i < 1 then
        return self.values[1]:compute(c) + self.derivatives[1] * (coordinate - self.locations[1])
    end
    if i == n-1 then
        return self.values[n]:compute(c) + self.derivatives[n] * (coordinate - self.locations[n])
    end
    local loc0 = self.locations[i]
    local loc1 = self.locations[i + 1]
    local der0 = self.derivatives[i]
    local der1 = self.derivatives[i + 1]
    local f = (coordinate - loc0) / (loc1 - loc0)
    local val0 = self.values[i]:compute(c)
    local val1 = self.values[i + 1]:compute(c)
    local f8 = der0 * (loc1 - loc0) - (val1 - val0)
    local f9 = -der1 * (loc1 - loc0) + (val1 - val0)
    local f10 = lerp(f, val0, val1) + f * (1.0 - f) * lerp(f, f8, f9)
    return f10
end
function MultiPoint:min()
    return self.calculatedMin
end
function MultiPoint:max()
    return self.calculatedMax
end
function MultiPoint:mapAll(visitor)
    local newCoordinate = visitor(self.coordinate)
    local newValues = {}
    for i, value in (self.values) do
        newValues[i] = value:mapAll(visitor)
    end
    local newObj = MultiPoint.new(newCoordinate, self.locations, newValues, self.derivatives)
    return newObj
end
function MultiPoint:addPoint(location, value, derivative)
    table.insert(self.locations, location)
    if type(value) == "number" then
        value = CubicSpline.Constant.new(value)
    end
    table.insert(self.values, value)
    table.insert(self.derivatives, derivative or 0)
    return self
end
function MultiPoint:calculateMinMax()
    if not MinMaxNumberFunction.is(self.coordinate) then
        return
    end
    local lastIdx = #(self.locations)-1
    local splineMin = math.huge
    local splineMax = -math.huge
    local coordinateMin = self.coordinate:minValue()
    local coordinateMax = self.coordinate:maxValue()
    for _, innerSpline in ipairs(self.values) do
        innerSpline:calculateMinMax()
    end
    if coordinateMin < self.locations[1] then
        local minExtend = MultiPoint.linearExtend(coordinateMin, self.locations, self.values[1]:min(), self.derivatives, 1)
        local maxExtend = MultiPoint.linearExtend(coordinateMin, self.locations, self.values[1]:max(), self.derivatives, 1)
        splineMin = math.min(splineMin, math.min(minExtend, maxExtend))
        splineMax = math.max(splineMax, math.max(minExtend, maxExtend))
    end
    if coordinateMax > self.locations[lastIdx] then
        local minExtend = MultiPoint.linearExtend(coordinateMax, self.locations, self.values[lastIdx]:min(), self.derivatives, lastIdx)
        local maxExtend = MultiPoint.linearExtend(coordinateMax, self.locations, self.values[lastIdx]:max(), self.derivatives, lastIdx)
        splineMin = math.min(splineMin, math.min(minExtend, maxExtend))
        splineMax = math.max(splineMax, math.max(minExtend, maxExtend))
    end
    for _, innerSpline in ipairs(self.values) do
        splineMin = math.min(splineMin, innerSpline:min())
        splineMax = math.max(splineMax, innerSpline:max())
    end
    for i = 1, lastIdx do
        local locationLeft = self.locations[i]
        local locationRight = self.locations[i + 1]
        local locationDelta = locationRight - locationLeft
        local splineLeft = self.values[i]
        local splineRight = self.values[i + 1]
        local minLeft = splineLeft:min()
        local maxLeft = splineLeft:max()
        local minRight = splineRight:min()
        local maxRight = splineRight:max()
        local derivativeLeft = self.derivatives[i]
        local derivativeRight = self.derivatives[i + 1]
        if derivativeLeft ~= 0.0 or derivativeRight ~= 0.0 then
            local maxValueDeltaLeft = derivativeLeft * locationDelta
            local maxValueDeltaRight = derivativeRight * locationDelta
            local minValue = math.min(minLeft, minRight)
            local maxValue = math.max(maxLeft, maxRight)
            local minDeltaLeft = maxValueDeltaLeft - maxRight + minLeft
            local maxDeltaLeft = maxValueDeltaLeft - minRight + maxLeft
            local minDeltaRight = -maxValueDeltaRight + minRight - maxLeft
            local maxDeltaRight = -maxValueDeltaRight + maxRight - minLeft
            local minDelta = math.min(minDeltaLeft, minDeltaRight)
            local maxDelta = math.max(maxDeltaLeft, maxDeltaRight)
            splineMin = math.min(splineMin, minValue + 0.25 * minDelta)
            splineMax = math.max(splineMax, maxValue + 0.25 * maxDelta)
        end
    end
    self.calculatedMin = splineMin
    self.calculatedMax = splineMax
end
function MultiPoint.linearExtend(location, locations, value, derivatives, useIndex)
    local derivative = derivatives[useIndex]
    return derivative == 0.0 and value or value + derivative * (location - locations[useIndex])
end

function CubicSpline.Evaluate(obj, extractor)
    if type(obj) == "number" then
        return Constant.new(obj)
    end
    
    local root = (obj) or {}
    local spline = MultiPoint.new(extractor(root.coordinate))
    local points = {}
    for i,v in root.points do
       table.insert(points,v or {}) 
    end
    if #(points) == 0 then
        return Constant.new(0)
    end
    
    for i, point in (points) do
        local location = (point.location) or 0
        local value = CubicSpline.Evaluate(point.value, extractor)
        local derivative = (point.derivative) or 0
        spline:addPoint(location, value, derivative)
    end
    
    return spline
end
return CubicSpline