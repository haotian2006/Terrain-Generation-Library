local NoiseParameters = {}
function NoiseParameters.create(obj,ampl,usenormal,offset)
    return {obj,ampl,usenormal,offset}
end
function NoiseParameters.Evaluate(obj)
    return obj
end
return NoiseParameters