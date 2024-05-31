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


local state
love.load = function()
  Log.info("Game started")

  math.randomseed(os.time())

	state = {
		grid = Grid(Vector({10, 10})),
		camera = gamera.new(0, 0, 9999, 9999),
    world = Tiny.world(unpack(require("systems"))),

    remove = function(self, entity)
      self.world:remove(entity)
      self.grid[entity.position] = nil
      self.move_order.list = Fun.iter(self.move_order.list)
        :filter(function(e) return e ~= entity end)
        :totable()
    end,
	}
	state.camera:setScale(2)
	state.camera:setPosition(0, 0)
	love.graphics.setDefaultFilter("nearest", "nearest")

  for _, pair in ipairs({
    {library.wall, true, {{1, 1}, {1, 2}, {1, 3}, {2, 3}, {3, 3}}},
    {library.planks, false, {{2, 1}, {2, 2}, {3, 2}}},
  }) do
    local entity_factory, solid, positions = unpack(pair)
    for _, position in ipairs(positions) do
      local entity = state.world:add(common.extend(entity_factory(), {position = Vector(position)}))
      if solid then
        level.put(state.grid, entity)
      end
    end
  end

  state.player = state.world:add(common.extend(library.player(), {position = Vector({2, 2})}))
  level.put(state.grid, state.player)
  local bat = state.world:add(common.extend(library.bat(), {position = Vector({5, 5})}))
  level.put(state.grid, bat)

  state.move_order = {
    list = {
      state.player,
      bat,
    },
    current_i = 1,
  }
end

for _, callback_name in ipairs({"draw", "keypressed", "update"}) do
  love[callback_name] = function(...)
    state.world:update(function(_, entity) return entity.base_callback == callback_name end, state, {...})
  end
end
