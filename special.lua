local random = require("utils.random")


local module = {}

module.floating_damage = function(number, position)
  return {
    off_grid_position = (position - Vector({1, 1})) * 16
      + Vector({random.d(12) - 6, random.d(12) - 6}),  -- TODO fix magic number
    layer = "sfx",
    sprite = {
      text = number,
      size = 10,
    },
    life_time = 3,
  }
end

return module
