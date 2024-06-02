love.graphics.setDefaultFilter("nearest", "nearest")

Tiny = require("lib.tiny")
Vector = require("lib.vector")
Log = require("lib.log")
Grid = require("lib.grid")
Inspect = require("lib.inspect")
Fun = require("lib.fun")
require("lib.strong")

local gamera = require("lib.gamera")
local common = require("utils.common")
local library = require("library")


local state
love.load = function()
  Log.info("Game started")

  math.randomseed(os.time())

  local GRID_LAYERS = {"tiles", "solids", "sfx"}

	state = {
    -- grids
		camera = gamera.new(0, 0, 9999, 9999),
    world = Tiny.world(unpack(require("systems"))),

    add = function(self, entity)
      self.world:add(entity)
      if entity.position then
        self.grids[entity.layer][entity.position] = entity
      end
      return entity
    end,

    remove = function(self, entity)
      self.world:remove(entity)

      if entity.position then
        self.grids[entity.layer][entity.position] = nil
      end

      self.move_order.list = Fun.iter(self.move_order.list)
        :filter(function(e) return e ~= entity end)
        :totable()
    end,

    load_level = function(self, path, scheme)
      local level_lines = love.filesystem.read(path):split("\n")
      self.grids = Fun.iter(GRID_LAYERS)
        :map(function(layer) return layer, Grid(Vector({#level_lines[1], #level_lines})) end)
        :tomap()

      for _, layer in ipairs(GRID_LAYERS) do
        for y, line in ipairs(level_lines) do
          for _, x, character in Fun.iter(line):enumerate() do
            local factory = (scheme[layer] or {})[character]
            if factory then
              local e = self:add(common.extend(factory(), {position = Vector({x, y}), layer = layer}))
              if character == "@" then
                self.player = e
              end
            end
          end
        end
      end
    end,
	}
	state.camera:setScale(2)
	state.camera:setPosition(0, 0)

  state:load_level("assets/levels/demo.txt", {
    tiles = {
      _ = library.planks,
      [","] = library.grass,
    },
    solids = {
      ["#"] = library.wall,
      ["%"] = library.crooked_wall,
      S = library.smooth_wall,
      ["@"] = library.player,
      b = library.bat,
    },
  })

  local bat = state.grids.solids[Vector({9, 5})]

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
    state.world:update(function(_, entity)
      return entity.base_callback == callback_name
    end, state, {...})
  end
end
