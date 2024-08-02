local texting = require("state.gui.texting")
local special = require("tech.special")
local random = require("utils.random")


--local skip_sounds = Common.volumed_sounds("assets/sounds/click_modern", 0.5)
local skip_sounds = Common.volumed_sounds("assets/sounds/click_retro", 0.05)

return function()
  return {
    _entities = nil,
    selected_option_i = nil,
    options = nil,

    show = function(self, line, source)
      local portrait = -Query(source).portrait
      self._entities = State:add_multiple(Tablex.concat(
        texting.generate_html_page(
          "<pre>%s</pre>" % line, {default = {font = State.gui.font}},
          math.min(love.graphics.getWidth() - 40, State.gui.TEXT_MAX_SIZE[1]),
          "dialogue_text", {}
        ),
        {special.dialogue_background()},
        portrait and {special.portrait(portrait)} or {}
      ))
    end,

    skip = function(self)
      if not self._entities then return end
      State.audio:play_static(random.choice(skip_sounds):clone())
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
      assert(#options > 0)
      self.selected_option_i = 1
      self.options = options
      self:options_refresh()
    end,

    options_select = function(self)
      self:skip()
      self.options = nil
    end,
  }
end
