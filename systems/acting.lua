local turn_order = require("tech.turn_order")


return Tiny.processingSystem({
  codename = "acting",
  filter = Tiny.requireAll("ai"),
  base_callback = "update",

  preProcess = function()
    State.agression_log = State._next_agression_log
    State._next_agression_log = {}
    if #State.agression_log > 0 then Log.trace("AGRESSION!") end
    if State.move_order then
      local combatants = Fun.iter(State.move_order.list)
        :filter(function(e) return e ~= turn_order.WORLD_TURN end)
        :totable()

      if Fun.iter(combatants):all(function(e) return e.faction == combatants[1].faction end) then
        Log.info(
          "Fight ends as only %s are left standing"
           % table.concat(Fun.iter(combatants)
            :map(Common.get_name)
            :totable(), ", ")
        )
        State.move_order = nil
      end
    end
  end,

  process = function(self, entity, event)
    Query(entity.ai).observe(entity, event)
    if not State.move_order then
      entity.ai.run(entity, event)
      if entity.get_turn_resources then Tablex.extend(entity.turn_resources, entity:get_turn_resources()) end
      return
    end

    local is_world_turn = State.move_order:get_current() == turn_order.WORLD_TURN

    if is_world_turn then
      if State.move_order:contains(entity) then return end
    elseif State.move_order:get_current() ~= entity then return end

    if is_world_turn then
      event = {6}  -- 1 round is 6 seconds
    end

    local was_timeout_reached = (
      not entity.player_flag
      and Common.period(self, State.move_order:get_current(), 20, event[1])
    )

    if was_timeout_reached then
      Log.warn("%s's turn timed out" % Common.get_name(State.move_order:get_current()))
    end

    if
      entity.ai.run(entity, event) == turn_order.TURN_END_SIGNAL and not is_world_turn
      or was_timeout_reached
    then
      Common.reset_period(self, State.move_order:get_current())
      if entity.get_turn_resources then
        Tablex.extend(entity.turn_resources, entity:get_turn_resources())
      end
      State.move_order:move_to_next()
      Log.info("%s's turn" % Common.get_name(State.move_order:get_current()))
    end
  end,

  postProcess = function()
    if -Query(State.move_order):get_current() == turn_order.WORLD_TURN
    then
      State.move_order:move_to_next()
    end
  end,
})
