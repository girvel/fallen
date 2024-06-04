love.graphics.setDefaultFilter("nearest", "nearest")

Tiny = require("lib.tiny")
Vector = require("lib.vector")
Log = require("lib.log")
Grid = require("lib.grid")
Inspect = require("lib.inspect")
Fun = require("lib.fun")
D = require("lib.d")
require("lib.strong")
Gamera = require("lib.gamera")

local palette = require("library.palette")
local stateful = require("tech.stateful")


local state
love.load = function()
  Log.info("Game started")

  math.randomseed(os.time())

  state = stateful()
	state.camera:setScale(2)
	state.camera:setPosition(0, 0)

  state:load_level("assets/levels/demo.txt", palette)

  local bats = Fun.iter(pairs(state.grids.solids._inner_array))
    :filter(function(e) return e and e.name == "bat" end)
    :totable()

  state.move_order = {
    list = {
      state.player,
      unpack(bats),
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
