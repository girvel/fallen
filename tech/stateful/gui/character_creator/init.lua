local texting = require("tech.stateful.gui.texting")
local player = require("library.player")  -- TODO move to tech
local races = require("mech.races")
local forms = require("tech.stateful.gui.character_creator.forms")
local class = require("mech.class")
local fighter = require("mech.classes.fighter")
local feats = require("mech.feats")


return function()
  return {
    player_anchor = nil,
    text_entities = nil,
    font = love.graphics.newFont("assets/fonts/joystix.monospace-regular.otf", 18),

    parameters = {
      points = 0,
      abilities_raw = {
        strength = 15,
        dexterity = 15,
        constitution = 15,
        intelligence = 8,
        wisdom = 8,
        charisma = 8,
      },
      abilities_final = nil,
      current_index = 1,
      max_index = 1,
      movement_functions = {},
      race = "human",
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

      if State.player then
        self.text_entities = nil
        return
      end

      params.movement_functions = {}
      params.max_index = 0
      local text = ""

      text = text
        .. self.forms.race(params)
        .. self.forms.abilities(params)
        .. self.forms.class(params)

      self.text_entities = State:add_multiple(texting.generate_page(
        text,
        self.font, math.min(love.graphics.getWidth() - 40, State.gui.TEXT_MAX_SIZE[1]),
        "character_creator"
      ))
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

    submit = function(self)
      local params = self.parameters
      if params.points > 0 then return end  -- TODO notification
      local active_choices = class.get_choices(fighter.progression_table, 2)

      local args = {
        params.abilities_final, races[params.race],
        Fun.iter(params.build_options)
          :filter(function(o) return Tablex.contains(active_choices, o) end)
          :tomap(),
        races[params.race].feat_flag
          and feats.perk.options[params.build_options[feats.perk]]
          or nil,
      }

      Log.info("Finishing character creation with args:", args)

      State.player = State:add(Tablex.extend(
        player(unpack(args)),
        {position = self.player_anchor}
      ))
      Log.info("Created player")
      self:refresh()
    end,
  }
end
