local actions = require("core.actions")
local random = require("utils.random")
local common = require("utils.common")
local creature = require("core.creature")
local animated = require("tech.animated")
local interactive = require("tech.interactive")
local special = require("tech.special")


local module = {}

local bat_pack = animated.load_pack("assets/sprites/bat")

module.bat = function()
  return creature(bat_pack, {
    name = "bat",
    max_hp = 3,
    hungry = true,
    ai = function(self, state, event)
      if not state.move_order then return end

      local dt = unpack(event)
      if not common.period(self, .25, dt) then return end
      if not self._ai_coroutine then
        self._ai_coroutine = coroutine.create(self.async_ai)
      end

      local success, message = coroutine.resume(self._ai_coroutine, self, state)
      if not success then
        Log.error("Coroutine error: " .. message)
      end

      if coroutine.status(self._ai_coroutine) == "dead" then
        self._ai_coroutine = nil
        return true
      end
    end,
    async_ai = function(self, state)
      for _ in Fun.range(self.turn_resources.movement) do
        if self.hungry then
          local target = Fun.iter(Vector.directions)
            :map(function(v) return state.grids.solids:safe_get(self.position + v) end)
            :filter(function(e) return e and e.hp end)
            :nth(1)

          if target and actions.hand_attack(self, state, target) then
            self.hungry = false
          end
        end

        actions.move(random.choice(Vector.direction_names))(self, state)
        coroutine.yield()
      end
    end,
  })
end

local moose_dude_pack = animated.load_pack("assets/sprites/moose_dude")

module.moose_dude = function()
  return common.extend(
    creature(moose_dude_pack, {
      name = "moose dude",
      max_hp = 10,
    }),
    interactive(function(self, _, state)
      state:add(special.floating_line("//Видят//Ждут//", self.position))
      self.interact = nil
    end)
  )
end

local barrel_dude_pack = animated.load_pack("assets/sprites/barrel_dude")

module.barrel_dude = function()
  return creature(barrel_dude_pack, {
    name = "barrel dude",
    max_hp = 15,
  })
end

local exploding_dude_pack = animated.load_pack("assets/sprites/exploding_dude")

module.exploding_dude = function()
  return common.extend(
    animated(exploding_dude_pack),
    interactive(function(self, _, state)
      self.interact = nil
      self:animate("explode")
      self:when_animation_ends(function()
        state:remove(self)
      end)
    end),
    {
      name = "exploding dude",
    }
  )
end

return module
