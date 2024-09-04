local quest = require("tech.quest")
local texting = require("tech.texting")
local fx = require("tech.fx")
local hostility = require("mech.hostility")
local abilities = require("mech.abilities")
local translation = require("tech.translation")


local api, module_mt, static = Module("tech.railing.api")

api.narration = function(text, params)
  params = params or {}
  if params.check then
    text = '<span color="%s">[%s - %s] </span>' % {
      params.check[2] and Colors.hex.green or Colors.hex.red,
      translation.skill[params.check[1]] or translation.abilities[params.check[1]],
      params.check[2] and "успех" or "провал"
    } .. text
  end
  State.gui.dialogue:show(text, params.source)
  while State.mode:get() ~= State.mode.free do coroutine.yield() end
end

api.line = function(entity, text)
  api.narration([[<span color="%s">%s</span><span>: %s</span>]] % {
    Colors.to_hex(entity.sprite.color), Common.get_name(entity), text
  }, {source = entity})
end

api.wait_seconds = function(s)
  if State.fast_scenes then return end
  local t = love.timer.getTime()
  while love.timer.getTime() - t < s do coroutine.yield() end
end

api.wait_while = function(f)
  while f() do
    coroutine.yield()
  end
end

api.center_camera = function()
  Fun.iter({"scene", "scene_fx"}):each(function(view)
    State.gui.views[view].offset = (
      - State.player.position * State.gui.views.scene:get_multiplier()
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

api.options = function(options, remove_picked)
  State.gui.dialogue:options_present(options)
  while State.mode:get() ~= State.mode.free do coroutine.yield() end
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

api.notification = function(text, is_order)
  State.gui.sidebar:push_notification(text, is_order)
end

api.discover_wiki = function(page_table)
  for k, v in pairs(page_table) do
    State.gui.wiki.codex[k] = v
  end
  api.notification("Кодекс обновлён")  -- TODO mention page name
end

api.make_hostile = function(faction, entities)
  Fun.pairs(entities)
    :filter(function(_, e) return e.faction == faction end)
    :each(function(_, e)
      State:add(fx("assets/sprites/fx/aggression", "fx", e.position))
    end)
  hostility.make_hostile(faction)
end

api.ability_check = function(ability, dc)
  return abilities.check(State.player, ability, dc)
end

-- TODO REF remove message
api.saving_throw = function(ability, dc)
  local success = abilities.saving_throw(State.player, ability, dc)

  api.message.temporal('<span color="%s">[%s - %s]</span>' % {
    success and Colors.hex.green or Colors.hex.red,
    (translation.abilities[ability]):upper(),
    success and "успех" or "провал",
  })

  return success
end

api.ability_check_message = function(ability, dc, content_success, content_failure)
  local success = abilities.check(State.player, ability, dc)

  api.message.positional('<span color="%s">[%s - %s]</span> %s' % {
    success and Colors.hex.green or Colors.hex.red,
    (translation.abilities[ability] or translation.skill[ability]):upper(),
    success and "успех" or "провал",
    success and content_success or content_failure,
  })

  return success
end

api.message = {}

local message = function(content, params)
  params = params or {}
  local offset = Vector({0.5, not params.source and -1 or 0})
  params.source = params.source or State.player

  return texting.popup(
    (params.source.position + offset) * State.gui.views.scene:get_multiplier(),
    "above", "scene_popup", content, State.gui.wiki.styles, 300
  )
end

api.message.positional = function(content, params)
  local entities = message(content, params)
  local life_time = -Query(params).life_time or 5

  Table.extend(entities[1], {
    _epicenter = State.player.position,
    _dependent_entities = Table.extend({}, entities),
    ai = {
      observe = function(self)
        if (State.player.position - self._epicenter):abs() <= 2 then return end

        for _, e in ipairs(self._dependent_entities) do
          State:refresh(e, {life_time = life_time})
        end
        self.ai.observe = nil
      end,
    },
  })

  return State:add_multiple(entities)
end

local SLOW_READING_SPEED = 10

api.message.temporal = function(content, params)
  local entities = message(content, params)
  local life_time = -Query(params).life_time or content:utf_len() / SLOW_READING_SPEED + 2

  for _, e in ipairs(entities) do
    State:add(e, {life_time = life_time})
  end

  return entities
end

api.autosave = function()
  Log.info("Autosave")
  love.save_flag = true
  api.notification("Игра сохранена")
end

local quest_stage = function(k, v)
  local tasks = State.gui.wiki.quests[k].tasks
  return tasks[v] or tostring(v)
end

api.update_quest = function(changes)
  local states = State.gui.wiki.quest_states
  for k, v in pairs(changes) do
    if not Table.contains(quest.SPECIAL_STAGES, v) and (states[k] or 0) > v then
      error("Attempt to degrade quest %s from stage %s (%s) to stage %s (%s)" % {
        k, states[k], quest_stage(k, states[k]), v, quest_stage(k, v),
      }, 2)
    end
    Log.info("Quest %s: %s -> %s" % {k, states[k], v})
    states[k] = v
  end
end

return api
