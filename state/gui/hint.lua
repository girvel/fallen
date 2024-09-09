local interactive = require("tech.interactive")


local hint, module_mt, static = Module("state.gui.hint")

module_mt.__call = function(_)
  return {
    override = nil,

    -- TODO REF hint should be separated
    get = function(self)
      if self.override then return self.override end
      if not Table.contains({"free", "fight"}, State.mode:get().codename) then return "" end
      local interaction = interactive.get_for(State.player)
      if interaction then
        return "[E] для взаимодействия с " .. Entity.name(interaction)
      end
      return ""
    end,
  }
end

return hint
