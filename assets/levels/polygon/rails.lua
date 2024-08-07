local railing = require("tech.railing")
local sprite = require("tech.sprite")
local api = railing.api


return function()
  return Tablex.extend(railing.mixin(), {
    scenes = {
      {
        name = "Testing",
        enabled = false,
        start_predicate = function(self, rails, dt) return true end,

        run = function(self, rails, dt)
          self.enabled = false
          api.discover_wiki({fought_dreamers = true})
          State.player.hp = 1
          State.player:rotate("left")
          api.narration("Hello, <hate>world</hate>!")
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
          api.notification("Game saved")
          love.filesystem.write("last_save.lua", Dump(State))
          Fun.iter(Dump.get_warnings()):each(Log.warn)
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
