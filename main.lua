Tiny = require("lib.tiny")
Vector = require("lib.vector")
Log = require("lib.log")
Grid = require("lib.grid")
Inspect = require("lib.inspect")


local game_state = {
  grid = Grid(Vector({10, 10})),
}

local world
love.load = function()
  Log.info("Game started")

  world = Tiny.world(unpack(require("systems")))

  game_state.grid[Vector({2, 2})] = world:add({
    position = Vector({2, 2}),
    sprite = {
      character = "@",
    },
    player_flag = true,
    turn_resources = {
      movement = 6,
      movement_max = 6,
    },
  })

  game_state.grid[Vector({1, 1})] = world:add({
    position = Vector({1, 1}),
    sprite = {
      character = "#",
    },
  })

  game_state.grid[Vector({1, 2})] = world:add({
    position = Vector({1, 2}),
    sprite = {
      character = "#",
    },
  })

  game_state.grid[Vector({1, 3})] = world:add({
    position = Vector({1, 3}),
    sprite = {
      character = "#",
    },
  })
end

for _, callback_name in ipairs({"draw", "keypressed"}) do
  love[callback_name] = function(...)
    world:update(function(_, entity) return entity.base_callback == callback_name end, game_state, {...})
  end
end

