local texting = require("tech.texting")
local interactive = require("tech.interactive")
local animated = require("tech.animated")
local level = require("state.level")
local sprite = require("tech.sprite")
local sound = require("tech.sound")


local live, _, static = Module("library.palette.live")

-- plain sprites --
local lever_packs = {
  on = animated.load_pack("assets/sprites/animations/lever_on"),
  off = animated.load_pack("assets/sprites/animations/lever_off"),
}

live.lever = function()
  return Table.extend(
    animated(lever_packs.off),
    interactive(function(self)
      self.is_on = self.animation.pack ~= lever_packs.on
      local next_state = self.is_on and "on" or "off"
      self:animate("turn_" .. next_state):next(function(self)
        self.animation.pack = lever_packs[next_state]
      end)
    end),
    {name = "рычаг", is_on = false,}
  )
end

for _, prefix in ipairs({"", "black_"}) do
  local closed_door_pack = animated.load_pack("assets/sprites/animations/%sdoor/closed" % prefix)
  local open_door_pack = animated.load_pack("assets/sprites/animations/%sdoor/open" % prefix)

  live[prefix .. "door"] = function(args)
    args = args or {}
    return Table.extend(
      animated(closed_door_pack),
      interactive(function(self)
        if self.locked then
          if not State:exists(self._popup[1]) then
            self._popup = State:add_multiple(texting.popup(self.position, "above", "Закрыто."))
          end
          return
        end

        self:open()
      end, not args.highlighted),
      {
        codename = prefix .. "door",
        layer = "solids",
        view = "scene",
        name = "дверь",
        is_open = false,
        open = Dump.ignore_upvalue_size .. function(self)
          if self.is_open then return end
          self:animate("open"):next(function(_)
            self.animation.pack = open_door_pack
            level.change_layer(self, "above_solids")
            self.is_open = true
            self._interact = self.interact
            self.interact = nil
          end)
        end,
        close = Dump.ignore_upvalue_size .. function(self)
          if not self.is_open then return end
          self.animation.pack = closed_door_pack
          level.change_layer(self, "solids")
          self.is_open = false
          self.interact = self._interact
          self._interact = nil
        end,
        locked = args.locked,
        _popup = {},
      }
    )
  end
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
