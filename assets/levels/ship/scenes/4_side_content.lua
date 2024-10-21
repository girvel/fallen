local level = require("state.level")
local hostility = require("mech.hostility")
local attacking = require("mech.attacking")
local item = require("tech.item")
local actions = require("mech.creature.actions")
local api = require("tech.railing").api
local items = require("library.palette.items")
local decorations = require("library.palette.decorations")
local on_tiles    = require("library.palette.on_tiles")


return function()
  return {
    {
      name = "Dorm razor scene",
      enabled = true,

      characters = {
        dorm_halfling = {},
        dorm_woman = {},
        dorm_beard = {},
        dorm_grunt = {},
        player = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.dorm_halfling.interacted_by == State.player
      end,

      run = function(self, rails, c)
        self.enabled = false

        api.narration("Полурослик без верхней одежды стоит в центре кровавой бани.")
        api.narration("В его волосатой спине торчит опасная бритва; лезвие полностью вошло в плоть.")
        api.narration("На спине несколько характерных резаных ран, но самая серьёзная вызвана застрявшей бритвой.")
        api.narration("Раненый безуспешно пытается извлечь инородный предмет из своей спины.")
        api.line(State.player, "(Он истекал кровью, но продолжал бриться… Отвратительное зрелище)")
        api.narration("Наблюдаемый объект не показывает панику, но явно приближается к потере сознания.")
        api.narration("Окружающие его рабочие выглядят напряженно.")

        local options = {
          "Что здесь произошло?",
          "*Осмотреть бритву*",
          [4] = "*Уйти*",
        }

        while true do
          local chosen_option = api.options(options, true)
          if chosen_option == 1 then
            c.dorm_woman:rotate("up")
            c.dorm_woman:act(actions.move)
            api.narration("К тебе делает шаг смуглая женщина в забрызганном кровью рабочем комбинезоне.")
            api.line(c.dorm_woman, "Он приводил себя в порядок, потом случайно нанес рану.")
            api.line(c.dorm_woman, "Повреждений не так много, надо дать отдохнуть.")
            api.line(c.dorm_woman, "Пара часов шока, пара дней сна, и он будет в порядке.")
          elseif chosen_option == 2 then
            api.narration("Крепко сжатая бритва имеет невероятную заточку.")
            api.narration("Её острота режет взгляд, неудивительно, что неуклюжий полурослик порезался.")
            api.narration("Она бы сошла за хорошее оружие, только вот безопасно изъять её будет тяжело.")
            options[3] = "[Медицина] *Аккуратно изъять бритву*"
          elseif chosen_option == 3 then
            if api.ability_check("medicine", 12) then  -- TODO! RM
              api.narration("Аккуратно изъять бритву в текущей ситуации невозможно.", {check = {"medicine", true}})
              api.narration("По-крайней мере, в одиночку.")
              api.line(State.player, "Эй, прекратите стоять столбом! Положить его на кровать животом вниз! Принести чистую воду!")

              local blackout_end = api.blackout()

              local moved_characters = {"dorm_grunt", "dorm_woman", "dorm_beard"}
              local old_positions = {}
              for _, name in ipairs(moved_characters) do
                local p = rails.positions[name .. "_1"]
                if p then
                  local character = c[name]
                  old_positions[character] = character.position
                  level.move(character, p)
                end
              end
              decorations.lie(c.dorm_halfling, rails.positions.dorm_bed, "lower")
              c.dorm_halfling.ai = {}
              c.dorm_halfling.hp = c.dorm_halfling:get_max_hp() - 3
              level.move(State.player, rails.positions.dorm_player)

              blackout_end()

              api.narration("Рабочие медленно начинают исполнять твои приказы.")
              api.line(State.player, "Бородатый — промывай раны!")
              api.line(State.player, "Громила — держи его крепче!")
              api.line(State.player, "Здесь есть кто-то, умеющий шить?!")
              api.line(c.dorm_woman, "…я умею.")
              api.line(State.player, "Ну так ищи иглу! Живей!")

              c.dorm_woman:rotate("right")
              c.dorm_grunt:rotate("left")
              c.dorm_woman:act(actions.move)
              c.dorm_grunt:act(actions.move)

              blackout_end = api.blackout()

              for ch, p in pairs(old_positions) do
                level.move(ch, p)
              end
              item.drop(c.dorm_halfling, 1)
              level.move(rails.entities.razor, rails.positions.razor_drop)

              blackout_end()

              api.narration("Далее всё проходит как в тумане.")
              api.narration("Секунду назад ты стоял около пускающего слюни полумертвого существа...")
              api.narration("А сейчас он перемотан лоскутами из простыней и спокойно похрапывает.")

            else
              api.line(State.player, "(Для него это лишь очередное ранение. Сколько их у него уже, шесть?)", {check = {"medicine", false}})
              api.narration("Ты подходишь и уверенным движением отрываешь руку с бритвой от его спины.")
              api.narration("Фонтан крови обливает все вокруг, чудом не попадая на тебя.")
              api.narration("Бритва со свистом вылетает из слабой ладони, пролетая половину комнаты.")
              api.narration("И попадая в глаз одному из рабочих.")
              api.narration("Рабочий в недоумении хватается за ручку инородного предмета. В тот же момент, полурослик падает ничком — он мертв.")
              Table.remove(c.dorm_halfling.inventory, rails.entities.razor)
              item.give(c.dorm_grunt, rails.entities.razor)
              attacking.damage(c.dorm_grunt, 8, true)
              attacking.damage(c.dorm_halfling, 10, true)
              api.narration("Толпа вмиг звереет, видимо, ошибочно посчитав тебя виновным в этой вакханалии.")
              hostility.make_hostile("dreamers_1")
            end
            break
          else
            break
          end
        end
      end,
    },
  }
end
