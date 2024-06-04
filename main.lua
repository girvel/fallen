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
  state.camera:setWindow(0, 0, 9999, 9999)

  state:load_level("assets/levels/demo.txt", palette)
end

for _, callback_name in ipairs({"draw", "keypressed", "update"}) do
  love[callback_name] = function(...)
    state.world:update(function(_, entity)
      return entity.base_callback == callback_name
    end, state, {...})
  end
end
