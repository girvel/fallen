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

  local wall_image = love.graphics.newImage("assets/sprites/wall.png")
  local wall_at = function(x, y)
    local v = Vector({x, y})
    game_state.grid[v] = world:add({
      position = v,
      sprite = {
        image = wall_image,
      },
    })
  end

  wall_at(1, 1)
  wall_at(1, 2)
  wall_at(1, 3)
  wall_at(2, 3)
  wall_at(3, 3)
end

for _, callback_name in ipairs({"draw", "keypressed"}) do
  love[callback_name] = function(...)
    world:update(function(_, entity) return entity.base_callback == callback_name end, game_state, {...})
  end
end

