return {
    type = 'clamp',
    input = {
        type = 'add',
        argument1 = {
            type = 'mul',
            argument1 = {
                type = 'interpolated',
                argument = 'minecraft:overworld/offset',
            },
            argument2 = 80
        },
        argument2 = 100,
    },
    min = 40,
    max = 100,
}