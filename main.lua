Log = require("lib.log")
Fun = require("lib.fun")
Tiny = require("lib.tiny")
Inspect = require("lib.inspect")
require("lib.strong")

Log.info("Starting basic LOVE setup")

Tablex = require("lib.tablex")
Mathx = require("lib.mathx")
Common = require("lib.common")

Vector = require("lib.vector")
Grid = require("lib.grid")
D = require("lib.d")

local love_errorhandler = love.errorhandler
love.errorhandler = function(msg)
  Log.fatal(debug.traceback("Error: " .. tostring(msg), 2):gsub("\n[^\n]+$", ""))
end

love.graphics.setDefaultFilter("nearest", "nearest")
love.keyboard.setKeyRepeat(true)

local palette = require("library.palette")
local stateful = require("tech.stateful")
local cli = require("tech.cli")

local systems = require("systems")


love.load = function(args)
  Log.info("Loading the game")
  math.randomseed(os.time())
  State = stateful(systems)
  State:load_level("assets/levels/polygon", palette)

  args = cli.parse(args)
  Log.info("Command line arguments:", args)

  for _, scene in ipairs(args.checkpoints) do
    State.rails.scenes[scene].enabled = true
  end

  if not args.debug then
    local background_sound = love.audio.newSource("assets/sounds/740904__green__light__09.wav", "static")
    background_sound:setVolume(0.15)
    background_sound:setLooping(true)
    background_sound:play()
    love.errorhandler = love_errorhandler
  end

  Log.info("Game is loaded")
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

