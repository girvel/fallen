local common = require("utils.common")
local interactive = require("tech.interactive")
local animated = require("tech.animated")
local level = require("tech.level")


local module = {}

local static_sprite = function(path)
  return {
    sprite = {
      image = love.graphics.newImage(path)
    }
  }
end

local lever_packs = {
  on = animated.load_pack("assets/sprites/lever_on"),
  off = animated.load_pack("assets/sprites/lever_off"),
}

module.lever = function()
  return common.extend(
    animated(lever_packs.off),
    interactive(function(self)
      self.is_on = self.animation.pack ~= lever_packs.on
      local next_state = self.is_on and "on" or "off"
      self:animate("turn_" .. next_state)
      self:when_animation_ends(function(self)
        self.animation.pack = lever_packs[next_state]
      end)
    end),
    {name = "lever", is_on = false,}
  )
end

local closed_door_pack = animated.load_pack("assets/sprites/closed_door")
local open_door_pack = animated.load_pack("assets/sprites/open_door")

module.door = function()
  return common.extend(
    animated(closed_door_pack),
    interactive(function(self)
      self.interact = nil
      self:animate("open")
      self:when_animation_ends(function(self, state)
        self.animation.pack = open_door_pack
        level.change_layer(state.grids, self, "tiles")
      end)
    end),
    {name = "door"}
  )
end

module.scripture_straight = function()
  return common.extend(
    interactive(function(_, other)
      other.reads = "Hello, VSauce! Michael here.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    end),
    static_sprite("assets/sprites/scripture_straight.png"),
    {name = "ancient scripture"}
  )
end

module.mannequin = function()
  return common.extend(
    static_sprite("assets/sprites/mannequin.png"),
    {
      name = "mannequin",
      hp = 1000,
      get_armor = function() return 10 end,
    }
  )
end

module.wall = function()
  return static_sprite("assets/sprites/wall.png")
end

module.planks = function()
  return static_sprite("assets/sprites/planks.png")
end

module.bushes = function()
  return static_sprite("assets/sprites/bushes.png")
end

module.smooth_wall = function()
  return static_sprite("assets/sprites/smooth_wall.png")
end

module.crooked_wall = function()
  return static_sprite("assets/sprites/crooked_wall.png")
end

return module
