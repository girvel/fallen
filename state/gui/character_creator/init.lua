local texting = require("state.gui.texting")
local player = require("state.player")
local races = require("mech.races")
local forms = require("state.gui.character_creator.forms")
local class = require("mech.class")
local fighter = require("mech.classes.fighter")
local feats = require("mech.feats")
local mech = require("mech")


return Module("state.gui.character_creator", function()
  return {
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
      points = 0,
      abilities_raw = {
        str = 15,
        dex = 15,
        con = 15,
        int = 8,
        wis = 8,
        cha = 8,
      },
      abilities_final = nil,
      free_skills = 4,
      skills = {},
      current_index = 1,
      max_index = 1,
      movement_functions = {},
      race = "human",
      class = fighter(),
      bonuses = {},

      build_options = {},

      _get_indicator = function(self, i)
        return i == self.current_index and ">" or " "
      end,
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
        text = text
          .. self.forms.class(params)
          .. self.forms.race(params)
          .. self.forms.abilities(params)
          .. self.forms.skills(params)
      end

      self.text_entities = State:add_multiple(texting.generate(
        "<pre>%s</pre>" % text, Tablex.merge({}, State.gui.wiki.styles, self.styles),
        math.min(love.graphics.getWidth() - 40, State.gui.TEXT_MAX_SIZE[1]),
        "character_creator"
      ))

      if State.player.experience <= mech.experience_for_level[State.player.level] then
        params.current_index = -1
      end
    end,

    forms = forms,

    move_cursor = function(self, direction_name)
      assert(Tablex.contains(Vector.direction_names, direction_name))

      local params = self.parameters
      if direction_name == "down" then
        params.current_index = (params.current_index) % params.max_index + 1
      elseif direction_name == "up" then
        params.current_index = (params.current_index - 2) % params.max_index + 1
      else
        Query(params.movement_functions[params.current_index])(Vector[direction_name][1])
      end
      self:refresh()
    end,

    close = function(self)
      if State.player.experience > mech.experience_for_level[State.player.level] then
        return
      end
      State:remove_multiple(self.text_entities)
      self.text_entities = nil
    end,

    submit = function(self)
      local params = self.parameters
      if params.current_index < 0 then return end
      if params.points > 0 or params.free_skills > 0 then return end  -- TODO notification
      local active_choices = class.get_choices(fighter.progression_table, 2)

      local changes = {
        abilities = params.abilities_final,
        race = races[params.race],
        build = Fun.iter(params.build_options)
          :filter(function(o) return Tablex.contains(active_choices, o) end)
          :tomap(),
        feat = races[params.race].feat_flag
          and feats.perk.options[params.build_options[feats.perk]]
          or nil,
        level = params.level,
        class = params.class,
        skills = params.skills,
      }

      Log.info("Finishing character creation with args:", changes)

      State.player:level_up(changes)
      State:remove_multiple(self.text_entities)
      self.text_entities = nil
    end,
  }
end)
