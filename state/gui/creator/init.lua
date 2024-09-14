local texting = require("tech.texting")


local init, module_mt, static = Module("state.gui.creator.init")

module_mt.__call = function(_)
  return {
    is_active = function(self)
      return not not self._text_entities
    end,

    refresh = function(self)
      if self._text_entities then
        State:remove_multiple(self._text_entities)
      end

      local text = Html(function()
        return pre {
          h1 {"Hello, world!"},
        }
      end)

      self._text_entities = State:add_multiple(texting.generate(
        text, State.gui.wiki.styles,  -- TODO! have our own nested
        math.min(love.graphics.getWidth() - 40, State.gui.TEXT_MAX_SIZE[1]),
        "character_creator",  -- TODO! rename to creator
        {}
      ))
    end,

    move_cursor = Fn(),  -- TODO! implement
    can_close = Fn(false),  -- TODO! implement
    close = nil,
    can_submit = Fn(false),  -- TODO! implement
    submit = nil,

    _text_entities = nil,
  }
end

return init
