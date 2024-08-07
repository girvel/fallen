local fighter = require("mech.classes.fighter")
local humanoid = require("mech.humanoid")
local animation_packs = require("library.animation_packs")
local weapons = require("library.weapons")


local player, module_mt = Static.module("state.player")

module_mt.__call = function(_, abilities, race, build, feat)
  local result = humanoid({
    player_flag = true,
    name = "протагонист",
    class = fighter(),
    race = race,
    build = build,
    feat = feat,
    level = 2,
    direction = "right",
    faction = "player",

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
        return result
      end,

      observe = function(self)
        if State.combat and self ~= State.combat:get_current() then
          self.next_action = nil
        end
      end,
    },

    abilities = abilities,
  })

  result.resources.second_wind = 1
  result.resources.action_surge = 1

  result.inventory.main_hand = weapons.dagger()
  result.inventory.other_hand = weapons.gas_key()

  return result
end

return player
