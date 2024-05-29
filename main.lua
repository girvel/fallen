Tiny = require("lib.tiny")
Vector = require("lib.vector")
Log = require("lib.log")


local world
love.load = function()
  Log.info("Game started")

  world = Tiny.world(unpack(require("systems")))

  world:add({
    position = Vector({20, 16}),
    sprite = {
      character = "@",
    },
    player_flag = true,
    turn_resources = {
      movement = 6,
      movement_max = 6,
    },
  })

  world:add({
    position = Vector({19, 16}),
    sprite = {
      character = "#",
    },
  })

  world:add({
    position = Vector({19, 15}),
    sprite = {
      character = "#",
    },
  })

  world:add({
    position = Vector({19, 17}),
    sprite = {
      character = "#",
    },
  })
end

local game_state = {}

for _, callback_name in ipairs({"draw", "keypressed"}) do
  love[callback_name] = function(...)
    world:update(function(_, entity) return entity.base_callback == callback_name end, game_state, {...})
  end
end

