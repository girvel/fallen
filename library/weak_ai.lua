local ai = require("tech.ai")
local api = ai.api
-- TODO REF tech.texting?
local texting = require("tech.texting")


local weak_ai, module_mt, static = Module("library.weak_ai")

module_mt.__call = function()
  return {
    _was_attacked_by = {},
    _line_entities = {},
    run = ai.async(function(self, event)
      if #self.ai._was_attacked_by > 0 then
        self.ai._was_attacked_by = {}
        if State:exists(self.ai._line_entities[1]) then
          State:remove_multiple(self.ai._line_entities)
        end
        self.ai._line_entities = State:add_multiple(texting.popup(
          self.position, "above", Random.choice({"Ааай", "Оой"})
        ))
      end
    end, true),
    observe = function(self, event)
      api.aggregate_aggression(self.ai._was_attacked_by, self)
    end
  }
end

return weak_ai
