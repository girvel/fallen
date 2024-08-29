local railing, module_mt, static = Module("tech.railing")

railing.api = require("tech.railing.api")

module_mt.__call = function(_, ...)
  return Table.extend(setmetatable({
    active_coroutines = {},

    update = function(self, dt)
      self.active_coroutines = Fun.iter(self.active_coroutines)
        :chain(Fun.iter(pairs(self.scenes))
          :filter(function(s)
            return s.enabled
              and (not self:is_running(s) or s.multiple_instances_flag)
              and s:start_predicate(self, dt)
          end)
          :map(function(s)
            Log.info("Scene `" .. s.name .. "` starts")
            return {
              coroutine = coroutine.create(function()
                --s:run(self, dt)
                Debug.call(s.run, s, self, dt)
                Log.info("Scene `" .. s.name .. "` ends")
              end),
              base_scene = s,
            }
          end)
        )
        :filter(function(c)
          Common.resume_logged(c.coroutine, dt)
          return coroutine.status(c.coroutine) ~= "dead"
        end)
        :totable()
    end,

    run_task = function(self, task)
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
    end,

    remove_scene = function(self, k)
      self:stop_scene(k)
      self.scenes[k] = nil
      Log.info("Removed scene " .. k)
    end,

    stop_scene = function(self, k)
      self.active_coroutines = Fun.iter(self.active_coroutines)
        :filter(function(c) return c.base_scene ~= self.scenes[k] end)
        :totable()
      Log.info("Stopped scene " .. k)
    end,

    is_running = function(self, scene)
      if type(scene) == "string" then scene = self.scenes[scene] end
      return Fun.iter(self.active_coroutines)
        :any(function(c) return c.base_scene == scene end)
    end,
  }, {
    __serialize = function(self)
      if #self.active_coroutines == 0 then return end
      self = Table.shallow_copy(self)
      self.active_coroutines = {}
      return function()
        return self
      end
    end
  }), ...)
end

return railing
