local classes = require("core.classes")
local humanoid = require("core.humanoid")
local hotkeys = require("library.player.hotkeys")
local animation_packs = require("library.animation_packs")


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

    immortal = true,
    on_death = function(self)
      self:rotate("left")
      self.animation.pack = animation_packs.skeleton
      self:animate()
    end,

    ai = function(self)
      local mode
      if State.gui.text_entities then
        mode = "reading"
      elseif State.gui.line_entities then
        mode = "dialogue"
      elseif self.dialogue_options then
        mode = "dialogue_options"
      elseif State.move_order then
        mode = "fight"
      elseif self.hp <= 0 then
        mode = "death"
      else
        mode = "free"
      end

      Query(hotkeys[mode])[self.last_pressed_key](self)
      self.last_pressed_key = nil
    end,
    abilities = {
      strength = 16,
      dexterity = 18,
      constitution = 14,
      intelligence = 8,
      wisdom = 10,
      charisma = 8,
    },
  })
  result.hp = 1  -- TODO RM

  result.turn_resources.second_wind = 1
  result.turn_resources.action_surge = 1

  return result
end

return module
