local railing = require("tech.railing")
local ai = require("tech.ai")
local api = ai.api
local texting = require("tech.texting")


local weak_ai, module_mt, static = Module("library.ais.weak")

module_mt.__call = function()
  return {
    _was_attacked_by = {},
    _line_entities = {},
    run = ai.async(function(self, entity, dt)
      if #self._was_attacked_by > 0 then
        self._was_attacked_by = {}
        if State:exists(self._line_entities[1]) then
          State:remove_multiple(self._line_entities)
        end
        self._line_entities = railing.api.message.temporal(
          Random.choice({"Ааай", "Оой"}), {source = entity}
        )
      end
    end, true),
    observe = function(self, entity, dt)
      api.aggregate_aggression(entity.ai._was_attacked_by, entity)
      if State:check_aggression(State.player, entity) then
        entity.interact = nil
      end
    end
  }
end

return weak_ai
