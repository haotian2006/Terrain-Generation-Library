return {
    type = "minecraft:mul",
    argument1 = -3.0,
    argument2 = {
        type = "minecraft:add",
        argument1 = -0.3333333333333333,
        argument2 = {
            type = "minecraft:abs",
            argument = {
                type = "minecraft:add",
                argument1 = -0.6666666666666666,
                argument2 = {
                    type = "minecraft:abs",
                    argument = "minecraft:overworld/ridges"
                }
            }
        }
    }
}