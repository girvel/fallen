local feature = require("mech.feature")
local texting = require("tech.texting")
local races = require("mech.races")
local forms = require("state.gui.character_creator.forms")
local class = require("mech.class")
local fighter = require("mech.classes.fighter")
local feats = require("mech.feats")
local mech = require("mech")


return Module("state.gui.character_creator", function()
  local result = {
    player_anchor = nil,
    text_entities = nil,
    styles = {
      default = {
        font_size = 18,
      },
      h1 = {
        font_size = 30,
      },
      h1_prefix = {
        font_size = 30,
      },
      h2 = {
        font_size = 24,
      },
      h2_prefix = {
        font_size = 24,
      },
    },

    parameters = {
      points = 27,
      abilities_raw = {
        str = 8,
        dex = 8,
        con = 8,
        int = 8,
        wis = 8,
        cha = 8,
      },
      abilities_final = nil,
      free_skills = 3,
      skills = {},
      current_index = 1,
      max_index = 1,
      movement_functions = {},
      race = "human",
      class = fighter(),
      bonuses = {},

      build_options = {},

      _get_indicator = function(self, i)
        return '<span on_update="self.sprite.text = State.gui.character_creator.parameters.current_index == %s and [[&gt;]] or [[ ]]"> </span>' % i
      end,
      scroll = 0,

      forms_last_index = {},
    },

    refresh = function(self)
      local params = self.parameters
      if self.text_entities then
        State:remove_multiple(self.text_entities)
      end

      params.movement_functions = {}
      params.max_index = 0
      local text = "   <h1>Редактор персонажа</h1>"

      if State.player.experience >= 0 then
        params.level = Fun.iter(mech.experience_for_level)
          :enumerate()
          :filter(function(level, exp) return exp <= State.player.experience end)
          :map(function(level, exp) return level end)
          :max() or 0

        text = text .. Fun.iter(self.forms_sequence)
          :map(function(f) return f(params) end)
          :reduce(Fun.op.concat, "")
      end

      self.text_entities = State:add_multiple(texting.generate(
        "<pre>%s</pre>" % text, Table.merge({}, State.gui.wiki.styles, self.styles),
        math.min(love.graphics.getWidth() - 40, State.gui.TEXT_MAX_SIZE[1]),
        "character_creator", {params = params}
      ))
    end,

    forms = forms,

    move_cursor = function(self, direction_name)
      assert(direction_name == "zero" or Table.contains(Vector.direction_names, direction_name))

      local params = self.parameters

      if direction_name == "down" then
        params.current_index = (params.current_index) % params.max_index + 1
      elseif direction_name == "up" then
        params.current_index = (params.current_index - 2) % params.max_index + 1
      elseif not self:can_close() then
        Query(params.movement_functions[params.current_index])(Vector[direction_name][1])
        self:refresh()
      end
      params.scroll = -40 * (params.current_index - 1)
    end,

    can_close = function(self)
      return State.player.experience <= mech.experience_for_level[State.player.level + 1]
    end,

    close = function(self)
      if not self:can_close() then
        State.gui.notifier:push("Редактирование персонажа не закончено")
        return
      end
      State:remove_multiple(self.text_entities)
      self.text_entities = nil
    end,

    can_submit = function(self)
      local params = self.parameters
      return not self:can_close() and (params.points <= 0 or params.free_skills <= 0)
    end,

    submit = function(self)
      local params = self.parameters

      if self:can_close() then
        State.gui.notifier:push("Нельзя изменить персонажа")
        return
      end
      if not self:can_submit() then
        State.gui.notifier:push("Не все ресурсы распределены")
        return
      end

      local table_slice = Fun.iter(params.class.progression_table)
        :take_n(params.level)
        :reduce(Table.concat, {})

      local perks = Fun.iter(table_slice)
        :map(function(f)
          if f.enum_variant == feature.perk then
            return f.modifier
          end

          if f.enum_variant == feature.choice then
            return f.options[params.build_options[f]]
          end
        end)
        :filter(Fun.op.truth)
        :chain(races[params.race].feat_flag
          and {feats.feature.options[params.build_options[feats.feature]]}
          or {}
        )
        :totable()

      local changes = {
        abilities = params.abilities_final,
        race = races[params.race],

        level = params.level,
        class = params.class,
        skills = params.skills,
        perks = perks,
      }

      Log.info("Finishing character creation with args:", changes)

      State.player:level_up(changes)
      self:close()
    end,
  }

  result.forms_sequence = {
    result.forms.class,
    result.forms.race,
    result.forms.abilities,
    result.forms.skills,
  }

  return result
end)
