local fighter = require("mech.classes.fighter")
local humanoid = require("mech.humanoid")
local animation_packs = require("library.animation_packs")
local weapons = require("library.weapons")


local module_mt = {}
local player = setmetatable({}, module_mt)

module_mt.__call = function(_, abilities)
  local result = humanoid({
    player_flag = true,
    name = "протагонист",
    class = fighter(),
    race = {
      codename = "player_character",
      movement_speed = 6,
      skin_color = Common.hex_color("8ed3dc"),
    },
    level = 2,
    direction = "right",
    faction = "dreamers",

    immortal = true,
    on_death = function(self)
      self:rotate("left")
      self.animation.pack = animation_packs.skeleton
      self:animate()
    end,

    ai = {run = function(self)
      if not self.next_action then return end
      local result = self:act(self.next_action)
      self.next_action = nil
      return result
    end},

    abilities = abilities,
  })

  result.resources.second_wind = 1
  result.resources.action_surge = 1

  result.inventory.main_hand = weapons.dagger()

  return result
end

return player
