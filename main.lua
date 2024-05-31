Tiny = require("lib.tiny")
Vector = require("lib.vector")
Log = require("lib.log")
Grid = require("lib.grid")
Inspect = require("lib.inspect")
Fun = require("lib.fun")

local gamera = require("lib.gamera")
local common = require("utils.common")
local level = require("level")
local library = require("library")


local world, game_state
love.load = function()
  Log.info("Game started")

  math.randomseed(os.time())

	game_state = {
		grid = Grid(Vector({10, 10})),
		camera = gamera.new(0, 0, 9999, 9999),
	}
	game_state.camera:setScale(2)
	game_state.camera:setPosition(0, 0)
	love.graphics.setDefaultFilter("nearest", "nearest")

  world = Tiny.world(unpack(require("systems")))

  for _, pair in ipairs({
    {library.wall, true, {{1, 1}, {1, 2}, {1, 3}, {2, 3}, {3, 3}}},
    {library.planks, false, {{2, 1}, {2, 2}, {3, 2}}},
  }) do
    local entity_factory, solid, positions = unpack(pair)
    for _, position in ipairs(positions) do
      local entity = world:add(common.extend(entity_factory(), {position = Vector(position)}))
      if solid then
        level.put(game_state.grid, entity)
      end
    end
  end

  game_state.player = world:add(common.extend(library.player(), {position = Vector({2, 2})}))
  level.put(game_state.grid, game_state.player)
  local bat = world:add(common.extend(library.bat(), {position = Vector({5, 5})}))
  level.put(game_state.grid, bat)

  game_state.move_order = {
    list = {
      game_state.player,
      bat,
    },
    current_i = 1,
  }
end

for _, callback_name in ipairs({"draw", "keypressed", "update"}) do
  love[callback_name] = function(...)
    world:update(function(_, entity) return entity.base_callback == callback_name end, game_state, {...})
  end
end
