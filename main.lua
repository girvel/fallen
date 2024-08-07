-- global imports --
Log = require("lib.log")
Fun = require("lib.fun")
Tiny = require("lib.tiny")
Inspect = require("lib.inspect")
Memoize = require("lib.memoize")
require("lib.strong")

Log.info("Starting basic LOVE setup")

Tablex = require("lib.tablex")
Query = require("lib.query")
Mathx = require("lib.mathx")
Common = require("lib.Common")

Dump = require("lib.dump")
Static = require("lib.static")
Enum = require("lib.enum")
Vector = require("lib.vector")
Grid = require("lib.grid")
D = require("lib.d")

require("lib.tiny_dump_patch")()

local love_errorhandler = love.errorhandler
love.errorhandler = function(msg)
  Log.fatal(debug.traceback("Error: " .. tostring(msg), 2):gsub("\n[^\n]+$", ""))
end

love.graphics.setDefaultFilter("nearest", "nearest")
love.keyboard.setKeyRepeat(true)


-- local imports --
local palette = require("library.palette")
local quests = require("library.quests")
local factions = require("library.factions")
local sound = require("tech.sound")

-- TODO move these to the level configuration
local state = require("state")
local cli = require("tech.cli")
local systems = require("systems")


love.load = function(args)
  local closure_args = Tablex.deep_copy(args)
  love.reload = function()
    State.world:clearEntities()
    State.world:clearSystems()
    State.world:refresh()
    return love.load(closure_args)
  end

  args = cli.parse(args)
  Log.info("Command line arguments:", args)
  Log.level = args.debug and "trace" or "debug"

  local seed = os.time()
  Log.info("Loading the game; seed", seed)
  math.randomseed(seed)

  if args.load_save then
    State = assert(loadstring(love.filesystem.read(args.load_save .. ".lua"))())
  else
    State = state(systems, args.debug)  -- TODO debug should not be stored in a save
    State:load_level("assets/levels/" .. args.level, palette)

    State.gui.wiki.quests = quests
    State.factions = factions()
  end
  State.audio.disable_ambient = args.disable_ambient
  State.gui.show_fps = args.show_fps

  for _, scene in ipairs(args.checkpoints) do
    State.rails.scenes[scene].enabled = true
  end

  for _, scene in ipairs(args.scenes) do
    State.rails.scenes[scene].enabled = true
    State.rails.scenes[scene].start_predicate = function() return true end
  end

  love.audio.stop()
  love.audio.setDistanceModel("exponent")
  if not args.disable_ambient then
    local engine = sound("assets/sounds/ship_engine.mp3", 1)
    engine.source:setLooping(true)
    State.audio:play({position = Vector({12, 64})}, engine, "large")
  end

  if not args.debug then
    love.errorhandler = love_errorhandler
  else
    jit.off()
  end

  if args.resolution then
    love.window.updateMode(args.resolution[1], args.resolution[2], {fullscreen = false})
  end

  if args.enable_profiler then
    State.profiler = require("lib.profile")
    State.profiler.setclock(love.timer.getTime)
  end

  if args.tests then
    love.is_running_tests = true
  end

  Log.info("Game is loaded")
end

local active_time = 0
local frames_total = 0

love.run = function()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	love.timer.step()

	local dt = 0

  Query(State.profiler).start()

	-- Main loop time.
	return function()
    if love.reload_flag then
      love.reload()
      love.reload_flag = nil
    end

    local current_time = love.timer.getTime()

		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		dt = love.timer.step()

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw(dt) end

			love.graphics.present()
		end

    active_time = active_time + love.timer.getTime() - current_time
    frames_total = frames_total + 1
		love.timer.sleep(0.001)

    if love.is_running_tests then
      require("tests.test_serialization")
      return 0
    end
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
    State.world:refresh()
    State.world:update(function(_, entity)
      return entity.base_callback == callback_name
    end, {...})  -- TODO REF maybe unpack the arguments?
  end
end

love.quit = function()
  Log.info("Exited smoothly")
  Log.info("Max potential FPS: %.2f" % (frames_total / active_time))
  if State.profiler then
    State.profiler.stop()
    Log.info("===== PROFILE =====\n\n" .. State.profiler.report(100))
  end
end

Log.info("Finished setup")
