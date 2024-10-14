local api = require("tech.railing").api
local level = require("state.level")
local item = require("tech.item")
local experience = require("mech.experience")
local quest = require("tech.quest")
local items = require("library.palette.items")


return function()
  return {
    open_left_megadoor = {
      name = "Open left megadoor",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return true
      end,

      run = function(self, rails)
        self.enabled = false

        rails.entities.megadoor11:open()
        rails.entities.megadoor12:open()
        rails.entities.megadoor13:open()
      end,
    },

    checkpoint_4 = {
      name = "Checkpoint (4)",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return true
      end,

      run = function(self, rails, dt)
        self.enabled = false
        api.checkpoint_base()

        level.move(State.player, rails.positions.checkpoint_4)
        api.update_quest({warmup = quest.COMPLETED})
        rails.scenes.player_leaves_his_room.enabled = false
        rails.scenes.open_left_megadoor.enabled = true
        rails.entities.detective_door.locked = false

        State.player.experience = experience.for_level[3]
        State.gui.creator:refresh()
        State.gui.creator:submit()

        item.give(State.player, State:add(items.pole()))
        api.center_camera()
      end,
    },

    {
      name = "Markis dialogue",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities.markis.interacted_by == State.player
      end,

      furry_recognized = nil,

      run = function(self, rails)
        rails.entities.markis.interacted_by = nil

        api.line(rails.entities.markis, "Пропустите-с, несу уголь в кош-тельную")

        if rails.furry_recognized == nil then
          api.line(State.player, "(Это… Кот?)")

          self.furry_recognized = api.ability_check("nature", 18)
          if self.furry_recognized then
            api.narration(
              "Он представитель расы зверолюдей с западного континента; их аномальная природа влияет на эмбрион в момент созревания, в результате дети рождаются с чертами разных зверей.",
              {check = {"nature", true}}
            )
          else
            api.narration("Определенно. Кот.", {check = {"nature", false}})
          end
        end
      end,
    },
  }
end
