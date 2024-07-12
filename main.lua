Log = require("lib.log")
Fun = require("lib.fun")
Tiny = require("lib.tiny")
Inspect = require("lib.inspect")
require("lib.strong")

Log.info("Starting basic LOVE setup")

Tablex = require("lib.tablex")
Query = require("lib.query")
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
  args = cli.parse(args)
  Log.info("Command line arguments:", args)

  Log.info("Loading the game")
  math.randomseed(os.time())
  State = stateful(systems, args.debug)
  State:load_level("assets/levels/" .. args.level, palette)

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

love.quit = function()
  Log.info("Exited smoothly")
end

Log.info("Finished setup")
