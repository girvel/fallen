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
    fov_radius = 20,
    race = races.human,

    immortal = true,
    on_death = function(self)
      self:rotate("left")
      self.animation.pack = animation_packs.skeleton
      self:animate()
    end,

    ai = {
      run = function(self)
        if not self.next_action then return end
        local result = self:act(self.next_action)
        self.next_action = nil
        if not self.in_cutscene then return result end
      end,

      observe = function(self)
        if State.combat and self ~= State.combat:get_current() then
          self.next_action = nil
        end
      end,
    },
  })
end

return player
