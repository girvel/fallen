local api = require("tech.railing").api
local special = require("tech.special")
local engineer_ai = require("library.engineer_ai")


return function()
  return {
    player_attacks_half_orc = {
      name = "Player attacks half-orc",
      enabled = true,
      start_predicate = function(self, rails)
        return Fun.iter(State.agression_log)
          :any(function(pair)
            return Tablex.shallow_same(pair, {State.player, rails.entities[3]})
          end)
      end,
      run = function(self, rails)
        self.enabled = false
        rails.scenes.half_orc_begs.enabled = true
        rails.entities[3].faction = "rebellion"
        rails.entities[3].interact = nil
        if rails.entities[3]._highlight then
          State:remove(rails.entities[3]._highlight)
        end
        State:start_combat({State.player, rails.entities[3]})
      end,
    },

    half_orc_begs = {
      name = "Half-orc begs for his life",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return rails.entities[3].hp <= rails.old_hp[3] / 2
      end,

      run = function(self, rails, dt)
        self.enabled = false
        rails.entities[3].ai.mode = engineer_ai.modes.skip_turn()
        State:add(special.floating_line("Стой! Остановись, мужик!!!", rails.entities[3].position))
        rails.scenes.half_orc_mercy.enabled = true
      end,
    },

    half_orc_mercy = {
      name = "Half-orc talks after player spares him",
      enabled = false,
      start_predicate = function(self, rails, dt) return rails.entities[3].faction == State.player.faction end,

      run = function(self, rails, dt)
        self.enabled = false
        api.narration("Полуорк несколько секунд тяжело дышит, опираясь о ближайшую стену.")
        api.narration("В его взгляде нет ярости, только первобытный страх.")
        api.line(State.player, "(Его родичи известны буйным нравом)")
        api.line(State.player, "(И сдаваться они не умеют)")
        api.line(State.player, "(Он же больше смахивает на нежного городского жителя)")

        local options = {
          "Кто ты такой?",
          "Это ты вызвал диверсию?",
          "Куда ты пойдешь, если я тебя отпущу?",
          "Может ты видел или слышал что-то интересное?",
          "Я принял решение."
        }

        while true do
          local picked_option = api.options(options, true)

          if picked_option == 1 then
            api.line(rails.entities[3], "")
            api.line(rails.entities[3], "")
            api.line(rails.entities[3], "")
            api.line(rails.entities[3], "")

            local picked_suboption = api.options({
              "",
              "",
            })

            if picked_suboption == 1 then
              api.line(rails.entities[3], "")
              api.line(rails.entities[3], "")
              api.line(rails.entities[3], "")
              api.line(rails.entities[3], "")
              api.line(rails.entities[3], "")
            else
              api.line(rails.entities[3], "")
              api.line(rails.entities[3], "")
              api.line(rails.entities[3], "")
              api.line(rails.entities[3], "")
              api.line(rails.entities[3], "")
              api.line(rails.entities[3], "")
            end
          elseif picked_option == 2 then
            api.line(rails.entities[3], "")
            api.line(rails.entities[3], "")
            api.line(rails.entities[3], "")
            api.line(rails.entities[3], "")

            local picked_suboption = api.options({
              "",
              "",
            })

            if picked_suboption == 1 then
              api.line(rails.entities[3], "")
              api.line(rails.entities[3], "")
              api.line(rails.entities[3], "")
            else
              api.line(rails.entities[3], "")
              api.line(rails.entities[3], "")
            end
          elseif picked_option == 3 then
            api.line(rails.entities[3], "")
            api.line(rails.entities[3], "")
            api.line(rails.entities[3], "")
          elseif picked_option == 4 then
            api.line(rails.entities[3], "")
            api.line(rails.entities[3], "")
            api.line(rails.entities[3], "")
            api.line(rails.entities[3], "")
          elseif picked_option == 5 then
            api.line(rails.entities[3], "")

            local picked_suboption = api.options({
              "",
              "",
              "",
              "",
            })

            if picked_suboption == 1 or picked_suboption == 2 then
              rails.entities[3].faction = "rebellion"
              State:start_combat({State.player, rails.entities[3]})
            end
            break
          end
        end
      end,
    },

    player_attacks_dreamer = {
      name = "Player attacks one of the dreamers",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return Fun.iter({1, 2, 4})
          :any(function(i)
            return Fun.iter(State.agression_log)
              :any(function(pair)
                return Tablex.shallow_same(pair, {State.player, rails.entities[i]})
              end)
          end)
      end,

      run = function(self, rails, dt)
        self.enabled = false
        rails.scenes.second_rotates_valve.enabled = false
        rails.scenes.player_wins_dreamers.enabled = true
        rails.scenes.player_attacks_half_orc.enabled = false

        State.player.faction = "rebellion"
        rails.entities[3].faction = "rebellion"

        local engineers = Fun.range(1, 4):map(function(i) return rails.entities[i] end):totable()
        State:start_combat(Tablex.concat({State.player}, engineers))
        Fun.iter(engineers):each(function(e)
          e.interact = nil
          if e._highlight then
            State:remove(e._highlight)
            e._highlight = nil
          end
        end)
        rails.entities[3].ai.mode = engineer_ai.modes.run_away_to(rails.positions.exit)

        api.notification(rails, "Это была ошибка", true)
        api.wait_seconds(5)
        api.notification(rails, "Устранить агрессивных инженеров", true)
      end,
    },

    player_wins_dreamers = {
      name = "Player wins the fight against dreamers",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return State.player.hp > 0 and not State.move_order
      end,

      run = function(self, rails, dt)
        self.enabled = false
        State.gui.wiki.discovered_pages.dreamers = 2
        State.gui.wiki.discovered_pages.codex = 2
        api.notification(rails, "Задача выполнена неудовлетворительно", true)
        api.wait_seconds(11)
        api.notification(rails, "Ожидайте следующее задание", true)
      end,
    },

    {
      name = "Half-orc runs away",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return rails.entities[3].ai.mode == engineer_ai.modes.run_away_to(rails.positions.exit)
          and rails.entities[3].position == rails.positions.exit
      end,

      run = function(self, rails, dt)
        self.enabled = false
        api.wait_seconds(0.5)
        State:remove(rails.entities[3])
      end,
    },
  }
end
