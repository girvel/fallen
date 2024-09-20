local game_save = require("state.game_save")


return function()
  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

  -- We don't want the first frame's dt to include time taken by love.load.
  love.timer.step()

  local dt = 0

  Query(State.profiler).start()

  -- Main loop time.
  return function()
    if love._custom.load then
      game_save.read(love._custom.load)
      love._custom.load = nil
    end

    if love.is_running_tests then
      Log.info("\n\n========== TESTS ==========\n")
      require("tech.texting._tests.test_texting_process")
      return 0
    end

    local current_time = love.timer.getTime()
    local key_data = love._custom.key_repetition

    -- Process events.
    if love.event then
      love.event.pump()
      for name, a,b,c,d,e,f in love.event.poll() do
        if name == "quit" then
          if not love.quit or not love.quit() then
            return a or 0
          end
        elseif name == "keypressed" then
          key_data.delays[b] = key_data.delay
          love.custom_keypressed(b)
        elseif name == "keyreleased" then
          key_data.delays[b] = nil
        elseif name == "mousepressed" then
          love.custom_keypressed(c)
        end
        love.handlers[name](a,b,c,d,e,f)
      end
    end

    -- Update dt, as we'll be passing it to update
    dt = love.timer.step()

    for k, v in pairs(key_data.delays) do
      key_data.delays[k] = math.max(0, v - dt)
      if key_data.delays[k] == 0 then
        local rate = key_data.specific_rates[k] or key_data.rate
        while Common.period(1 / rate, key_data.id, k) do
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

    love._custom.active_time = love._custom.active_time + love.timer.getTime() - current_time
    love._custom.frames_total = love._custom.frames_total + 1
    love.timer.sleep(0.001)

    -- should go last to capture at least 1 tick
    if love._custom.save then
      game_save.write(love._custom.save)
      love._custom.save = nil
    end
  end
end
