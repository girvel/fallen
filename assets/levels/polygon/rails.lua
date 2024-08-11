local railing = require("tech.railing")
local sprite = require("tech.sprite")
local api = railing.api
local game_save = require("state.game_save")


local lorem = "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."

return function()
  return Tablex.extend(railing.mixin(), {
    scenes = {
      {
        name = "Testing",
        enabled = true,
        start_predicate = function(self, rails, dt) return true end,

        run = function(self, rails, dt)
          self.enabled = false
          api.discover_wiki({fought_dreamers = true})
          api.narration("Hello, <hate>world</hate>!")
          State.gui.popup:show(State.player.position, "above", "Oh hi Mark", 10)
          State.player.portrait = sprite.image("assets/sprites/portraits/half_orc.png")
          api.line(State.player, "I'm gay")
        end,
      },

      {
        name = "Mannequin is hit",
        enabled = true,
        start_predicate = function(self, rails, dt)
          return rails.entities.mannequin.hp < rails.last_mannequin_hp
        end,

        run = function(self, rails, dt)
          rails.last_mannequin_hp = rails.entities.mannequin.hp
          api.ability_check_message("str", 12, lorem, "You suck more.")
          -- api.notification("Game saved")
          -- game_save.write()
        end,
      },
    },

    initialize = function(self)
      self.entities = {
        mannequin = State.grids.solids[Vector({9, 7})],
      }

      self.last_mannequin_hp = self.entities.mannequin.hp
    end,
  })
end
