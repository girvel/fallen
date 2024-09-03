local love_errorhandler = love.errorhandler
love.errorhandler = function(msg)
  if Debug.debug_mode then
    return Debug.handle_error(msg)
  end
  Log.fatal(debug.traceback("Error: " .. tostring(msg), 2):gsub("\n[^\n]+$", ""))
end

love.graphics.setDefaultFilter("nearest", "nearest")

require("kernel.globals")()


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
  local closure_args = Table.deep_copy(args)
  love.reload = function()
    State.world:clearEntities()
    State.world:clearSystems()
    State.world:refresh()
    return love.load(closure_args)
  end

  args = cli.parse(args)

  Log.info("Command line arguments:", args)
  Log.level = args.debug and "trace" or "debug"
  Debug.debug_mode = args.debug

  local seed = os.time()
  Log.info("Loading the game; seed", seed)
  math.randomseed(seed)

  if args.load_save then
    game_save.read()
  else
    State = state(systems)  -- TODO debug should not be stored in a save
    State:set_shader()
    State:load_level("assets/levels/" .. args.level)

    State.gui.wiki.quests = quests
    State.factions = factions()
  end

  State.audio.disable_ambient = args.disable_ambient
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
    State.audio:play({position = Vector({12, 64})}, engine, "large")
  end

  if not args.debug then
    love.errorhandler = love_errorhandler
  else
    jit.off()
    Table.extend(State.gui.character_creator.parameters, {
      skills = {
        sleight_of_hand = true,
        arcana = true,
        nature = true,
      },
      abilities_raw = {
        str = 15,
        dex = 15,
        con = 15,
        int = 8,
        wis = 8,
        cha = 8,
      },
      points = 0,
      free_skills = 0,
    })
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

love._custom = {
  active_time = 0,
  frames_total = 0,

  key_repetition_delays = {},
  key_repetition_id = {},
  key_repetition_delay = .3,
  key_repetition_rate = 5,
}

love.run = function()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	love.timer.step()

	local dt = 0

  Query(State.profiler).start()

	-- Main loop time.
	return function()
    -- TODO REF State.flags & state_management preupdate system
    if love.reload_flag then
      love.reload()
      love.reload_flag = nil
    end

    if love.load_flag then
      game_save.read()
      love.load_flag = nil
    end

    if love.save_flag then
      game_save.write()
      love.save_flag = nil
    end

    local current_time = love.timer.getTime()
    local custom = love._custom

		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
        elseif name == "keypressed" then
          custom.key_repetition_delays[b] = custom.key_repetition_delay
          love.custom_keypressed(b)
        elseif name == "keyreleased" then
          custom.key_repetition_delays[b] = nil
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		dt = love.timer.step()

    for k, v in pairs(custom.key_repetition_delays) do
      custom.key_repetition_delays[k] = math.max(0, v - dt)
      if custom.key_repetition_delays[k] == 0 then
        while Common.period(1 / custom.key_repetition_rate, custom.key_repetition_id, k) do
          love.custom_keypressed(k)
        end
      end
    end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw(dt) end

			love.graphics.present()
		end

    custom.active_time = custom.active_time + love.timer.getTime() - current_time
    custom.frames_total = custom.frames_total + 1
		love.timer.sleep(0.001)

    if love.is_running_tests then
      require("integration.test_serialization")
      return 0
    end
	end
end

for callback_name, _ in pairs(
  Fun.iter(systems):reduce(function(acc, system)
    acc[system.base_callback] = true
    return acc
  end, {})
) do
  love[callback_name] = function(...)
    State.world:refresh()
    Debug.pcall(State.world.update, State.world, function(_, entity)
      return entity.base_callback == callback_name
    end, ...)  -- TODO REF maybe unpack the arguments?
  end
end

love.quit = function()
  Log.info("Exited smoothly")
  Log.info("Max potential FPS: %.2f" % (love._custom.frames_total / love._custom.active_time))
  if State.profiler then
    State.profiler.stop()
    Log.info("===== PROFILE =====\n\n" .. State.profiler.report(100))
  end
end

Log.info("Finished setup")
