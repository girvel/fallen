local sound = require("tech.sound")
local sounds = require("tech.sounds")
local texting = require("tech.texting")
local gui = require("tech.gui")


return Module("state.gui.dialogue", function()
  return {
    _entities = nil,
    selected_option_i = nil,
    options = nil,

    show = function(self, line, source)
      local portrait = -Query(source).portrait
      self._entities = State:add_multiple(Table.concat(
        texting.generate(
          texting.parse("<pre>%s</pre>" % line), State.gui.wiki.styles,  -- TODO move styles?
          math.min(love.graphics.getWidth() - 40, State.gui.TEXT_MAX_SIZE[1]),
          "dialogue_text", {}
        ),
        {gui.dialogue_background()},
        portrait and {gui.portrait(portrait)} or {}
      ))
    end,

    skip = function(self)
      if not self._entities then return end
      sound.play(sounds.click)
      State:remove_multiple(self._entities)
      self._entities = nil
    end,

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

    options_present = function(self, options)
      assert(#options > 0, "Trying to present empty options list")
      self.selected_option_i = 1
      self.options = options
      self:options_refresh()
    end,

    options_select = function(self)
      self:skip()
      self.options = nil
    end,
  }
end)
