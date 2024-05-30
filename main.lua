Tiny = require("lib.tiny")
Vector = require("lib.vector")
Log = require("lib.log")
Grid = require("lib.grid")
Inspect = require("lib.inspect")

local gamera = require("lib.gamera")


local world, game_state
love.load = function()
  Log.info("Game started")

	game_state = {
		grid = Grid(Vector({10, 10})),
		camera = gamera.new(0, 0, 9999, 9999),
	}
	game_state.camera:setScale(2)
	game_state.camera:setPosition(0, 0)
	love.graphics.setDefaultFilter("nearest", "nearest")

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

  local wall_image_data = love.image.newImageData("assets/sprites/wall.png")
	wall_image_data:mapPixel(function(_, _, r, g, b, a)
		if r == 1 and g == 1 and b == 1 and a == 1 then
			return 0.25, 0.169, 0.33, 1
		else
			return 0, 0, 0, 0
		end
	end)
	local wall_image = love.graphics.newImage(wall_image_data)

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

love.errorhandler = function(msg)
  Log.fatal(msg)
end
