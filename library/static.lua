local common = require("utils.common")
local interactive = require("tech.interactive")


local module = {}

module.scripture_straight = function()
  return common.extend(
    interactive(function(_, other)
      other.reads = "Hello, VSauce! Michael here.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    end),
    {
      name = "ancient scripture",
      was_interacted_with = false,
      sprite = {
        image = love.graphics.newImage("assets/sprites/scripture_straight.png")
      }
    }
  )
end

module.wall = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/wall.png"),
    },
  }
end

module.planks = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/planks.png")
    }
  }
end

module.grass = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/grass.png")
    }
  }
end

module.smooth_wall = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/smooth_wall.png")
    }
  }
end

module.crooked_wall = function()
  return {
    sprite = {
      image = love.graphics.newImage("assets/sprites/crooked_wall.png")
    }
  }
end

return module
