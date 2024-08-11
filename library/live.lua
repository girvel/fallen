local interactive = require("tech.interactive")
local animated = require("tech.animated")
local level = require("tech.level")
local sprite = require("tech.sprite")
local sound = require("tech.sound")
local railing = require("tech.railing")


local live, _, static = Module("library.live")

-- plain sprites --
local lever_packs = {
  on = animated.load_pack("assets/sprites/lever_on"),
  off = animated.load_pack("assets/sprites/lever_off"),
}

live.lever = function()
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

live.door = function(args)
  args = args or {}
  return Tablex.extend(
    animated(closed_door_pack),
    args.locked and {} or interactive(function(self)
      self:open()
      self.interact = nil
    end, not args.highlighted),
    {
      layer = "solids",
      view = "scene",
      name = "дверь",
      is_open = false,
      open = Dump.ignore_upvalue_size .. function(self)
        self:animate("open")
        self:when_animation_ends(function(_)
          self.animation.pack = open_door_pack
          level.change_layer(State.grids, self, "above_solids")
          self.is_open = true
        end)
      end,
    }
  )
end

local mannequin_sounds = {
  hit = sound.multiple("assets/sounds/hits_body", 0.3),
}

live.mannequin = function()
  return {
    sprite = sprite.image("assets/sprites/mannequin.png"),
    transparent_flag = true,
    layer = "solids",
    view = "scene",
    name = "манекен",
    hp = 1000,
    get_armor = function() return 5 end,
    sounds = mannequin_sounds,
  }
end

return live
