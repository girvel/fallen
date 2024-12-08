local fx = require("tech.fx")
local hostility = require("mech.hostility")
local ai = require("tech.ai")
local api = ai.api


local combat_ai, module_mt, static = Module("library.ais.combat")

module_mt.__call = function()
  return {
    run = ai.async(function(self, entity, dt)
      if not api.in_combat(entity) or not hostility.are_hostile(entity, State.player) then
        return
      end

      api.travel(entity, State.player.position)
      api.try_attacking(entity, State.player)
    end),

    observe = function(self, entity, dt)
      if not hostility.are_hostile(entity, State.player)
        and State:check_aggression(State.player, entity)
      then
        hostility.make_hostile(entity.faction)
      end

      if not Table.contains(-Query(State.combat).list or {}, entity)
        and hostility.are_hostile(entity, State.player)
      then
        State:add(fx("assets/sprites/fx/aggression", "fx", entity.position))
        State:start_combat({entity, State.player})
      end
    end,
  }
end

return combat_ai
