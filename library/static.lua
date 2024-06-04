local common = require("utils.common")
local interactive = require("tech.interactive")


local module = {}

local static = function(path)
  return {
    sprite = {
      image = love.graphics.newImage(path)
    }
  }
end

module.scripture_straight = function()
  return common.extend(
    interactive(function(_, other)
      other.reads = "Hello, VSauce! Michael here.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    end),
    static("assets/sprites/scripture_straight.png"),
    {name = "ancient scripture"}
  )
end

module.mannequin = function()
  return common.extend(
    static("assets/sprites/mannequin.png"),
    {
      name = "mannequin",
      hp = 1000,
      get_armor = function() return 10 end,
    }
  )
end

module.wall = function()
  return static("assets/sprites/wall.png")
end

module.planks = function()
  return static("assets/sprites/planks.png")
end

module.grass = function()
  return static("assets/sprites/grass.png")
end

module.smooth_wall = function()
  return static("assets/sprites/smooth_wall.png")
end

module.crooked_wall = function()
  return static("assets/sprites/crooked_wall.png")
end

return module
