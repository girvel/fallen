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
    {name = "рычаг", is_on = false,}
  )
end

local closed_door_pack = animated.load_pack("assets/sprites/closed_door")
local open_door_pack = animated.load_pack("assets/sprites/open_door")

module.door = function(disable_interaction)
  return common.extend(
    animated(closed_door_pack),
    disable_interaction and {} or interactive(function(self)
      self.interact = nil
    end),
    {
      name = "дверь",
      open = function(self)
        self:animate("open")
        self:when_animation_ends(function(_, state)
          self.animation.pack = open_door_pack
          level.change_layer(state.grids, self, "tiles")
        end)
      end,
    }
  )
end

module.scripture = function(kind, text)
  assert(kind and text, "scripture requires 2 arguments: kind of scripture and its content")
  return common.extend(
    interactive(function(_, other)
      other.reads = text
    end),
    static_sprite("assets/sprites/scripture_" .. (kind or "straight") .. ".png"),
    {name = "древняя надпись"}
  )
end

module.mannequin = function()
  return common.extend(
    static_sprite("assets/sprites/mannequin.png"),
    {
      name = "манекен",
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
