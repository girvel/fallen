--- @class scene: {[string]: any}
--- @field name string
--- @field enabled boolean
--- @field characters? {[string]: table}
--- @field start_predicate fun(scene, table, number, table): boolean?
--- @field run fun(scene, table, table): any

--- @overload fun(...: table): rails
local railing, module_mt, static = Module("tech.railing")

railing.api = require("tech.railing.api")

--- @class rails
--- @field scenes table<string|number, scene>
--- @field entities table<string, entity>
--- @field positions table<string, vector>
--- @field _active_coroutines thread[]
local railing_methods = {}

railing_methods.update = function(self, dt)
  for _, scene in pairs(self.scenes) do
    local characters = Fun.pairs(scene.characters or {})
      :map(function(name, params)
        if name == "player" then return name, State.player end
        return name, self.entities[name] or false
      end)
      :tomap()

    if scene.enabled
      and (scene.multiple_instances_flag or not self:is_running(scene))
      and (scene.in_combat_flag or not characters.player or not State.combat)
      and Fun.pairs(characters):all(function(_, c) return State:exists(c) end)
      and scene:start_predicate(self, dt, characters)
    then
      table.insert(self._active_coroutines, {
        coroutine = coroutine.create(function()
          if not scene.boring_flag then
            Log.info("Scene `" .. scene.name .. "` starts")
          end

          for _, character in pairs(characters) do
            Query(character).ai.in_cutscene = true
          end

          -- run the body
          -- if failed
          --   if debug mode
          --     update stack
          --     launch debug shell
          --   else
          --     log the stack trace
          --     reset blackout
          -- else
          --   proceed
          -- reset in_cutscene
          -- log ending

          Debug.call(scene.run, scene, self, characters)

          for _, character in pairs(characters) do
            Query(character).ai.in_cutscene = nil
          end

          if not scene.boring_flag then
            Log.info("Scene `" .. scene.name .. "` ends")
          end
        end),
        base_scene = scene,
      })
    end
  end

  self._active_coroutines = Fun.iter(self._active_coroutines)
    :filter(function(c)
      Common.resume_logged(c.coroutine, dt)
      return coroutine.status(c.coroutine) ~= "dead"
    end)
    :totable()
end

railing_methods.run_task = function(self, task)
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

railing_methods.remove_scene = static .. function(self, k)
  self:stop_scene(k)
  self.scenes[k] = nil
  Log.info("Removed scene " .. k)
end

railing_methods.stop_scene = function(self, k)
  self._active_coroutines = Fun.iter(self._active_coroutines)
    :filter(function(c) return c.base_scene ~= self.scenes[k] end)
    :totable()
  Log.info("Stopped scene " .. k)
end

railing_methods.is_running = function(self, scene)
  if type(scene) == "string" then scene = self.scenes[scene] end
  return Fun.iter(self._active_coroutines)
    :any(function(c) return c.base_scene == scene end)
end

module_mt.__call = function(_, ...)
  local result = setmetatable(Table.extend(
    {_active_coroutines = {}},
    railing_methods,
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

  love.filesystem.write("dump.lua", Dump(result))
  return result
end

return railing
