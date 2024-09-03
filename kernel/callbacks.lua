local game_save = require("state.game_save")


return function()
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
        require("tests.test_serialization")
        return 0
      end
    end
  end
end
