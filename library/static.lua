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
  return Tablex.extend(
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
  return Tablex.extend(
    animated(closed_door_pack),
    disable_interaction and {} or interactive(function(self)
      self.interact = nil
    end),
    {
      name = "дверь",
      is_open = false,
      open = function(self)
        self:animate("open")
        self:when_animation_ends(function(_)
          self.animation.pack = open_door_pack
          level.change_layer(State.grids, self, "tiles")
          self.is_open = true
        end)
      end,
    }
  )
end

module.scripture = function(kind, text)
  assert(kind and text, "scripture requires 2 arguments: kind of scripture and its content")
  return Tablex.extend(
    interactive(function(_, other)
      other.reads = text
    end),
    static_sprite("assets/sprites/scripture_" .. (kind or "straight") .. ".png"),
    {name = "древняя надпись"}
  )
end

module.mannequin = function()
  return Tablex.extend(
    static_sprite("assets/sprites/mannequin.png"),
    {
      name = "манекен",
      hp = 1000,
      get_armor = function() return 10 end,
    }
  )
end

local kid_pack = animated.load_pack("assets/sprites/kid")
module.kid = function()
  return Tablex.extend(
    animated(kid_pack),
    {name = "ребёнок", direction = "down", code_name = "kid"}
  )
end

local teacher_pack = animated.load_pack("assets/sprites/teacher")
module.teacher = function()
  return Tablex.extend(
    animated(teacher_pack),
    {name = "тренер", direction = "down", code_name = "teacher"}
  )
end

for _, name in ipairs({
  "wall", "planks", "bushes", "smooth_wall", "crooked_wall", "sand", "wall_with_vines",
  "key_point", "walkway",
}) do
  module[name] = function()
    return Tablex.extend(
      static_sprite("assets/sprites/" .. name .. ".png"),
      {code_name = name}
    )
  end
end

return module
