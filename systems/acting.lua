local combat = require("tech.combat")
local fx = require("tech.fx")
local sound = require("tech.sound")
local hostility = require("mech.hostility")
local cue = require("tech.cue")


local your_move_sound = sound.multiple("assets/sounds/your_move1", 0.5)

local acting, _, static = Module("systems.acting")

acting.system = static(Tiny.processingSystem({
  codename = "acting",
  filter = Tiny.requireAll("ai"),
  base_callback = "update",

  onAdd = function(self, entity)
    return -Query(entity.ai).initialize(entity)
  end,

  preProcess = function()
    State._aggression_log = State._next_aggression_log
    State._next_aggression_log = {}
    if State.combat then
      local combatants = State.combat:iter_entities_only():totable()

      if Fun.iter(combatants):all(function(a)
        return Fun.iter(combatants):all(function(b) return not hostility.are_hostile(a, b) end)
      end) then
        Log.info(
          "Fight ends as only %s are left standing"
           % table.concat(Fun.iter(combatants)
            :map(Entity.name)
            :totable(), ", ")
        )
        Fun.iter(combatants):each(function(e)
          Table.extend(e.resources, -Query(e):get_resources("short") or {})
        end)
        State.combat = nil
      end
    end
  end,

  process = function(self, entity, dt)
    self:_refresh_blood(entity)

    local observe = entity.ai.observe
    if observe then
      Debug.pcall(observe, entity, dt)
    end
    if not entity.ai.run then return end

    if not State.combat then
      return self:_process_outside_combat(entity, dt)
    else
      return self:_process_inside_combat(entity, dt)
    end
  end,

  postProcess = function(self)
    if -Query(State.combat):get_current() == combat.WORLD_TURN then
      self:_pass_turn()
    end
  end,

  _refresh_blood = function(self, entity)
    if not entity.hp then return end
    cue.set(entity, "blood", entity.hp <= entity:get_max_hp() / 2)
  end,

  _process_outside_combat = function(self, entity, dt)
    if not entity.ai.in_cutscene then Debug.pcall(entity.ai.run, entity.ai, entity, dt) end
    if -Query(entity.animation).current.codename:starts_with("idle") then
      Table.extend(entity.resources, -Query(entity):get_resources("move"))
    else
      Table.extend(entity.resources, -Query(entity):get_resources("free"))
    end
  end,

  _process_inside_combat = function(self, entity, dt)
    local is_world_turn = State.combat:get_current() == combat.WORLD_TURN

    if is_world_turn then
      if Table.contains(State.combat.list, entity) then return end
    elseif State.combat:get_current() ~= entity then return end

    if is_world_turn then
      dt = 6
    end

    local was_timeout_reached = (
      not entity.player_flag
      and Common.period(10, self, State.combat:get_current())
    )

    if was_timeout_reached then
      Log.warn("%s's turn timed out" % Entity.name(State.combat:get_current()))
    end

    local ok, signal = Debug.pcall(entity.ai.run, entity.ai, entity, dt)
    if
      not ok
      or signal == combat.TURN_END_SIGNAL and not is_world_turn
      or was_timeout_reached
    then
      self:_pass_turn()
    end
  end,

  _pass_turn = function(self)
    local current = State.combat:get_current()
    Common.reset_period(self, current)
    Table.extend(current.resources, -Query(current):get_resources("move") or {})
    current.disengaged_flag = nil  -- TODO redo as condition
    current.advantage_flag = nil  -- TODO redo as condition
    State.combat:move_to_next()
    current = State.combat:get_current()
    Log.info("%s's turn" % Entity.name(current))

    if current == State.player then
      sound.play(your_move_sound)
      State:add(fx("assets/sprites/fx/turn_starts", "fx_under", current.position))
    end
  end,
}))

return acting
