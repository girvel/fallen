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
local cli = require("tech.cli")


local state
love.load = function(args)
  Log.info("Game started")
  math.randomseed(os.time())
  state = stateful()
  state:load_level("assets/levels/demo", palette)

  args = cli.parse(args)
  Log.info("Command line arguments:", args)

  for _, scene in ipairs(args.checkpoints) do
    state.rails.scenes[scene].enabled = true
  end

  if not args.debug then
    local background_sound = love.audio.newSource("assets/sounds/740904__green__light__09.wav", "static")
    background_sound:setVolume(0.05)
    background_sound:setLooping(true)
    background_sound:play()
  end
end

for _, callback_name in ipairs({"draw", "keypressed", "update"}) do
  love[callback_name] = function(...)
    state.world:update(function(_, entity)
      return entity.base_callback == callback_name
    end, state, {...})
  end
end

