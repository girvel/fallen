local actions = require("core.actions")
local random = require("utils.random")
local creature = require("core.creature")
local humanoid = require("core.humanoid")
local animated = require("tech.animated")
local interactive = require("tech.interactive")
local turn_order = require("tech.turn_order")
local classes = require("core.classes")
local weapons = require("library.weapons")
local core = require("core")
local races = require("core.races")


local module = {}

for i, race in ipairs({races.half_elf, races.halfling, races.half_orc, races.dwarf}) do
  module[i] = function(direction, inventory)
    return humanoid({
      name = "инженер",
      race = race,
      max_hp = 1,  -- TODO class dude
      direction = direction,
      inventory = inventory,

      ai = function() end,
    })
  end
end

local bat_pack = animated.load_pack("assets/sprites/bat")

module.bat = function()
  return creature(bat_pack, {
    name = "летучая мышь",
    max_hp = 3,
    faction = "monster",
    ai = function(self, event)
      if not State.move_order then return end

      local dt = unpack(event)
      if not Common.period(self, .25, dt) then return end
      if not self._ai_coroutine then
        self._ai_coroutine = coroutine.create(self.async_ai)
      end

      local success, message = coroutine.resume(self._ai_coroutine, self)
      if not success then
        Log.error("Coroutine error: " .. message)
      end

      if coroutine.status(self._ai_coroutine) == "dead" then
        self._ai_coroutine = nil
        return true
      end
    end,
    async_ai = function(self)
      for _ in Fun.range(self.turn_resources.movement) do
        if self.hungry then
          local target = Fun.iter(Vector.directions)
            :map(function(v) return State.grids.solids:safe_get(self.position + v) end)
            :filter(function(e) return e and e.hp end)
            :nth(1)

          if target then actions.hand_attack(self, target) end
        end

        actions.move[random.choice(Vector.direction_names)](self)
        coroutine.yield()
      end
    end,
  })
end

local exploding_dude_pack = animated.load_pack("assets/sprites/exploding_dude")

module.exploding_dude = function()
  return Tablex.extend(
    animated(exploding_dude_pack),
    interactive(function(self, other)
      self.interact = nil
      self:animate("explode")
      self:when_animation_ends(function()
        State:remove(self)

        local bats = {}
        for _ = 1, 3 do
          local v
          for _ = 1, 1000 do
            v = self.position + Vector({
              math.random(11) - 6,
              math.random(11) - 6,
            })
            if State.grids.solids:safe_get(v) == nil then break end
          end

          local bat = State:add(Tablex.extend(module.bat(), {position = v}))
          bat:animate("appear")
          table.insert(bats, bat)
        end

        bats[#bats]:when_animation_ends(function()
          State.move_order = turn_order(Tablex.concat(bats, {other}))
        end)
      end)
    end),
    {
      name = "таинственный силуэт",
    }
  )
end

return module
