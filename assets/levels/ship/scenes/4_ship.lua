local ai = require("tech.ai")
local level = require("state.level")
local hostility = require("mech.hostility")
local attacking = require("mech.attacking")
local item = require("tech.item")
local actions = require("mech.creature.actions")
local api = require("tech.railing").api
local decorations = require("library.palette.decorations")
local experience = require("mech.experience")
local quest = require("tech.quest")
local items = require("library.palette.items")
local live  = require("library.palette.live")
local shaders = require("tech.shaders")
local player  = require("state.player")
local health  = require("mech.health")


return function()
  return {
    parasites_start = {
      name = "Start parasites quest",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return api.get_quest("detective") > 2
      end,

      run = function(self, rails)
        self.enabled = false

        api.wait_seconds(30)
        api.notification("Иди в рубку", true)
        api.wait_seconds(1)
        api.notification("Вверх по коридору", true)
        api.wait_seconds(1)
        api.update_quest({parasites = 1})
      end,
    },

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

      run = function(self, rails)
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
        State:remove(rails.entities.captain_door_note)
        api.update_quest({parasites = 1})
        rails.has_valve = true
        rails.bottles_taken = 3
      end,
    },

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

              api.fade_out()

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

              api.fade_in()

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

              api.fade_out()

              for ch, p in pairs(old_positions) do
                level.move(ch, p)
              end
              item.drop(c.dorm_halfling, 1)
              level.move(rails.entities.razor, rails.positions.razor_drop)

              api.fade_in()

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
              health.damage(c.dorm_grunt, 8, true)
              health.damage(c.dorm_halfling, 10, true)
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
            hostility.make_hostile("guards")
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
            rails.source_of_first_alcohol = rails.source_of_first_alcohol or "storage_room"
            c.alcohol_crate:open()
            return
          end

          api.narration("Ты аккуратно берёшь бутылку, делаешь шаг в сторону выхода, и...", {check = {"cha", false}})
        else  -- chosen_option == 3
          if api.ability_check("perception", 12) then
            api.line(c.player, "(Стоит немного подготовиться)", {check = {"perception", true}})
            api.narration("Охранники ведут себя циклично, как по вызубренной инструкции — кажется, даже чихают по таймеру.")
            api.narration("Ты подсчитываешь момент, когда они не смотрят;")
            api.narration("Пяткой откатываешь валяющийся на полу помидор — было бы глупо на него случайно наступить;")

            rails.bottles_taken = rails.bottles_taken + 1
            rails.source_of_first_alcohol = rails.source_of_first_alcohol or "storage_room"
            c.alcohol_crate:open()

            c.player:rotate("down")
            c.player:act(actions.move)
            api.narration("Аккуратно берёшь бутылку, — охранник только начинает поворачиваться, — делаешь шаг в сторону двери...")

            local travel_coroutine = coroutine.create(Fn.curry(ai.api.tcod_travel,
              c.player, rails.positions.storage_room_exit
            ))

            while coroutine.status(travel_coroutine) ~= "dead" do
              Common.resume_logged(travel_coroutine)
              api.wait_seconds(.25)
            end

            api.narration("И бодрой походкой победителя выходишь из кладовой.")
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

        hostility.make_hostile("guards")
      end,
    },

    {
      name = "Talking to the first guard",
      enabled = true,

      characters = {
        guard_1 = {},
        player = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.guard_1.interacted_by == c.player
      end,

      run = function(self, rails, c)
        c.guard_1.interacted_by = nil

        api.line(c.guard_1, "Я на посту, говори с моим собратом.")
      end,
    },

    {
      name = "Talking to the second guard",
      enabled = true,

      characters = {
        guard_2 = {},
        player = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.guard_2.interacted_by == c.player
      end,

      _options = {
        "*осмотреть его форму*",
        -- [2]
        -- [3]
        -- [4]
      },

      _can_activate = {
        [2] = true,
        [3] = true,
      },

      run = function(self, rails, c)
        c.guard_2.interacted_by = nil

        api.narration("Крепкий мужчина в военной форме одним глазом пристально смотрит на тебя, вторым на вход.")
        if c.guard_2.inventory.other_hand == rails.entities.captain_door_valve then
          api.narration("В одной руке он сжимает дубинку, другой — держит крупный стальной вентиль.")
        end

        if not State:exists(rails.entities.captain_door_note)
          and not rails.has_valve
        then
          if api.get_quest("parasites") == 1 then
            if self._can_activate[2] then
              self._options[2] = "Я за вентилем — мне нужно попасть в рубку"
              self._can_activate[2] = false
            end
          else
            if self._can_activate[3] then
              self._options[3] = "Я за вентилем."
              self._can_activate[3] = false
            end
          end
        else
          self._options[2] = nil
          self._options[3] = nil
        end

        if self._can_activate[4] and Table.contains({1, 2}, api.get_quest("alcohol")) then
          self._can_activate[4] = false
          self._options[4] = "Не знаешь, где можно найти алкоголь?"
        end

        self._options[5] = "*Уйти*"

        while true do
          local chosen_option = api.options(self._options, true)

          if chosen_option == 1 then
            api.narration("Он одет так же, как и ты — старая военная форма без опознавательных знаков.")

            if api.ability_check("history", 8) then
              api.narration("Стандартная военно-морская форма солдат Трансанской Республики, от рядового до младшего офицера.", {check = {"history", true}})
              api.narration("Её тоннами шили во времена Мировой Войны, а сейчас продают за бесценок.")
              api.narration("Форма традиционно располагает  погонами, нашивками и прочими памятными знаками, символизирующими родство с определенной частью Республики.")
              api.narration("Но на вашей форме лишь неотстирываемая многолетняя пыль.")
            else
              api.narration("Ты разглядываешь форму, пытаешься найти в ней что-то знакомое.", {check = {"history", true}})
              -- TODO SFX
              api.narration("Укороченные рукава, множество нашивных кармашков, бронзовые пуговицы...")
              api.narration("Бежевые ботинки цвета хаки... Дубинка...")
              -- TODO disable SFX
              api.narration("Абсолютно никаких ассоциаций. Ничего из этого тебе не знакомо.")
              api.line(c.player, "(Мне показалось, я что-то узнал)")
              api.narration("Тебе показалось. Не думай об этом.")
            end

          elseif chosen_option == 2 then
            api.narration("Спящий без раздумий протягивает  увесистый вентиль.")
            api.line(c.guard_2, "Держи, удачи в зачистке, будет тяжело...")
            rails:give_valve_to_player()
            if api.ability_check("insight", 12) then
              api.narration("Ты замечаешь, что он хочет сказать что-то ещё.", {check = {"insight", true}})
              api.line(c.player, "Закончи свою мысль.")
              api.line(c.guard_2, "Будет тяжело — возвращайся и возьми в помощь моего напарника.")
              api.line(c.guard_2, "(Стоит запомнить)")
            else
              api.line(c.player, "(Тяжело?! Да за кого он меня принимает?!)", {check = {"insight", false}})
              api.narration("Ты надменно оборачиваешься, готовясь уходить.")
            end
            break

          elseif chosen_option == 3 then
            api.line(c.guard_2, "Не положено, вентиль будет у меня, пока не поступит иной приказ вышестоящего.")
            api.narration("Он указывает пальцем на свой лоб, будто приказ придёт точно в него.")
            api.narration("Пока ты выбираешь слова, он с силой давит пяткой пробегающего таракана; превосходная скорость реакции для такого громилы.")
            api.narration("По неизвестной причине, тебя начинает наполнять гнев.")

            if api.options({
              "[Запугивание] *Заставить его отдать вентиль*",
              "*Отступить; гнев — оружие слабых*",
            }) == 1 then
              api.line(c.player, "(Что он себе позволяет?)")
              api.line(c.player, "(Моё желание идти, куда я захочу, не остановит какой-то выскочка)")
              api.narration("Резким движением ты пододвигаешь своё лицо вплотную к нему; в отражении глаз замечаешь кошмарный оскал.")

              if api.ability_check("intimidation", 12) then
                api.line(c.player, "Я. ЗДЕСЬ. ВЫШЕСТОЯЩИЙ.", {check = {"intimidation", true}})
                api.narration("Он даже бровью не шелохнул, но тебя уже не остановить.")
                api.line(c.player, "ОТДАЙ. МНЕ. ВЕНТИЛЬ.")
                api.line(c.player, "ЧЕРТОВ ВЕНТИЛЬ, ОТ ГРЁБАНОЙ КОМНАТЫ, КОТОРУЮ ТЫ ЗАПЕР БЕЗ СПРОСА")
                api.line(c.player, "ВЕЧНО ВСЁ ПРИХОДИТСЯ ДЕЛАТЬ ЗА ТАКИХ БЕЗМОЗГЛЫХ КУКОЛ КАК ТЫ")
                api.narration("Не страх, но сомнение появилось на его лице.")
                api.narration("Время сбавить градус. Ты возвращаешься на приемлемое расстояние и протягиваешь ладонь в ожидании.")
                api.line(c.player, "Я — вышестоящий, ты должен отдать его мне.")
                api.narration("Несколько раз моргнув, он протягивает тебе невероятно холодный вентиль.")
                api.narration("Похоже, ты перегрелся пока кричал.")
                api.narration("Но вентиль у тебя; ты добился своего.")
                rails:give_valve_to_player()
              else
                api.line(c.player, "Я В РОТ ИМЕЛ ТВОЕГО ВЫШЕСТОЯЩЕГО", {check = {"intimidation", false}})
                api.notification("...", true)
                api.line(c.player, "ОТДАВАЙ ВЕНТИЛЬ ТВАРЬ")
                api.narration("Ты видишь как вены на лице охранника раздуваются, наполняясь чистой яростью.")
                api.line(c.guard_2, "Прими наказание за грубость со смирением!")
                hostility.make_hostile("guards")
              end
            end
            break

          elseif chosen_option == 4 then
            api.line(c.guard_2, "Если ищешь спирт, посмотри в медицинском отсеке.")

          else -- chosen_option == 5
            break
          end
        end
      end,
    },

    {
      name = "Interacting with the captain megadoor",
      enabled = true,

      characters = {
        player = {},
        captain_door = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.captain_door.interacted_by == c.player
      end,

      _options = {
        [2] = "[Атлетика] *провернуть движущий механизм руками*",
      },

      run = function(self, rails, c)
        c.captain_door.interacted_by = nil

        if State:exists(rails.entities.captain_door_note) then
          api.narration("Кто-то скрутил с двери вентиль и прикрепил рядом записку:")
          State:remove(rails.entities.captain_door_note)
          coroutine.yield()
          api.narration("“Для допуска обратитесь в офицерскую кладовую.”")
        else
          api.narration("Кто-то скрутил с двери вентиль.")
        end

        self._options[1] = "*уйти*"

        if rails.has_valve then
          self._options[3] = "*Вернуть вентиль на законное место*"
        end

        local inventory = c.player.inventory
        local gas_key = rails.entities.gas_key
        if inventory.main_hand == gas_key or inventory.other_hand == gas_key then
          self._options[4] = "*Использовать газовый ключ как рычаг*"
        end

        State:remove_multiple(c.captain_door._popup)

        while true do
          local chosen_option_1 = api.options(self._options, true)

          if chosen_option_1 == 1 then
            break
          elseif chosen_option_1 == 2 then
            if api.ability_check("athletics", 18) then
              api.narration("Такой трюк без инструментов тянет на небольшое чудо.", {check = {"athletics", true}})
              api.narration("После нескольких безуспешных попыток, ты продвинулся лишь на треть оборота, но ладони уже покрылись ссадинами.")
              api.narration("Ты чувствуешь, в тебе есть сила закончить это испытание, но заплатить придётся здоровьем.")

              local chosen_option_2 = api.options({
                "*Отказаться от этой затеи*",
                "*Упорно продолжать*",
              })

              if chosen_option_2 == 1 then
                api.narration("Верное решение; свою силу ты уже доказал.")
                api.narration("Ты найдешь другой способ.")
              else
                local lines = {
                  "Не щадя своего тела, затирая мозоли в кровь, ты заканчиваешь первый оборот.",
                  "Может, твоя кровь стала смазкой в механизме.",
                  "А может, вселенная вознаграждает упорных.",
                  "Но остальные обороты даются легко — разумеется, по твоим меркам.",
                }

                health.damage(c.player, 1)
                for _, line in ipairs(lines) do
                  api.narration(line)
                  health.damage(c.player, 1)
                end

                c.captain_door:open()
                api.narration("Проход открыт, и ты чувствуешь себя сильным, как Железный Джерри.")
                break
              end
            else
              api.narration("Не стоило и пытаться, без инструментов это обычному человеку не под силу.", {check = {"athletics", false}})
              api.narration("Придётся найти вентиль или инструмент, способный провернуть механизм.")
            end
          elseif chosen_option_1 == 3 then
            rails.has_valve = false

            for i = 1, 3 do
              local position = c.captain_door.position + Vector.left * (i - 1)
              State:remove(State.grids.solids[position])
              local e = State:add(live["megadoor%s" % {4 - i}](), {position = position})
              if i == 1 then
                e.locked = false
              end
              coroutine.yield()
            end

            api.narration("Ты надёжно закрепляешь вентиль на движущий механизм.")
            api.narration("Выглядит складно, лаконично, так, будто и не снимали.")
            api.narration("Наконец, ты можешь открыть злосчастную дверь.")
            break
          else  -- chosen_option_1 == 4
            api.narration("С этим бы справился и ребёнок.")
            api.narration("Десяток секунд пыхтения; попытки вспомнить, в какую сторону нужно крутить.")
            c.captain_door:open()
            api.narration("Звук твоей внеочередной победы.")
            api.narration("Газовый ключ способен открыть тебе множество дверей.")
            break
          end
        end
      end,
    },

    {
      name = "Algenus orders pulling the lever",
      enabled = true,

      start_predicate = function(self, rails, dt, c)
        return not State:exists(rails.entities.captain_door)
          or rails.entities.captain_door.layer ~= "solids"
      end,

      run = function(self, rails, c)
        self.enabled = false
        rails.scenes.parasites_start.enabled = false

        api.wait_seconds(8)
        api.notification("Разблокируй желтый рычаг на правой панели.", true)
        api.wait_seconds(3)
        api.update_quest({parasites = 2})
      end,
    },

    {
      name = "Change of FOV radius for water view",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position[2] == rails.positions.water_fov_border_enter[2]
          and State.player.fov_radius ~= 30
      end,

      run = function(self, rails)
        State.player.fov_radius = 30
      end,
    },

    {
      name = "Change of FOV radius back after water view",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position[2] == rails.positions.water_fov_border_exit[2]
          and State.player.fov_radius ~= player.DEFAULT_FOV
      end,

      run = function(self, rails)
        State.player.fov_radius = player.DEFAULT_FOV
      end,
    },

    {
      name = "Looting sigi",
      enabled = true,

      characters = {
        player = {},
        sigi_crate = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.sigi_crate.interacted_by == c.player
      end,

      run = function(self, rails, c)
        c.sigi_crate:open()
        api.narration("Среди кучи барахла ты находишь видавшую жизнь пачку.")
        api.narration("На этикетке изображена высокая полуорчиха в роскошном прогулочном платье, на фоне счастливые рабочие собирают табачные листья; высвецшим курсивом написано: “Дуушнарские, теперь в новом дизайне”")
        rails:sigi_update("found")
      end,
    },
  }
end
