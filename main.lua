love.graphics.setDefaultFilter("nearest", "nearest")
love.keyboard.setKeyRepeat(true)

Fun = require("lib.fun")
Tiny = require("lib.tiny")
Log = require("lib.log")
Inspect = require("lib.inspect")
require("lib.strong")

Tablex = require("lib.tablex")
Mathx = require("lib.mathx")
Common = require("lib.common")

Vector = require("lib.vector")
Grid = require("lib.grid")
D = require("lib.d")

local palette = require("library.palette")
local stateful = require("tech.stateful")
local cli = require("tech.cli")

local systems = require("systems")


love.load = function(args)
  Log.info("Game started")  -- TODO better launch logging (for timestamps)
  math.randomseed(os.time())
  State = stateful(systems)
  State:load_level("assets/levels/demo", palette)

  args = cli.parse(args)
  Log.info("Command line arguments:", args)

  for _, scene in ipairs(args.checkpoints) do
    State.rails.scenes[scene].enabled = true
  end

  if not args.debug then
    local background_sound = love.audio.newSource("assets/sounds/740904__green__light__09.wav", "static")
    background_sound:setVolume(0.05)
    background_sound:setLooping(true)
    background_sound:play()
  end
end

for callback_name, _ in pairs(
  Fun.iter(systems)
    :reduce(function(acc, system)
      acc[system.base_callback] = true
      return acc
    end, {})
) do
  love[callback_name] = function(...)
    State.world:update(function(_, entity)
      return entity.base_callback == callback_name
    end, {...})
  end
end

