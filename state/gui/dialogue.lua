local texting = require("state.gui.texting")
local special = require("tech.special")
local random = require("utils.random")


--local skip_sounds = Common.volumed_sounds("assets/sounds/click_modern", 0.5)
local skip_sounds = Common.volumed_sounds("assets/sounds/click_retro", 0.4)

return function()
  return {
    text_entities = nil,
    selected_option_i = nil,
    options = nil,

    show = function(self, line)
      self.text_entities = State:add_multiple(texting.generate_html_page(
        "<pre>%s</pre>" % line, {default = {font = State.gui.font}},
        math.min(love.graphics.getWidth() - 40, State.gui.TEXT_MAX_SIZE[1]),
        "dialogue_text", {}
      ))
      self.background = State:add(special.dialogue_background())
    end,

    skip = function(self)
      if not self.text_entities then return end
      random.choice(skip_sounds):clone():play()
      State:remove_multiple(self.text_entities)
      if self.background then State:remove(self.background) end
      self.text_entities = nil
      self.background = nil
    end,

    options_refresh = function(self)
      self:skip()
      self:show(Fun.iter(self.options)
        :enumerate()
        :map(function(i, o)
          return "%s %s. %s\n" % {
            self.selected_option_i == i and ">" or " ", i, o
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
