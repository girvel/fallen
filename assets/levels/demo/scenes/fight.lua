local api = require("tech.railing").api
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
        rails.scenes.half_orc_mercy.enabled = true
      end,
    },

    half_orc_mercy = {
      name = "Half-orc talks after player spares him",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return rails.entities[3].faction == State.player.faction
      end,

      run = function(self, rails, dt)
        self.enabled = false
        api.narration("Полуорк несколько секунд тяжело дышит, опираясь о ближайшую стену.")
        rails.entities[3]:rotate(Vector.name_from_direction(
          (State.player.position - rails.entities[3].position):normalized()
        ))
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
            api.line(rails.entities[3], "Я..?")
            api.line(rails.entities[3], "Меня зовут Рронт. С двумя Р…")
            api.line(rails.entities[3], "Фамилия - Бобински")
            api.line(rails.entities[3], "Получается Рронт Бобински, да")

            local picked_suboption = api.options({
              "Понятно, Ронт, а что ты здесь делаешь?",
              "Да я не имя твоё спрашивал, **идиот**. Кто такой и что здесь делаешь? По существу.",
            })

            if picked_suboption == 1 then
              api.line(rails.entities[3], "Я… Я не знаю")
              api.line(rails.entities[3], "Помню мы с друзьями, ну, культурно отдыхали")
              api.line(rails.entities[3], "С алкоголем")
              api.line(rails.entities[3], "А потом я здесь, а вокруг эти… как зомби себя ведут")
              api.line(rails.entities[3], "И правильно Рронт, две р")
            else
              api.line(rails.entities[3], "Не надо кричать!")
              api.line(rails.entities[3], "Я просто выпивал с друзьями")
              api.line(rails.entities[3], "Потом проснулся здесь")
              api.line(rails.entities[3], "Я ничего не помню!")
              api.line(rails.entities[3], "Я ничего не понимаю!!")
              api.line(rails.entities[3], "Отпусти меня!!!")
            end
          elseif picked_option == 2 then
            api.line(rails.entities[3], "Я не вызывал никакой диверсии!")
            api.line(rails.entities[3], "Просто пытался выбраться")
            api.line(rails.entities[3], "И шумел чтоб снаружи услышал кто")
            api.line(rails.entities[3], "Ещё подумал, что дверь откроется, если сломать эту вот хренотеть")

            local picked_suboption = api.options({
              "А насчёт остального? Твои перчатки, весь этот бардак, ложь в показаниях?",
              "У тебя верно с головой не в порядке. И актёр ты никудышный. Вычислить обман было проще, чем опрокинуть ведро.",
            })

            if picked_suboption == 1 then
              api.line(rails.entities[3], "Я просто испугался")
              api.line(rails.entities[3], "И подумал притвориться одним из этих")
              api.line(rails.entities[3], "Видимо неудачно")
            else
              api.line(rails.entities[3], "Я всего лишь хотел найти момент, чтобы сбежать из этого ада")
              api.line(rails.entities[3], "И вредить я никому не хотел, только выбраться")
            end
          elseif picked_option == 3 then
            api.line(rails.entities[3], "Не знаю…")
            api.line(rails.entities[3], "О, я попробую найти выход, буду искать и точно найду.")
            api.line(rails.entities[3], "Верно.")
          elseif picked_option == 4 then
            api.line(rails.entities[3], "Ничего!")
            api.line(rails.entities[3], "Пока ты не открыл дверь, я был заперт здесь")
            api.line(rails.entities[3], "Как в тюрьме")
            api.line(rails.entities[3], "Или во гробу")
          elseif picked_option == 5 then
            api.line(rails.entities[3], "И какое?")

            local picked_suboption = api.options({
              "Я внимательно выслушал тебя, диверсант, но боюсь, что должен тебя уничтожить. Ничего личного.",
              "Слушать тебя было бессмысленно, мертвым от такого идиота будет больше пользы.",
              "Можешь идти, не думаю, что ты виноват в какой-либо диверсии.",
              "И на такого идиота я потратил ценные минуты своей жизни?! Долой с глаз моих! И чтоб больше я тебя не видел!",
            })

            if picked_suboption == 1 or picked_suboption == 2 then
              rails.entities[3].faction = "rebellion"
              State:start_combat({State.player, rails.entities[3]})
            else
              rails.entities[3].ai.mode = engineer_ai.modes.run_away_to(rails.positions.exit)
            end
            break
          end
        end
      end,
    },

    {
      name = "Half orc was killed",
      enabled = true,
      start_predicate = function(self, rails, dt) return rails.entities[3].hp <= 0 end,

      run = function(self, rails, dt)
        self.enabled = false
        api.notification("Задача выполнена", true)
        api.notification("Ожидайте следующее задание", true)
        State.gui.wiki.quests_states.detective = 2
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
        rails:cancel_scene(rails.scenes.player_attacks_half_orc)
        rails:cancel_scene(rails.scenes.half_orc_mercy)

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

        api.notification("Это была ошибка", true)
        api.notification("Устранить агрессивных инженеров", true)
      end,
    },

    player_wins_dreamers = {
      name = "Player wins the fight against dreamers",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return State.player.hp > 0 and not State.combat
      end,

      run = function(self, rails, dt)
        self.enabled = false
        api.notification("Задача выполнена неудовлетворительно", true)
        api.notification("Ожидайте следующее задание", true)
        api.discover_wiki({fought_dreamers = true})
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
