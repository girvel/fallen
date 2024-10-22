local level = require("state.level")
local hostility = require("mech.hostility")
local attacking = require("mech.attacking")
local item = require("tech.item")
local actions = require("mech.creature.actions")
local api = require("tech.railing").api
local decorations = require("library.palette.decorations")


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
            if api.ability_check("medicine", 12) then
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

    guard_1_rotates = {
      name = "Guard #1 rotates",
      enabled = true,

      characters = {
        guard_1 = {},
      },

      _start_predicate_pid = {},
      start_predicate = function(self, rails, dt, c)
        return (
          not State.combat
          and not rails:is_running("stealing_alcohol")
          and Common.relative_period(8, dt, self._start_predicate_pid)
        )
      end,

      run = function(self, rails, c)
        self.enabled = false
        c.guard_1:rotate("down")

        local t = love.timer.getTime()
        while love.timer.getTime() - t < 1 or rails:is_running("stealing_alcohol") do
          coroutine.yield()
        end

        c.guard_1:rotate("left")
        self.enabled = true
      end,
    },

    stealing_alcohol = {
      name = "Player tries to steal alcohol from the storage room",
      enabled = true,

      characters = {
        player = {},
        alcohol_crate = {},
        guard_1 = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.alcohol_crate.interacted_by == c.player and not State.combat
      end,

      _caught_n = 0,

      run = function(self, rails, c)
        c.alcohol_crate.interacted_by = nil

        if c.guard_1.direction == "left" then
          self._caught_n = self._caught_n + 1
          api.line(c.guard_1, ({
            "Тебе не положено это брать.",
            "Последнее предупреждение. Eщё раз — последует наказание.",
            "Наказание за воровство — смерть.",
          })[self._caught_n])
          if self._caught_n == 3 then
            hostility.make_hostile("combat_dreamers")
          end
          return
        end

        api.narration("В ящике полным-полно съестных припасов различной ценности.")
        api.narration("Основная масса — старые консервы в невзрачных упаковках, но присутствуют и относительно свежие овощи и даже вполне сносное мясо.")
        api.narration("В центре композиции лежит единственный алкогольный напиток: бутылка дешёвого рома “Русалкино молоко”.")
        api.narration("Бутылка сияет, как бриллиант в короне, а русалка на этикетке так и завлекает на грех.")
        api.narration("Когда охранник ненадолго отворачивается, ты понимаешь, что мог бы незаметно забрать бутылку.")

        if api.get_quest("alcohol") == 0 then
          api.line(c.player, "(Мне она ни к чему, разве что испытать риск ради риска)")
          api.narration("Кажется, это называют клептоманией.")
        else
          api.line(c.player, "(Хоть мне это и не по душе, я мог бы незаметно её забрать)")
          api.line(c.player, "(Если бы только была возможность куда-то увести этого охранника…)")
        end

        local chosen_option = api.options({
          "*Уйти, воровство для слабых*",
          "[Харизма] *Взять в открытую, ведь ты не вор*",
          "[Внимание] *Не украсть, а аккуратно забрать*",
        })

        if chosen_option == 1 then
          api.narration("Ты оставляешь бутылку грустить в компании скучной еды.")
          api.narration("Но ты всегда сможешь её навестить.")
          return
        end

        self.enabled = false
        if chosen_option == 2 then
          if api.ability_check("cha", 18) then
            api.narration("Ты медленно берёшь бутылку, не слушая комментарии охранника на фоне.", {check = {"cha", true}})
            c.guard_1:rotate("left")
            api.line(c.guard_1, "Эй, верни на место!")
            api.narration("Но ты не уходишь с ней, а всего лишь рассматриваешь на месте: оцениваешь этикетку, внимательно читаешь состав, проводишь пальцем вдоль фигуры русалки.")
            api.narration("Оглядываясь в сторону охранника, указываешь ему на мелкий шрифт...")
            api.narration("Затем слегка потряхиваешь бутылку с деловым видом.")
            api.line(c.player, "Теперь всё понятно, доложу начальству в ближайший срок.")
            api.line(c.player, "Конечно, в письменном виде.")
            api.narration("С этими словами ты аккуратно заматываешь бутылку в газету, найденную в соседнем ящике, ставишь подпись в блокноте.")
            c.guard_1:rotate("down")
            api.narration("Оглядываешься, охранник уже потерял к тебе интерес.")
            api.line(c.player, "(Вот теперь можно идти)")
            api.narration("Бутылка при тебе. И нет, ты не понимаешь, как у тебя это получилось.")

            rails.bottles_taken = rails.bottles_taken + 1
            c.alcohol_crate.interact = nil
            return
          end

          api.narration("Ты аккуратно берёшь бутылку, делаешь шаг в сторону выхода, и...", {check = {"cha", false}})
        else  -- chosen_option == 3
          if api.ability_check("perception", 12) then
            api.line(c.player, "(Стоит немного подготовиться)", {check = {"perception", true}})
            api.narration("Охранники ведут себя циклично, как по вызубренной инструкции — кажется, даже чихают по таймеру.")
            api.narration("Ты подсчитываешь момент, когда они не смотрят;")
            api.narration("Пяткой откатываешь валяющийся на полу помидор — было бы глупо на него случайно наступить;")
            api.narration("Аккуратно берёшь бутылку, — охранник только начинает поворачиваться, — делаешь шаг в сторону двери...")
            api.narration("И бодрой походкой победителя выходишь из кладовой.")

            rails.bottles_taken = rails.bottles_taken + 1
            c.alcohol_crate.interact = nil
            return
          end

          api.narration("Ты аккуратно берёшь бутылку, делаешь шаг в сторону выхода, и...", {check = {"perception", false}})
        end

        api.narration("Наступаешь на валяющийся помидор.")

        c.guard_1:rotate("left")
        if State:exists(rails.entities.guard_2) then
          rails.entities.guard_2:rotate("left")
        end

        api.narration("Оба охранника вмиг поворачиваются в твою сторону.")
        api.narration("Они хватаются за дубинки.")
        api.line(c.guard_1, "За кражу и порчу собственности полагается наказание.")
        api.line(c.player, "Через твой труп.")

        hostility.make_hostile("combat_dreamers")
      end,
    },
  }
end
