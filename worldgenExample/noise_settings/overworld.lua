return {
    aquifers_enabled = true,
    default_block = {
        Name = "minecraft:stone"
    },
    default_fluid = {
        Name = "minecraft:water",
        Properties = {
            level = "0"
        }
    },
    disable_mob_generation = false,
    legacy_random_source = false, 
    noise = {
        height = 256,
        min_y = 0,
        size_horizontal = 1,
        size_vertical = 2
    },
    noise_Router = {
        barrier = {
            type = "minecraft:noise",
            noise = "minecraft:aquifer_barrier",
            xz_scale = 1.0,
            y_scale = 0.5
        },
        continents = "minecraft:overworld/continents",
        depth = {
            type = "reference",
            key = "depth"
          }, 
        depth_Debug =  {
          type = "minecraft:add",
          argument1 = {
              type = "minecraft:y_clamped_gradient",
              from_value = 1.5,
              from_y = -64,
              to_value = -1.5,
              to_y = 320
          },
          argument2 =  "minecraft:overworld/offset"
      },
        erosion = "minecraft:overworld/erosion",
        final_density =  {
            type = "minecraft:squeeze",
            argument = {
              type = "minecraft:mul",
              argument1 = 0.64,
              argument2 = {
                type = "minecraft:blend_density",
                argument = {
                  type = "minecraft:add",
                  argument1 = 0.1171875,
                  argument2 = {
                    type = "minecraft:mul",
                    argument1 = {
                      type = "minecraft:y_clamped_gradient",
                      from_y = 0,
                      to_y = 1,
                      from_value = 0,
                      to_value = 1
                    },
                    argument2 = {
                      type = "minecraft:add",
                      argument1 = -0.1171875,
                      argument2 = {
                        type = "minecraft:add",
                        argument1 = -0.078125,
                        argument2 = {
                          type = "minecraft:mul",
                          argument1 = {
                            type = "minecraft:y_clamped_gradient",
                            from_y = 240,
                            to_y = 256,
                            from_value = 1,
                            to_value = 0
                          },
                          argument2 = {
                            type = "minecraft:add",
                            argument1 = 0.078125,
                            argument2 = {
                                type = "minecraft:add",
                                argument1 = {
                                    type = "minecraft:mul",
                                    argument1 = 4.0,
                                    argument2 = {
                                      type = "minecraft:quarter_negative",
                                      argument = {
                                        type = "minecraft:mul",
                                        argument1 = {
                                          type = "minecraft:add",
                                          argument1 ={
                                            type = "minecraft:add",
                                            argument1 = "minecraft:overworld/depth"
                                            },
                                          argument2 = {
                                            type = "reference",
                                            key = "jaggedness"
                                            
                                          }
                                        },
                                        argument2 ={
                                            type = 'reference',
                                            key = 'factor'
                                        }
                                      }
                                    }
                                  },
                                argument2 = "minecraft:overworld/base_3d_noise"
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
        },

        initial_density_without_jaggedness = {
            type = "minecraft:add",
            argument1 = 0.1171875,
            argument2 = {
                type = "minecraft:mul",
                argument1 = {
                    type = "minecraft:y_clamped_gradient",
                    from_value = 0.0,
                    from_y = -64,
                    to_value = 1.0,
                    to_y = -40
                },
                argument2 = {
                    type = "minecraft:add",
                    argument1 = -0.1171875,
                    argument2 = {
                        type = "minecraft:add",
                        argument1 = -0.078125,
                        argument2 = {
                            type = "minecraft:mul",
                            argument1 = {
                                type = "minecraft:y_clamped_gradient",
                                from_value = 1.0,
                                from_y = 240,
                                to_value = 0.0,
                                to_y = 256
                            },
                            argument2 = {
                                type = "minecraft:add",
                                argument1 = 0.078125,
                                argument2 = {
                                    type = "minecraft:clamp",
                                    input = {
                                        type = "minecraft:add",
                                        argument1 = -0.703125,
                                        argument2 = {
                                            type = "minecraft:mul",
                                            argument1 = 4.0,
                                            argument2 = {
                                                type = "minecraft:quarter_negative",
                                                argument = {
                                                    type = "minecraft:mul",
                                                    argument1 = "minecraft:overworld/depth",
                                                    argument2 = {
                                                        type = 'reference',
                                                        key = 'factor'
                                                    }
                                                }
                                            }
                                        }
                                    },
                                    max = 64.0,
                                    min = -64.0
                                }
                            }
                        }
                    }
                }
            }
        },
        weirdness  = "minecraft:overworld/ridges",
        temperature = {
            type = "minecraft:shifted_noise",
            noise = "minecraft:temperature",
            shift_x = "minecraft:shift_x",
            shift_y = 0.0,
            shift_z = "minecraft:shift_z",
            xz_scale = 0.25,
            y_scale = 0.0
        },
        humidity = {
            type = "minecraft:shifted_noise",
            noise = "minecraft:vegetation",
            shift_x = "minecraft:shift_x",
            shift_y = 0.0,
            shift_z = "minecraft:shift_z",
            xz_scale = 0.25,
            y_scale = 0.0
        },
        xzOrder = {
            {
               type = 'set',
               argument  = {
                type = "minecraft:mul",
                argument1 = "minecraft:overworld/jaggedness",
                argument2 = {
                    type = "minecraft:half_negative",
                    argument = {
                    type = "minecraft:noise",
                    noise = "minecraft:jagged",
                    xz_scale = 1500.0,
                    y_scale = 0.0
                    }
                }
               },
               key = "jaggedness"
             },-- calculate the jaggedness
             {
                type = 'set',
                argument = "minecraft:overworld/offset",
                key = 'offset'
             },
             
             {
                type = 'set',
                argument = "minecraft:overworld/factor",
                key = 'factor'
             }
        }
    },
    ore_veins_enabled = true,
    sea_level = 63,
    biome_source = { 
  {
    biome = "minecraft:plains",
    parameters = {
        depth = 0,
        offset = 0.1,
        weirdness =0,
        erosion = 0,
        temperature =0,
        humidity =0,
        continentalness =0
    }
},
{
  biome = "minecraft:desert",
  parameters = { 
      depth = 0,
      offset = 0.0,
      weirdness =.2,
      erosion = -.1,
      temperature =0,
      humidity =-0,
      continentalness =0
  }
}
},
    spawn_target = { {
        continentalness = { -0.11, 1.0 },
        depth = 0.0,
        erosion = { -1.0, 1.0 },
        humidity = { -1.0, 1.0 },
        offset = 0.0,
        temperature = { -1.0, 1.0 },
        weirdness = { -1.0, -0.16 }
    }, {
        continentalness = { -0.11, 1.0 },
        depth = 0.0,
        erosion = { -1.0, 1.0 },
        humidity = { -1.0, 1.0 },
        offset = 0.0,
        temperature = { -1.0, 1.0 },
        weirdness = { 0.16, 1.0 }
    } },
}
