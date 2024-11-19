local line_profiler = require("lib.line_profiler")
line_profiler.time_function = love.timer.getTime
love.graphics.setDefaultFilter("nearest", "nearest")
require("kernel").initialize()


-- local imports --
local quests = require("library.quests")
local factions = require("library.factions")
local sound = require("tech.sound")
local game_save = require("state.game_save")

-- TODO move these to the level configuration
local state = require("state")
local cli = require("tech.cli")
local systems = require("systems")


love.load = function(args)
  args = cli.parse(args)

  if not args.debug then
    love.errorhandler = love.custom.old_errorhandler
  else
    jit.off()
  end

  Log.info("Command line arguments:", args)
  Log.level = args.debug and "trace" or "debug"
  Debug.debug_mode = args.debug

  local seed = os.time()
  Log.info("Loading the game; seed", seed)
  math.randomseed(seed)

  if args.tests then
    -- TODO use love.custom function
    love.is_running_tests = true
    love.window.minimize()
  end

  if args.load_save then
    game_save.read("last.fallen_save")
  else
    State = state(systems)
    State.shader = nil
    State:load_level("assets/levels/" .. args.level)

    State.gui.wiki.quests = quests
    State.factions = factions()
  end

  State.ambient.disabled = args.disable_ambient
  State.gui.show_fps = args.show_fps
  State.fast_scenes = args.fast_scenes

  for _, scene in ipairs(args.enable_scenes) do
    Query(State.rails.scenes[scene]).enabled = true
  end

  for _, scene in ipairs(args.disable_scenes) do
    Query(State.rails.scenes[scene]).enabled = false
  end

  love.audio.stop()
  love.audio.setDistanceModel("exponent")
  if not args.disable_ambient then
    local engine = sound("assets/sounds/ship_engine.mp3", 1)
    engine.source:setLooping(true)
    sound.play({engine}, Vector({12, 64}), "medium")
  end

  if args.resolution then
    love.window.updateMode(args.resolution[1], args.resolution[2], {fullscreen = false})
  end

  if args.enable_profiler then
    State.profiler = setmetatable(
      require("lib.vendor.profile"),
      {__serialize = function() return function() end end}
    )
    State.profiler.setclock(love.timer.getTime)
  end

  Log.info("Game is loaded")
end

for callback_name, _ in pairs(
  Fun.iter(systems):reduce(function(acc, system)
    acc[system.base_callback] = true
    return acc
  end, {})
) do
  love[callback_name] = function(...)
    Debug.pcall(State._world.update, State._world, function(_, entity)
      return entity.base_callback == callback_name
    end, ...)
    State._world:refresh()
  end
end

love.quit = function()
  Log.info("Exited smoothly")
  Log.info("Max potential FPS: %.2f" % (love._custom.frames_total / love._custom.active_time))
  if State.profiler then
    State.profiler.stop()
    Log.info("===== PROFILE =====\n\n" .. State.profiler.report(100))
  end
  Log.info(line_profiler.report())
end

Log.info("Finished setup")
