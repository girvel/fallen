local sound = require("tech.sound")
local interactive = require("tech.interactive")
local animated = require("tech.animated")
local level = require("tech.level")
local sprite = require("tech.sprite")
local sound = require("tech.sound")
local railing = require("tech.railing")
local pipes = require("library.palette.pipes")
local creature = require("mech.creature")
local on_solids = require("library.palette.on_solids")


local live, _, static = Module("library.palette.live")

local valve_rotating_sounds = sound.multiple("assets/sounds/valve_rotate", 0.05)
local pipe_valve_pack = animated.load_pack("assets/sprites/animations/pipe_valve")

live.valve = function(leaking_pipe_name)
  return Table.extend(
    animated(pipe_valve_pack),
    interactive(Dump.ignore_upvalue_size .. function(self, other)
      local target = State.rails.entities[self._leaking_pipe_name]
      sound.play(valve_rotating_sounds, self.position, "small")
      self:animate("rotate"):next(function()
        target.overflow_counter = 0
        pipes.burst_with_steam(target)
      end)
    end),
    {
      layer = "on_solids",
      view = "scene",
      name = "Вентиль",
      codename = "valve",
      transparent_flag = true,
      _leaking_pipe_name = leaking_pipe_name,
    }
  )
end

live.note = function(codex_update)
  codex_update = codex_update or {}
  return Table.extend(
    interactive(function(self, other)
      self.interacted_by = other
      railing.api.discover_wiki(codex_update)
      State:remove(self)
    end, {highlight = true}),
    {
      sprite = sprite.image("assets/sprites/note.png"),
      codename = "note",
      layer = "on_solids",
      view = "scene",
      name = "записка",
    }
  )
end

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
            self._popup = railing.api.message.positional("Закрыто.", {source = self})
          end
          return
        end

        self:open()
      end, {highlight = args.highlight}),
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
            level.change_layer(self, "on_solids")
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

for _, postfix in ipairs {"", "c"} do
for i = 1, 3 do
  local codename = "megadoor%s%s" % {i, postfix}
  live[codename] = function()
    local result = Table.extend(
      animated("assets/sprites/animations/%s/closed" % {codename}),
      {
        layer = "solids",
        view = "scene",
        name = "огромная дверь",
        codename = codename,

        _is_open = false,
        _open = function(self)
          if self._is_open then return end
          self._is_open = true
          self.interact = nil

          self:animate("open"):next(function()
            self.animation.pack = animated.load_pack(
              "assets/sprites/animations/%s/open" % {codename}
            )
            level.change_layer(self, "on_solids")
          end)
        end,
      }
    )

    if i == 3 then
      Table.extend(
        result,
        interactive(function(self, other)
          self.interacted_by = other

          if self.locked then
            if not State:exists(self._popup[1]) then
              self._popup = railing.api.message.positional("Закрыто.", {source = self})
            end
            return
          end

          self:open()
        end),
        {
          locked = true,
          _popup = {},
          open = function(self)
            for d = 0, 2 do
              State.grids.solids[self.position + Vector.left * d]:_open()
            end
          end
        }
      )
    end

    return result
  end
end
end

live.breakable_door = function()
  return creature(animated.load_pack("assets/sprites/animations/breakable_door"), {
    name = "дверь",
    codename = "breakable_door",

    max_hp = 20,
    perks = {
      {
        modify_incoming_damage = function(self, entity, damage)
          if damage < 8 then
            return 0
          end
          return damage
        end,
      },
    },

    sounds = {
      hit = sound.multiple("assets/sounds/hits_soft_wood", .35),
    },

    on_death = function(self)
      State:add(on_solids.broken_door(), {position = self.position})
    end,
  })
end

return live
