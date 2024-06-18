love.graphics.setDefaultFilter("nearest", "nearest")
love.keyboard.setKeyRepeat(true)

Tiny = require("lib.tiny")
Vector = require("lib.vector")
Log = require("lib.log")
Grid = require("lib.grid")
Inspect = require("lib.inspect")
Fun = require("lib.fun")
D = require("lib.d")
require("lib.strong")

local palette = require("library.palette")
local stateful = require("tech.stateful")


local state
love.load = function(args)
  Log.info("Game started")
  math.randomseed(os.time())
  state = stateful()
  state:load_level("assets/levels/demo", palette)

  for _, arg in ipairs(args) do
    state.rails.scenes[arg].enabled = true
  end
end

for _, callback_name in ipairs({"draw", "keypressed", "update"}) do
  love[callback_name] = function(...)
    state.world:update(function(_, entity)
      return entity.base_callback == callback_name
    end, state, {...})
  end
end

