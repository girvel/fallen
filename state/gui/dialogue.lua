local sounds = require("tech.sounds")
local texting = require("tech.texting")
local gui = require("tech.gui")
local constants = require("tech.constants")


--- @overload fun(): state_gui_dialogue
local dialogue, module_mt, static = Module("state.gui.dialogue")

--- @class state_gui_dialogue
--- @field selected_option_i integer
--- @field options string[]
--- @field option_indices_map {[integer]: integer}
--- @field _entities entity[]
local base = {
  --- @param self state_gui_dialogue
  --- @param line string
  --- @param portrait? sprite_image
  --- @return nil
  show = function(self, line, portrait)
    self._entities = State:add_multiple(Table.concat(
      texting.generate(
        texting.parse("<pre>%s</pre>" % line), State.gui.wiki.styles,  -- TODO move styles?
        math.min(
          love.graphics.getWidth() - 40 - State.gui.views.dialogue_text.offset[1],
          constants.TEXT_MAX_SIZE[1]
        ),
        "dialogue_text", {}
      ),
      {gui.dialogue_background()},
      portrait and {gui.portrait(portrait)} or {}
    ))
  end,

  --- @param self state_gui_dialogue
  --- @return nil
  skip = function(self)
    if not self._entities then return end
    Random.choice(sounds.click):play()
    State:remove_multiple(self._entities)
    self._entities = nil
  end,

  --- @param self state_gui_dialogue
  --- @return nil
  options_refresh = function(self)
    self:skip()
    self:show(Fun.iter(self.options)
      :enumerate()
      :map(function(i, o)
        return '<option on_click="%s" on_hover="%s">%s %s. %s</option>\n' % {
          "State.gui.dialogue.selected_option_i = %s; State.gui.dialogue:options_select()" % i,
          [[
            if State.gui.dialogue.selected_option_i ~= %s then
              State.gui.dialogue.selected_option_i = %s
              State.gui.dialogue:options_refresh()
            end
          ]] % {i, i},
          self.selected_option_i == i and "&gt;" or " ", i, o
        }
      end)
      :reduce(Fun.op.concat, "")
    )
  end,

  --- @param self state_gui_dialogue
  --- @param options string[]
  --- @return nil
  options_present = function(self, options)
    assert(next(options), "Trying to present empty options list")

    self.selected_option_i = 1
    self.options = {}
    self.option_indices_map = {}

    local sorted_pairs = Fun.pairs(options):map(Table.pack):totable()
    table.sort(sorted_pairs, function(a, b) return a[1] < b[1] end)
    for i, pair in ipairs(sorted_pairs) do
      local index, option = unpack(pair)
      self.options[i] = option
      self.option_indices_map[i] = index
    end

    self:options_refresh()
  end,

  --- @param self state_gui_dialogue
  --- @return nil
  options_select = function(self)
    self:skip()
    self.options = nil
  end,
}

module_mt.__call = function(_)
  return Table.extend({
    _entities = nil,
    selected_option_i = nil,
    options = nil,
    option_indices_map = nil,
  }, base)
end

return dialogue
