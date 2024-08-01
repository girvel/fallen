local combat = require("tech.combat")
local fx = require("tech.fx")


local your_move_sound = Common.volumed_sounds("assets/sounds/your_move1", 0.5)[1]

return Tiny.processingSystem({
  codename = "acting",
  filter = Tiny.requireAll("ai"),
  base_callback = "update",

  preProcess = function()
    State.agression_log = State._next_agression_log
    State._next_agression_log = {}
    if State.combat then
      local combatants = State.combat:iter_entities_only():totable()

      if Fun.iter(combatants):all(function(e) return e.faction == combatants[1].faction end) then
        Log.info(
          "Fight ends as only %s are left standing"
           % table.concat(Fun.iter(combatants)
            :map(Common.get_name)
            :totable(), ", ")
        )
        Fun.iter(combatants):each(function(e)
          Tablex.extend(e.resources, -Query(e):get_resources("short") or {})
        end)
        State.combat = nil
      end
    end
  end,

  process = function(self, entity, event)
    Query(entity.ai).observe(entity, event)
    if not State.combat then
      entity.ai.run(entity, event)
      Tablex.extend(entity.resources, -Query(entity):get_resources("move") or {})
      return
    end

    local is_world_turn = State.combat:get_current() == combat.WORLD_TURN

    if is_world_turn then
      if Tablex.contains(State.combat.list, entity) then return end
    elseif State.combat:get_current() ~= entity then return end

    if is_world_turn then
      event = {6}  -- 1 round is 6 seconds
    end

    local was_timeout_reached = (
      not entity.player_flag
      and Common.period(20, self, State.combat:get_current())
    )

    if was_timeout_reached then
      Log.warn("%s's turn timed out" % Common.get_name(State.combat:get_current()))
    end

    if
      entity.ai.run(entity, event) == combat.TURN_END_SIGNAL and not is_world_turn
      or was_timeout_reached
    then
      self:_pass_turn()
    end
  end,

  postProcess = function(self)
    if -Query(State.combat):get_current() == combat.WORLD_TURN then
      self:_pass_turn()
    end
  end,

  _pass_turn = function(self)
    local current = State.combat:get_current()
    Common.reset_period(self, current)
    Tablex.extend(current.resources, -Query(current):get_resources("move") or {})
    State.combat:move_to_next()
    current = State.combat:get_current()
    Log.info("%s's turn" % Common.get_name(current))

    if current == State.player then
      State.audio:play_static(your_move_sound)
      State:add(fx("assets/sprites/fx/turn_starts", "fx_behind", current.position))
    end
  end,
})
