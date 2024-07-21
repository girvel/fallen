local railing = {api = {}}

railing.api.narration = function(text)
  State.gui.dialogue:show(text)
  while State:get_mode() ~= "free" do coroutine.yield() end
end

railing.api.line = function(entity, text)
  -- TODO get color back
  railing.api.narration(Common.get_name(entity) .. ": " .. text)
end

railing.api.wait_seconds = function(s)
  local t = love.timer.getTime()
  while love.timer.getTime() - t < s do coroutine.yield() end
end

railing.api.center_camera = function()
  Fun.iter({"scene", "scene_fx"}):each(function(view)
    State.gui.views[view].offset = (
      - State.gui.views.scene:apply_multiplier(State.player.position)
      + Vector({love.graphics.getDimensions()}) / 2
    )
  end)
end

railing.api.options = function(options)
  State.gui.dialogue:options_present(options)
  while State:get_mode() ~= "free" do coroutine.yield() end
  return State.gui.dialogue.selected_option_i
end

railing.api.notification = function(rails, text, time_seconds)
  time_seconds = time_seconds or 10

  rails:run_task(function()
    State.gui.sidebar.notification:set_text(text)
    railing.api.wait_seconds(time_seconds)
    if State.gui.sidebar.notification.sprite.text == text then
      State.gui.sidebar.notification:set_text("")
    end
  end)
end

railing.api.discover_wiki = function(rails, page, level)
  State.gui.wiki.discovered_pages[page] = level
  railing.api.notification(rails, "Информация в Кодексе обновлена")  -- TODO mention page name
end

railing.mixin = function()
  return {
    update = function(self, event)
      local dt = event[1]
      self.active_coroutines = Fun.iter(self.active_coroutines)
        :chain(Fun.iter(pairs(self.scenes))
          :filter(function(s) return s.enabled and s:start_predicate(self, dt) end)
          :map(function(s)
            Log.info("Scene `" .. s.name .. "` starts")
            return coroutine.create(function()
              s:run(self, dt)
              Log.info("Scene `" .. s.name .. "` ends")
            end)
          end)
        )
        :filter(function(c)
          Common.resume_logged(c, dt)
          return coroutine.status(c) ~= "dead"
        end)
        :totable()
    end,

    run_task = function(self, task)
      table.insert(self.scenes, {
        name = "Some task",
        enabled = true,
        start_predicate = function() return true end,
        run = function(self_scene, rails, dt)
          self_scene.enabled = false
          task(self_scene, rails, dt)
          Tablex.remove(self.scenes, self_scene)
        end,
      })
    end,
  }
end

return railing
