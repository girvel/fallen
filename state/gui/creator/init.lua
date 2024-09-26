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
      self._movement_functions = {}

      if self._text_entities then
        State:remove_multiple(self._text_entities)
      end

      local page = Html.pre {
        "   ", Html.h1 {"Редактор персонажа"},
        -- TODO!
        forms.abilities(),
        -- forms.skills(),
        forms.race(),
        forms.class(),
      }

      self._text_entities = State:add_multiple(texting.generate(
        page, self._styles,
        math.min(love.graphics.getWidth() - 40, State.gui.TEXT_MAX_SIZE[1]),
        "character_creator",  -- TODO! rename to creator
        {}
      ))
    end,

    move_cursor = function(self, direction)
      assert(Table.contains(Vector.directions, direction) or direction == Vector.zero)

      local creator = State.gui.creator

      if direction[2] ~= 0 then
        creator._current_selection_index
          = (creator._current_selection_index - 1 + direction[2])
            % #creator._movement_functions + 1
      else-- TODO! if not readonly
        Query(creator._movement_functions[creator._current_selection_index])(direction[1])
        self:refresh()
        -- maybe one day I can figure out how to regenerate only a part of the page
      end

      -- TODO! implement scroll through anchor
      -- params.scroll = -40 * (params.current_index - 1)
    end,

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

    _choices = {},

    _movement_functions = {},
    _current_selection_index = 1,
  }
end

return init
