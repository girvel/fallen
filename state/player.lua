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
    debug_flag = true,

    immortal = true,
    on_death = function(self)
      self:rotate("left")
      self.animation.pack = animation_packs.skeleton
      self:animate()
    end,

    action_factories = {},
    _last_actions = {},
    ai = {
      run = function(self)
        local mutex_factories, other_factories = Fun.iter(self.action_factories)
          :span(function(f) return f.mutex_group end)

        mutex_factories
          :group_by(function(f) return f.mutex_group, f end)
          :map(function(group, fs)
            local result = Fun.iter(fs)
              :filter(function(f) return self._last_actions[group] == f.action end)
              :nth(1) or fs[1]
            self._last_actions[group] = result.action
            return result
          end)
          :chain(other_factories)
          :each(function(f)
            Query(f).pre_action()
            if not self.in_cutscene and f.action then self:act(f.action) end
          end)

        self.action_factories = {}
      end,

      observe = function(self)
        if State.combat and self ~= State.combat:get_current() then
          self.action_factories = {}
        end
        self.animation_rate = love.keyboard.isDown("lshift", "rshift") and 2 or 1
      end,
    },
  })
end

return player
