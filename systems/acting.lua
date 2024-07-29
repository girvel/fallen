local combat = require("tech.combat")


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
      and Common.relative_period(20, event[1], self, State.combat:get_current())
    )

    if was_timeout_reached then
      Log.warn("%s's turn timed out" % Common.get_name(State.combat:get_current()))
    end

    if
      entity.ai.run(entity, event) == combat.TURN_END_SIGNAL and not is_world_turn
      or was_timeout_reached
    then
      Common.reset_period(self, State.combat:get_current())
      Tablex.extend(entity.resources, -Query(entity):get_resources("move") or {})
      State.combat:move_to_next()
      Log.info("%s's turn" % Common.get_name(State.combat:get_current()))
    end
  end,

  postProcess = function()
    if -Query(State.combat):get_current() == combat.WORLD_TURN
    then
      State.combat:move_to_next()
    end
  end,
})
