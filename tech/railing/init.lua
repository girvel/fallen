local railing, module_mt, static = Module("tech.railing")

railing.api = require("tech.railing.api")

railing._methods = static {a = static .. {}}
railing._methods.b = static {}

railing._methods.update = static .. function(self, dt)
  Log.trace("started updating rails")
  self._active_coroutines = Fun.iter(self._active_coroutines)
    :chain(Fun.iter(pairs(self.scenes))
      :filter(function(s)
        return s.enabled
          and (not self:is_running(s) or s.multiple_instances_flag)
          and s:start_predicate(self, dt)
      end)
      :map(function(s)
        return {
          coroutine = coroutine.create(function()
            Log.info("Scene `" .. s.name .. "` starts")
            Debug.call(s.run, s, self, dt)
            Log.info("Scene `" .. s.name .. "` ends")
          end),
          base_scene = s,
        }
      end)
    )
    :filter(function(c)
      Log.trace("Scene", Common.get_name(c.base_scene))
      Common.resume_logged(c.coroutine, dt)
      return coroutine.status(c.coroutine) ~= "dead"
    end)
    :totable()
  Log.trace("finished updating rails")
end

railing._methods.run_task = static .. function(self, task)
  local result = {
    name = "Some task",
    enabled = true,
    start_predicate = function() return true end,
    run = function(self_scene, rails, dt)
      self_scene.enabled = false
      task(self_scene, rails, dt)
      Table.remove(self.scenes, self_scene)
    end,
  }
  table.insert(self.scenes, result)
  return result
end

railing._methods.remove_scene = static .. function(self, k)
  self:stop_scene(k)
  self.scenes[k] = nil
  Log.info("Removed scene " .. k)
end

railing._methods.stop_scene = static .. function(self, k)
  self._active_coroutines = Fun.iter(self._active_coroutines)
    :filter(function(c) return c.base_scene ~= self.scenes[k] end)
    :totable()
  Log.info("Stopped scene " .. k)
end

railing._methods.is_running = static .. function(self, scene)
  if type(scene) == "string" then scene = self.scenes[scene] end
  return Fun.iter(self._active_coroutines)
    :any(function(c) return c.base_scene == scene end)
end

module_mt.__call = function(_, ...)
  return setmetatable(Table.extend(
    {_active_coroutines = {}},
    railing._methods,
    ...
  ), {
    __serialize = function(self)
      if #self._active_coroutines == 0 then return end
      self = Table.shallow_copy(self)
      self._active_coroutines = {}
      return function()
        return self
      end
    end,
  })
end

return railing
