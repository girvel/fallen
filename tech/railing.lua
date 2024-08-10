local fx = require("tech.fx")
local hostility = require("mech.hostility")
local mech = require("mech")
local utf8 = require("utf8")
local translation = require("tech.translation")


local railing, _, static = Module("tech.railing")
railing.api = static {}

railing.api.narration = function(text, source)
  State.gui.dialogue:show(text, source)
  while State:get_mode() ~= "free" do coroutine.yield() end
end

railing.api.line = function(entity, text)
  railing.api.narration([[<span color="%s">%s</span><span>: %s</span>]] % {
    Common.color_to_hex(entity.sprite.color), Common.get_name(entity), text
  }, entity)
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

local convert = function(index, removed_indices)
  for _, removed_index in ipairs(removed_indices) do
    if index < removed_index then break end
    index = index + 1
  end
  return index
end

railing.api.options = function(options, remove_picked)
  State.gui.dialogue:options_present(options)
  while State:get_mode() ~= "free" do coroutine.yield() end
  local converted_i = State.gui.dialogue.selected_option_i
  if remove_picked then
    options.removed = options.removed or {}
    converted_i = convert(converted_i, options.removed)
    table.remove(options, State.gui.dialogue.selected_option_i)
    table.insert(options.removed, converted_i)
    table.sort(options.removed)
  end
  return converted_i
end

railing.api.notification = function(text, is_order)
  State.gui.sidebar:push_notification(text, is_order)
end

railing.api.discover_wiki = function(page_table)
  for k, v in pairs(page_table) do
    State.gui.wiki.codex[k] = v
  end
  railing.api.notification("Информация в Кодексе обновлена")  -- TODO mention page name
end

railing.api.make_hostile = function(faction, entities)
  Fun.iter(entities)
    :filter(function(e) return e.faction == faction end)
    :each(function(e)
      State:add(fx("assets/sprites/fx/aggression", "fx", e.position))
    end)
  hostility.make_hostile(faction)
end

railing.api.ability_check_message = function(ability, dc, content_success, content_failure)
  local success = (D(20) + mech.get_modifier(State.player.abilities[ability])):roll() >= dc
  local content = '<span color="%s">[%s]</span> %s' % {
    success and "60b37e" or "e64e4b",
    translation.ability[ability]:upper(),
    success and content_success or content_failure,
  }

  State.gui.popup:show(
    State.player.position, "above", content, utf8.len(content) / 10
  )
end

railing.mixin = function()
  return {
    active_coroutines = {},

    update = function(self, event)
      local dt = event[1]
      self.active_coroutines = Fun.iter(self.active_coroutines)
        :chain(Fun.iter(pairs(self.scenes))
          :filter(function(s) return s.enabled and s:start_predicate(self, dt) end)
          :map(function(s)
            Log.info("Scene `" .. s.name .. "` starts")
            return {
              coroutine = coroutine.create(function()
                s:run(self, dt)
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
          Tablex.remove(self.scenes, self_scene)
        end,
      }
      table.insert(self.scenes, result)
      return result
    end,

    cancel_scene = function(self, scene)
      self:stop_scene(scene)
      Tablex.remove(self.scenes, scene)
    end,

    stop_scene = function(self, scene)
      self.active_coroutines = Fun.iter(self.active_coroutines)
        :filter(function(c) return c.base_scene ~= scene end)
        :totable()
    end,
  }
end

return railing
