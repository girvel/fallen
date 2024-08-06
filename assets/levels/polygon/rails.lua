local railing = require("tech.railing")
local sprite = require("tech.sprite")
local api = railing.api


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
          State.player.hp = 1
          State.player:rotate("left")
          api.narration("Hello, <hate>world</hate>!")
          State.player.portrait = sprite.image("assets/sprites/portraits/half_orc.png")
          api.line(State.player, "I'm gay")
        end,
      },
    },

    initialize = function(self)
    end,
  })
end
