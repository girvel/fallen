local interactive = require("tech.interactive")


local hint, module_mt, static = Module("state.gui.hint")

module_mt.__call = function(_)
  return {
    override = nil,

    get = function(self)
      if self.override then return self.override end

      if State.mode:get() == State.mode.creator and State.gui.creator:can_submit() then
        return "[Enter] чтобы закончить редактирование"
      end

      if
        State.player.ai.in_cutscene
        or not Table.contains({State.mode.free, State.mode.fight}, State.mode:get())
      then return "" end

      local interaction = interactive.get_for(State.player)
      if interaction then
        return "[E] для взаимодействия с " .. Entity.name(interaction)
      end

      return ""
    end,
  }
end

return hint
