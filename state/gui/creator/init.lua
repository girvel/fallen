local experience = require("mech.experience")
local fighter = require("mech.classes.fighter")
local forms = require("state.gui.creator.forms")
local texting = require("tech.texting")


local init, module_mt, static = Module("state.gui.creator.init")

module_mt.__call = function(_, gui)
  return {
    is_active = function(self)
      return not not self._text_entities
    end,

    refresh = function(self)
      self._mixin.level = experience.get_level(State.player.experience)

      if self._text_entities then
        State:remove_multiple(self._text_entities)
      end

      local text = Html.pre {
        "   ", Html.h1 {"Редактор персонажа"},
        -- TODO!
        -- forms.abilities(),
        -- forms.skills(),
        -- forms.race(),
        forms.class(self._mixin),
      }

      self._text_entities = State:add_multiple(texting.generate(
        text, self._styles,
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
    _styles = Table.merge({}, gui.styles, {
      default = {
        font_size = 18,
      },
      h1 = {
        font_size = 30,
      },
      h2 = {
        font_size = 24,
      },
    }),

    _mixin = {
      class = fighter.class,
      level = nil,
    },
  }
end

return init
