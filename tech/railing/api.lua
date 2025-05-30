local sound = require("tech.sound")
local gui = require("state.gui")
local quest = require("tech.quest")
local texting = require("tech.texting")
local fx = require("tech.fx")
local hostility = require("mech.hostility")
local abilities = require("mech.abilities")
local translation = require("tech.translation")


--- API for scripting (a.k.a. railing)
--- Partially asynchronous, intended to be called from inside the scene
local api, module_mt, static = Module("tech.railing.api")

--- Display narration at the bottom of the screen
--- @async
--- @param text string
--- @param params {check: [ability|skill, boolean]}?
--- @return nil
api.narration = function(text, params)
  params = params or {}
  if params.check then
    text = '<span color="%s">[%s — %s] </span>' % {
      params.check[2] and Colors.hex.green or Colors.hex.red,
      translation.skill[params.check[1]] or translation.abilities[params.check[1]],
      params.check[2] and "успех" or "провал"
    } .. text
  end
  State.gui.dialogue:show(text)
  while State.mode:get() ~= State.mode.free do coroutine.yield() end
end

--- @alias talker {position: vector, sprite_offset: vector?, sprite: {color: color}, portrait: sprite_image}

--- Display entity's line at the bottom of the screen
--- @async
--- @param entity talker
--- @param text string
--- @param params {check: [ability|skill, boolean]}?
--- @return nil
api.line = function(entity, text, params)
  params = params or {}
  if params.check then
    text = '<span color="%s">[%s - %s] </span>' % {
      params.check[2] and Colors.hex.green or Colors.hex.red,
      translation.skill[params.check[1]] or translation.abilities[params.check[1]],
      params.check[2] and "успех" or "провал"
    } .. text
  end
  text = '<span color="%s">%s</span>: %s' % {
    Colors.to_hex(entity.sprite.color), Entity.name(entity), text
  }
  State.gui.dialogue:show(text, entity.portrait)
  State:add(fx(
    "assets/sprites/fx/turn_starts", "fx_under",
    entity.position + (entity.sprite_offset or Vector.zero)
  ))
  while State.mode:get() ~= State.mode.free do coroutine.yield() end
end

--- Wait for s seconds
--- @async
--- @param s number
--- @return nil
api.wait_seconds = function(s)
  if State.fast_scenes then return end
  local t = love.timer.getTime()
  while love.timer.getTime() - t < s do coroutine.yield() end
end

--- Wait while f returns true
--- @async
--- @param f fun(): boolean?
--- @return nil
--- @deprecated
api.wait_while = function(f)
  while f() do
    coroutine.yield()
  end
end

--- Center camera on player
--- @return nil
api.center_camera = function()
  local value = gui.offsets.scene_steeply()
  Fun.iter({"scene", "scene_fx"}):each(function(view)
    State.gui.views[view].offset = value
  end)
  State.gui._prev_camera_position = value
end

--- Give player multiple options to pick
--- @async
--- @param options {[integer]: string}
--- @param remove_picked boolean? when true mutates the `options` table, setting the picked option to nil
--- @return integer # index of the picked option
api.options = function(options, remove_picked)
  State.gui.dialogue:options_present(options)
  while State.mode:get() ~= State.mode.free do coroutine.yield() end
  local index = State.gui.dialogue.option_indices_map[State.gui.dialogue.selected_option_i]
  if remove_picked then
    options[index] = nil
  end
  return index
end

--- Display notification
--- @param text string
--- @param is_order boolean? when true order FX are displayed, notification FX otherwise
--- @return nil
api.notification = function(text, is_order)
  State.gui.notifier:push(text, is_order)
end

local codex_update_sound = sound("assets/sounds/update_codex.mp3", .3)

--- Update wiki.codex, discovering new wiki pages; notifies player
--- @param page_table {[string]: any}
--- @return nil
api.discover_wiki = function(page_table)
  for k, v in pairs(page_table) do
    State.gui.wiki.codex[k] = v
  end
  api.notification("Кодекс обновлён")  -- TODO mention page name
  codex_update_sound:play()
end

--- Make faction hostile towards player
--- @deprecated
--- @param faction string
--- @param entities table[] rails.entities
--- @return nil
api.make_hostile = function(faction, entities)
  Fun.pairs(entities)
    :filter(function(_, e) return e.faction == faction end)
    :each(function(_, e)
      State:add(fx("assets/sprites/fx/aggression", "fx", e.position))
    end)
  hostility.make_hostile(faction)
end

--- @param ability ability|skill
--- @param dc integer check's difficulty class
--- @return boolean
api.ability_check = function(ability, dc)
  return abilities.check(State.player, ability, dc)
end

--- @param ability ability
--- @param dc integer saving throw's difficulty class
--- @return boolean # whether saving throw was successful
api.saving_throw = function(ability, dc)
  local success = abilities.saving_throw(State.player, ability, dc)

  api.message.temporal(Html.span {
    color = success and Colors.green or Colors.red,
    "[%s - %s]" % {translation.abilities[ability]:upper(), success and "успех" or "провал"},
  })

  return success
end

--- @param ability ability|skill
--- @param dc integer check's difficulty class
--- @param content_success string
--- @param content_failure string
--- @return boolean
api.ability_check_message = function(ability, dc, content_success, content_failure)
  local success = abilities.check(State.player, ability, dc)

  api.message.positional(Html.span {
    Html.span {
      color = success and Colors.green or Colors.red,
      "[%s - %s]" % {
        (translation.abilities[ability] or translation.skill[ability]):upper(),
        success and "успех" or "провал",
      },
    },
    " %s" % {success and content_success or content_failure},
  })

  return success
end

api.message = {}

local message = function(content, params)
  params = params or {}
  local offset = Vector({0.5, not params.source and -1 or 0})
  params.source = params.source or State.player
  offset = offset + (params.source.sprite_offset or Vector.zero)

  return texting.popup(
    (params.source.position + offset) * State.gui.views.scene:get_multiplier(),
    "above", "scene_popup", content, State.gui.styles, 300
  )
end

--- Display message until player moves + some time
--- @param content html_content
--- @param params {life_time: number?, source: {position: vector, sprite_offset: vector?}}?
--- @return table[]
api.message.positional = function(content, params)
  local entities = message(content, params)
  local life_time = -Query(params).life_time or 5

  Table.extend(entities[1], {
    _epicenter = State.player.position,
    _dependent_entities = Table.extend({}, entities),
    ai = {
      observe = function(self, entity)
        if (State.player.position - entity._epicenter):abs() <= 2 then return end

        for _, e in ipairs(entity._dependent_entities) do
          State:refresh(e, {life_time = life_time})
        end
        self.observe = nil
      end,
    },
  })

  return State:add_multiple(entities)
end

local SLOW_READING_SPEED = 10

--- Display message for reaction time + slow reading time
--- @param content html_content
--- @param params {life_time: number?, source: {position: vector, sprite_offset: vector?}}?
--- @return entity[]
api.message.temporal = function(content, params)
  local entities = message(content, params)
  local life_time = -Query(params).life_time
    or Fun.iter(entities)
      :map(function(e)
        if not -Query(e).sprite.text then return 0 end
        return (type(e.sprite.text) == "string" and e.sprite.text or e.sprite.text[2]):utf_len()
      end)
      :sum() / SLOW_READING_SPEED + 2

  for _, e in ipairs(entities) do
    State:add(e, {life_time = life_time})
  end

  return entities
end

--- Should only be called at the end of cutscenes, as it frees player's movement early
--- @return nil
api.autosave = function()
  Log.info("Autosave")
  State.player.ai.in_cutscene = false
  love.custom.plan_save("last.fallen_save")
  api.notification("Игра сохранена")
end

--- Save the beginning point of the game
--- @return nil
api.base_save = function()
  Log.info("Base save")
  State.player.ai.in_cutscene = false
  love.custom.plan_save("start.fallen_save")
end

--- Can not regress quests
--- @param changes table<string, integer> changes to quest progress in format quest: stage
--- @return nil
api.update_quest = function(changes)
  local states = State.gui.wiki.quest_states
  for k, v in pairs(changes) do
    if not Table.contains(quest.SPECIAL_STAGES, v) and (states[k] or 0) > v then
      goto continue
      -- error("Attempt to degrade quest %s from stage %s (%s) to stage %s (%s)" % {
      --   k, states[k], quest_stage(k, states[k]), v, quest_stage(k, v),
      -- }, 2)
    end
    Log.info("Quest %s: %s -> %s" % {k, states[k], v})
    states[k] = v
    ::continue::
  end
end

--- Get current stage of quest w/ given codename
--- @param codename string quest's identifier
--- @return integer
api.get_quest = function(codename)
  return State.gui.wiki.quest_states[codename] or 0
end

--- Rotate given entity towards player
--- @param entity table
--- @return nil
api.rotate_to_player = function(entity)
  entity:rotate(Vector.name_from_direction(
    (State.player.position - entity.position):normalized()
  ))
end

local FADE_DURATION = 0.5

--- Trigger fade out sequence & wait for it
--- @async
--- @return nil
api.fade_out = function()
  State.gui:trigger_blackout(FADE_DURATION)
  api.wait_seconds(FADE_DURATION)
end

--- Trigger fade in sequence & wait for it
--- @async
--- @return nil
api.fade_in = function()
  State.gui:trigger_blackout(-FADE_DURATION)
  api.wait_seconds(FADE_DURATION)
end

--- Ask player to input text
--- @async
--- @return string text lowercase text stripped of spaces
api.request_text = function()
  State.gui.text_input.active = true
  while State.gui.text_input.active do coroutine.yield() end
  local result = State.gui.text_input.text:strip():utf_lower()
  State.gui.text_input.text = ""
  return result
end

return api
