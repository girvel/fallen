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

Enum = require("lib.enum")
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
local quests = require("library.quests")
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

  Log.info("Loading the game")
  math.randomseed(os.time())
  State = state(systems, args.debug)
  State.callback_set = Fun.iter(systems)
    :reduce(function(acc, system)
      acc[system.base_callback] = true
      return acc
    end, {})
  State:load_level("assets/levels/" .. args.level, palette)
  State.gui.wiki.quests = quests

  State.audio.disable_ambient = args.disable_ambient

  for _, scene in ipairs(args.checkpoints) do
    State.rails.scenes[scene].enabled = true
  end

  for _, scene in ipairs(args.scenes) do
    State.rails.scenes[scene].enabled = true
    State.rails.scenes[scene].start_predicate = function() return true end
  end

  love.audio.stop()
  love.audio.setDistanceModel("linear")
  if not args.disable_ambient then
    local engine = love.audio.newSource("assets/sounds/ship_engine.mp3", "static")
    engine:setVolume(1)
    engine:setLooping(true)
    State.audio:play({position = Vector({12, 64})}, engine, 10, 50)
  end

  if not args.debug then
    love.errorhandler = love_errorhandler
  end

  Log.info("Game is loaded")
end

love.run = function()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
    if love.reload_flag then
      love.reload()
      love.reload_flag = nil
    end

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
		if love.timer then dt = love.timer.step() end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw(dt) end

			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
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
    end, {...})
  end
end

love.quit = function()
  Log.info("Exited smoothly")
end

Log.info("Finished setup")
