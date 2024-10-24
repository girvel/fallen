local combat = require("tech.combat")
local humanoid = require("mech.humanoid")
local animation_packs = require("library.animation_packs")
local races = require("mech.races")


local player, module_mt, static = Module("state.player")

module_mt.__call = function(_)
  return humanoid({
    player_flag = true,
    name = "протагонист",
    level = 0,
    experience = -1,
    max_hp = 1,
    direction = "right",
    faction = "player",
    fov_radius = 15,
    race = races.human,

    immortal = true,
    on_death = function(self)
      self:rotate("left")
      self.animation.pack = animation_packs.skeleton
      self:animate()
    end,

    action_factories = {},
    actions = {},
    _last_actions = {},

    can_act = function(self)
      return not State.combat or self == State.combat:get_current()
    end,

    ai = {
      run = function(self, entity)
        local result = Fun.iter(entity.actions)
          :map(function(f) return entity:act(f) end)
          :filter(function(v) return v == combat.TURN_END_SIGNAL end)
          :nth(1)

        entity.actions = {}
        return result
      end,

      observe = function(self)
        local mutex_factories, other_factories = Fun.iter(self.action_factories)
          :span(function(f) return f.mutex_group end)

        self.actions = mutex_factories
          :group_by(function(f) return f.mutex_group, f end)
          :map(function(group, fs)
            local result = Fun.iter(fs)
              :filter(function(f) return self._last_actions[group] == f end)
              :nth(1) or fs[1]
            self._last_actions[group] = result
            return result
          end)
          :chain(other_factories)
          :map(function(f)
            Query(f):pre_action()
            return f.action
          end)
          :filter(Fun.op.truth)
          :totable()

        self.action_factories = {}

        if not self:can_act() then
          self.actions = {}
        end

        local k = love.keyboard.isDown("lshift", "rshift") and 1.5 or 1

        self.animation_rate = k
        for _, key in ipairs({"w", "a", "s", "d"}) do
          love.custom.set_key_rate(key, love.custom.get_rate() * k)
        end
      end,
    },
  })
end

return player
