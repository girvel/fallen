Tiny = require("lib.tiny")
Vector = require("lib.vector")
Log = require("lib.log")
Grid = require("lib.grid")
Inspect = require("lib.inspect")
Fun = require("lib.fun")
require("lib.strong")

local gamera = require("lib.gamera")
local common = require("utils.common")
local level = require("level")
local library = require("library")


local state
love.load = function()
  Log.info("Game started")

  math.randomseed(os.time())

	state = {
    grid = nil,
		camera = gamera.new(0, 0, 9999, 9999),
    world = Tiny.world(unpack(require("systems"))),

    add = function(self, entity)
      self.world:add(entity)
      if entity.position then
        self.grid[entity.position] = entity
      end
    end,

    remove = function(self, entity)
      self.world:remove(entity)

      if entity.position then
        self.grid[entity.position] = nil
      end

      self.move_order.list = Fun.iter(self.move_order.list)
        :filter(function(e) return e ~= entity end)
        :totable()
    end,

    load_level = function(self, path, scheme)
      local level_lines = love.filesystem.read(path):split("\n")
      self.grid = Grid(Vector({#level_lines[1], #level_lines}))

      for y, line in ipairs(level_lines) do
        for _, x, character in Fun.iter(line):enumerate() do
          local factory = scheme[character]
          if factory then
            self:add(common.extend(factory(), {position = Vector({x, y})}))
          end
        end
      end
    end,
	}
	state.camera:setScale(2)
	state.camera:setPosition(0, 0)
	love.graphics.setDefaultFilter("nearest", "nearest")

  state:load_level("assets/levels/demo.txt", {
    ["#"] = library.wall,
    S = library.smooth_wall,
    ["@"] = library.player,
    b = library.bat,
  })

  state.player = state.grid[Vector({4, 4})]
  local bat = state.grid[Vector({9, 5})]

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
