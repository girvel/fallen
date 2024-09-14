local mode, module_mt, static = Module("state.mode")

local fullscreen_reading = "sidebar_background actions action_keys action_frames sidebar "
  .. "sidebar_text notification notification_fx tooltip_background tooltip"

module_mt.__call = function(_, views)
  return Table.extend(
    Fun.pairs({
      free = "*",
      combat = "*",
      dialogue = "*",
      dialogue_options = "*",
      reading = fullscreen_reading .. " wiki",
      character_creator = fullscreen_reading .. " character_creator",
      text_input = "",
      death = "",
    })
      :map(function(k, v)
        return k, {
          displayed_views = Common.set(v == "*" and views or v / " "),
          codename = k,
        }
      end)
      :tomap(),
    {
      get = function(self)
        if State.gui.text_input.active then
          return self.text_input
        elseif State.gui.creator:is_active() then
          return self.character_creator
        elseif State.player.hp <= 0 then
          return self.death
        elseif State.gui.wiki.text_entities then
          return self.reading
        elseif State.gui.dialogue.options then
          return self.dialogue_options
        elseif State.gui.dialogue._entities then
          return self.dialogue
        elseif State.combat then
          return self.combat
        else
          return self.free
        end
      end,
    }
  )
end

return mode
