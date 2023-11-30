local DensityFunction = require(script.Parent.Parent.DensityFunction)
local size = require(script.Parent.Parent.Parent.math.Utils).Size
local square = function(x)
    return x*x
end
local PARAMETER_SPACE = 6;
local Climate = {Subtables = {},Children = {}}
local sub = Climate.Subtables
Climate.__index = Climate
Climate.__type = "Climate"
Climate.IsChildOfClimate = true 

function Climate:IsA(type)
    if self.__type == type then return true end 
    if self.__parent then return self.__parent:IsA(type) end 
end
function Climate:GetClass(name)
    return self[name]
end

local function applySubtables(table)
    for i,v in table.Subtables do
        v.__index = setmetatable(v,table)
        v.__type = i
        v.__parent = table
        if rawget(v,"Subtables") then
            applySubtables(v)
        end
        Climate[i] = v
    end
end
function Climate:Init()
    applySubtables(self)
    return self
end

sub.example = {}
local example = sub.example
function example.new()
    local data = setmetatable({},example)
    return data
end


sub.Param = {}
local Param = sub.Param
function Param.new(min,max)
    local data = setmetatable({min=min,max=max},Param)
    return data
end
function Param:distance(param)
    local diffMax = (typeof(param) == "number" and param or param.min)-self.max
    local diffMin = self.min - (typeof(param) == "number" and param or param.max)
    if diffMax>0 then
        return diffMax
    end
    return math.max(diffMin,0)
end
function Param:union(param)
    return self.new(math.min(self.min,param.min),math.max(self.max,param.max))
end
function Param.Evaluate(obj)
    if typeof(obj) == "number" then
        return Param.new(obj,obj)
    end
    return Param.new(obj[1],obj[2]) 
end


sub.ParamPoint = {}
local ParamPoint = sub.ParamPoint
function ParamPoint.new(temperature, humidity, continentalness, erosion, depth, weirdness, offset)
    local data = setmetatable({temperature=temperature, humidity=humidity, continentalness=continentalness, erosion=erosion, depth=depth, weirdness=weirdness, offset=offset or 0},ParamPoint)
    return data
end
function ParamPoint:fittness(point)
    return square(self.temperature:distance(point.temperature))
    + square(self.humidity:distance(point.humidity))
    + square(self.continentalness:distance(point.continentalness))
    + square(self.erosion:distance(point.erosion))
    + square(self.depth:distance(point.depth))
    + square(self.weirdness:distance(point.weirdness))
    + square(self.offset - point.offset);
end
function ParamPoint:space()
      return {self.temperature, self.humidity, self.continentalness, self.erosion, self.depth, self.weirdness,  Param.new(self.offset, self.offset)};
end
function ParamPoint.Evaluate(obj)
    return ParamPoint.new(Param.Evaluate(obj.temperature),Param.Evaluate(obj.humidity),Param.Evaluate(obj.continentalness),Param.Evaluate(obj.erosion),
        Param.Evaluate(obj.depth),Param.Evaluate(obj.weirdness),obj.offset or 0)
end


sub.TargetPoint = {}
local TargetPoint = sub.TargetPoint
function TargetPoint.new(temperature, humidity, continentalness, erosion, depth, weirdness)
    local data = setmetatable({temperature=temperature, humidity=humidity, continentalness=continentalness, erosion=erosion, depth=depth, weirdness=weirdness},TargetPoint)
    return data
end
function TargetPoint:getoffset()
    return 0
end
function TargetPoint:toArray()
    return {self.temperature, self.humidity, self.continentalness, self.erosion, self.depth, self.weirdness, self.offset}
end

sub.RNode = {}
local RNode = sub.RNode
RNode.Subtables = {}
local RNodeSub = RNode.Subtables
function RNode.new(space)
    local o = {}
    setmetatable(o, RNode)
    for i,v in space do
        space[i] = Climate.param(v)
    end
    o.space = space
    return o
end

function RNode:distance(values)
    local result = 0
    for i = 1, PARAMETER_SPACE do
        result = result + square(self.space[i]:distance(values[i]))
    end
    return result
end

RNodeSub.RSubTree = {}
local RSubTree = RNodeSub.RSubTree
function RSubTree.new(children)
    local space = RSubTree.buildSpace(children)
    local o = RNode.new(space)
    setmetatable(o, RSubTree)
    o.children = children
    return o
end

function RSubTree.buildSpace(nodes)
    local space = {}
    for i = 1, PARAMETER_SPACE do
        space[i] = Param.new(math.huge, -math.huge)
    end
    for _, node in (nodes) do
        for i = 1, PARAMETER_SPACE do
            space[i] = space[i]:union(node.space[i])
        end
    end
    return space
end

function RSubTree:search(values,closest_leaf, distance)
    local dist = closest_leaf and distance(closest_leaf, values) or math.huge
    local leaf = closest_leaf 
    for _, node in self.children do
        local d1 = distance(node, values)   
        if dist <= d1 then continue end  
        local leaf2 = node:search(values, leaf, distance) 
        if not leaf2 then continue end 
        local d2 = (node == leaf2) and d1 or distance(leaf2, values)      
        if d2 == 0 then return leaf2 end  
        if dist <= d2 then continue end
        dist = d2
        leaf = leaf2
    end
    return leaf
end


RNodeSub.RLeaf = {}
local RLeaf = RNodeSub.RLeaf
function RLeaf.new(point,thing)
    local o = RNode.new(point:space())
    setmetatable(o, RLeaf)
    o.thing = thing
    return o
end
function RLeaf:search()
    return self
end

sub.RTree = {}
local RTree = sub.RTree
RTree.CHILDREN_PER_NODE = 10
function RTree.new(points)
    local o = {}
    setmetatable(o, RTree)
    if size(points) == 0 then
        error('At least one point is required to build search tree')
    end
    local nep = {}
    for i,v in points do
        nep[i] = RLeaf.new(v[1],v[2])
    end
    o.root = RTree.build(nep)
    return o
end

function RTree.build(nodes)
    if size(nodes) == 1 then
        return nodes[1]
    end
    if size(nodes) <= RTree.CHILDREN_PER_NODE then
        local sortedNodes = {}
        for _, node in (nodes) do
            local key = 0.0
            for i = 1, PARAMETER_SPACE do
                local param = node.space[i]
                key = key + math.abs((param.min + param.max) / 2.0)
            end
            table.insert(sortedNodes, {key,node })
        end
    
        table.sort(sortedNodes, function(a, b)
            return a[1] < b[1]
        end)
    
        local sortedNodeList = {}
        for a, entry in (sortedNodes) do
            sortedNodeList[a] = entry[2]
        end
    
        return RSubTree.new(sortedNodeList)
    end
    local f = math.huge
    local n3 = -1
    local result = {}
    for n2 = 1, PARAMETER_SPACE  do
        nodes = RTree.sort(nodes, n2, false)
        result = RTree.bucketize(nodes)
        local f2 = 0.0
        for _, subTree2 in (result) do
            f2 = f2 + RTree.area(subTree2.space)
        end
        if not (f > f2) then
            continue
        end
        f = f2
        n3 = n2
    end

    nodes = RTree.sort(nodes, n3, false)
    result = RTree.bucketize(nodes)
    result = RTree.sort(result, n3, true)
 --   result = RTree.map(result, function(subTree) return RTree.build(subTree.children) end)
    for i, subTree in result do
        local builtSubTree = RTree.build(subTree.children)
        result[i] = builtSubTree
    end
    return RSubTree.new(result)
end

function RTree.sort(nodes, i, abs)
    local new = {}
    for ind,node in nodes do
        local param = node.space[i]
        local f= (param.min+param.max)/2
        local key = abs and math.abs(f) or f
        new[ind] = {key,node}
    end
    nodes = {}
    table.sort(new,function(a,b)
        return a[1] < b[1]
    end)
    for ind,data in new do
        nodes[ind] = data[2]
    end
    return nodes
end

function RTree.bucketize(nodes)
    local arrayList = {}
    local arrayList2 = {}
    local n = 10 ^ math.floor(math.log(size(nodes) - 0.01) / math.log(10))
    for _, node in (nodes) do
        table.insert(arrayList2, node)
        if size(arrayList2) < n then
            continue
        end
        table.insert(arrayList, RSubTree.new(arrayList2))
        arrayList2 = {}
    end
    if size(arrayList2) ~= 0 then
        table.insert(arrayList, RSubTree.new(arrayList2))
    end
    return arrayList
end

function RTree.area(params)
    local f = 0.0
    for _, param in (params) do
        f = f + math.abs(param.max - param.min)
    end
    return f
end

function RTree:search(target, distance)
    local leaf = self.root:search(target:toArray(),self.last_leaf, distance)
    self.last_leaf = leaf
    return leaf:thing()
end

sub.Parameters = {}
local Parameters = sub.Parameters
function Parameters.new(things)
    local data = setmetatable({index = RTree.new(things)},Parameters)
    return data
end
local dist = function(node, values)
    return node:distance(values)
end
function Parameters:find( target)
    return self.index:search(target, dist)
end

sub.Sampler = {}
local Sampler = sub.Sampler
function Sampler.new(temperature, humidity, continentalness, erosion, depth, weirdness)
    local self = setmetatable({}, Sampler)
    self.temperature = temperature
    self.humidity = humidity
    self.continentalness = continentalness
    self.erosion = erosion
    self.depth = depth
    self.weirdness = weirdness
    return self
end

function Sampler.fromRouter(router)
    return Sampler.new(router.temperature, router.humidity , router.continents, router.erosion, router.depth, router.weirdness )
end

function Sampler:sample( x, y, z)
    local context = Vector3.new(bit32.lshift(x, 2), bit32.lshift(y, 2), bit32.lshift(z, 2)) 
    return Climate.target(
        self.temperature:compute(context),
        self.humidity:compute(context),
        self.continentalness:compute(context),
        self.erosion:compute(context),
        self.depth:compute(context),
        self.weirdness:compute(context)
    )
end

function Climate.target(temperature, humidity, continentalness, erosion, depth, weirdness)
    return TargetPoint.new(temperature, humidity, continentalness, erosion, depth, weirdness);
end
function Climate.parameters(temperature, humidity, continentalness, erosion, depth, weirdness, offset)
    return ParamPoint.new(Climate.param(temperature), Climate.param(humidity), Climate.param(continentalness), Climate.param(erosion), Climate.param(depth), Climate.param(weirdness), offset); 
end
function Climate.param(value,max)
    if (typeof(value) == 'number') then
        return Param.new(value, max or value);
    end
    return value;
end
local i = false
if not i then 
    Climate:Init()
end
return Climate