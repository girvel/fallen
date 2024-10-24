local races = require("mech.races")
local class = require("mech.class")
local abilities = require("mech.abilities")
local experience = require("mech.experience")
local fighter = require("mech.classes.fighter")
local forms = require("state.gui.creator.forms")
local texting = require("tech.texting")


--- @overload fun(gui: state_gui): creator
local init, module_mt, static = Module("state.gui.creator.init")

module_mt.__call = function(_, gui)
  --- @class creator
  --- @field scroll integer
  local result = {
    scroll = 0,  -- for some reason LSP does not see it so it is marked w/ @field
    size = Vector.zero,

    is_active = function(self)
      return not not self._text_entities
    end,

    refresh = function(self)
      if State.player.experience < 0 then return end

      self._mixin.level = experience.get_level(State.player.experience)
      self._movement_functions = {}
      self._active_choices = {}

      if self._text_entities then
        State:remove_multiple(self._text_entities)
      end

      local page = Html.pre {
        "   ", Html.h1 {
          self:is_readonly()
            and "Персонаж"
            or Html.span {color = Colors.green(), "Повышение уровня"},
        },
        forms.abilities(),
        forms.race(),
        forms.class(),
      }

      self._text_entities = State:add_multiple(texting.generate(
        page, self._styles,
        math.min(love.graphics.getWidth() - 40, State.gui.TEXT_MAX_SIZE[1]),
        "creator_text",
        {}
      ))
      self.size = texting.get_size(self._text_entities)
    end,

    move_cursor = function(self, direction)
      assert(Table.contains(Vector.directions, direction) or direction == Vector.zero)

      local creator = State.gui.creator

      if direction[2] ~= 0 then
        creator._current_selection_index
          = (creator._current_selection_index - 1 + direction[2])
            % #creator._movement_functions + 1
      elseif not self:is_readonly() then
        Query(creator._movement_functions[creator._current_selection_index])(direction[1])
        self:refresh()
        -- maybe one day I can figure out how to regenerate only a part of the page
      end
    end,

    is_readonly = function(self)
      return self._mixin.level == State.player.level
    end,

    close = function(self)
      if not self:is_readonly() then
        State.gui.notifier:push("Редактирование персонажа не закончено")
        return
      end
      State:remove_multiple(self._text_entities)
      self._text_entities = nil
    end,

    can_submit = function(self)
      return not self:is_readonly() and self._ability_points == 0
    end,

    submit = function(self)
      if self:is_readonly() then
        State.gui.notifier:push("Нельзя изменить персонажа")
        return
      end
      if not self:can_submit() then
        State.gui.notifier:push("Не все ресурсы распределены")
        return
      end

      self._mixin.perks = Fun.chain(
        experience.get_progression(self._mixin.class, self._mixin.level),
        experience.get_progression(self._mixin.race, self._mixin.level)
      )
        :map(function(it)
          if it.__type == class.choice then
            return self._choices[it]
          end
          return it
        end)
        :totable()

      Log.info("Finishing character creation with args:", self._mixin)
      State.player:level_up(self._mixin)
      self:close()
    end,

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
      race = races.human,
      level = nil,
      base_abilities = abilities(8, 8, 8, 8, 8, 8),
    },
    _ability_points = 27,

    _choices = {},
    _active_choices = {},

    _movement_functions = {},
    _current_selection_index = 1,
  }

  return result
end

return init
