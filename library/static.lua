local interactive = require("tech.interactive")
local animated = require("tech.animated")
local level = require("tech.level")
local static_sprite = require("tech.static_sprite")


local module = {}

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

module.scripture = function(kind, path)
  assert(kind)
  return Tablex.extend(
    path and interactive(function(self)
      State.gui:show_page(self.path)
    end) or {},
    static_sprite("assets/sprites/scripture_" .. (kind or "straight") .. ".png"),
    {name = "древняя надпись", path = path}
  )
end

local mannequin_sounds = {
  hit = {Common.volumed_sound("assets/sounds/hits_soft_wood.wav", 0.3)},
}

module.mannequin = function()
  return Tablex.extend(
    static_sprite("assets/sprites/mannequin.png"),
    {
      name = "манекен",
      hp = 1000,
      get_armor = function() return 5 end,
      sounds = mannequin_sounds,
    }
  )
end

local planks_sounds = {
  move = Fun.range(4)
    :map(function(n)
      local sound = love.audio.newSource("assets/sounds/move_planks_0" .. n .. ".wav", "static")
      sound:setVolume(0.1)
      return sound
    end)
    :totable(),
}

module.planks = function()
  return Tablex.extend(
    static_sprite("assets/sprites/planks.png"),
    {
      code_name = "planks",
      sounds = planks_sounds,
    }
  )
end

for _, name in ipairs({
  "wall", "bushes", "smooth_wall", "crooked_wall", "sand", "wall_with_vines",
  "key_point", "walkway", "steel_wall",
}) do
  module[name] = function()
    return Tablex.extend(
      static_sprite("assets/sprites/" .. name .. ".png"),
      {code_name = name}
    )
  end
end

return module
