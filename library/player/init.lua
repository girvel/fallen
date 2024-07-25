local classes = require("mech.classes")
local humanoid = require("mech.humanoid")
local animation_packs = require("library.animation_packs")
local weapons = require("library.weapons")


local module_mt = {}
local module = setmetatable({}, module_mt)

module_mt.__call = function()
  local result = humanoid({
    player_flag = true,
    name = "протагонист",
    class = classes.charming_leader,
    race = {
      codename = "player_character",
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

    hotkeys = require("library.player.hotkeys")(),
    ai = {run = function(self)
      local result = -Query(self.hotkeys[State:get_mode()])[self.last_pressed_key](self)
      self.last_pressed_key = nil
      return result
    end},

    abilities = {
      strength = 16,
      dexterity = 18,
      constitution = 14,
      intelligence = 8,
      wisdom = 10,
      charisma = 8,
    },
  })

  result.turn_resources.second_wind = 1
  result.turn_resources.action_surge = 1

  result.inventory.main_hand = weapons.dagger()

  return result
end

return module
