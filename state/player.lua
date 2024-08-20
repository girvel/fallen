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
    ai = {
      run = function(self)
        if self.in_cutscene then return end

        local actions = Fun.iter(self.action_factories)
          :reduce(
            function(acc, f)
              if f.mutex_group then
                if acc.encountered_groups[f.mutex_group] then return acc end
                acc.encountered_groups[f.mutex_group] = true
              end
              Query(f).pre_action()
              table.insert(acc.actions, f.action)
              return acc
            end,
            {actions = {}, encountered_groups = {}}
          ).actions

        local result = Fun.iter(actions)
          :map(function(a) return self:act(a) end)
          :any(Fun.op.truth)

        self.action_factories = {}
        return result
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
