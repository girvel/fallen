local tcod = require("tech.tcod")
local fx = require("tech.fx")
local ai = require("tech.ai")
local level = require("tech.level")
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
local sound   = require("tech.sound")
local sounds  = require("tech.sounds")


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

        rails.entities.megadoor_1:open()
      end,
    },

    cp4 = {
      name = "Checkpoint (4)",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return true
      end,

      run = function(self, rails)
        self.enabled = false
        rails.scenes.cp1:run(rails)

        level.move(State.player, rails.positions.checkpoint_4)
        api.update_quest({warmup = quest.COMPLETED})
        rails.scenes.player_leaves_his_room.enabled = false
        rails.scenes.open_left_megadoor.enabled = true
        rails.entities.detective_door.locked = false

        State.player.experience = experience.for_level[2]
        State.gui.creator:refresh()
        State.gui.creator:submit()

        item.give(State.player, State:add(items.pole(), {damage_roll = D(98)}))
        api.center_camera()
        State:remove(rails.entities.captain_door_note)
        --api.update_quest({parasites = 1, alcohol = quest.COMPLETED})
        api.update_quest({parasites = 1, alcohol = 1})
        rails.has_valve = true
        rails.bottles_taken = 2

        --rails:notice_flask()
        health.set_hp(State.player, 20)
        rails:spawn_possessed()
        coroutine.yield()
        health.damage(rails.entities.possessed, 1000)
        rails:start_lunch()
        rails.seen_water = true
        rails.met_son_mary = true
        rails.entities.son_mary.player_name = "Гаспар"
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
        api.line(State.player, "(Он истекал кровью, но продолжал бриться... Отвратительное зрелище)")
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
              health.set_hp(c.dorm_halfling, c.dorm_halfling:get_max_hp() - 3)
              level.move(State.player, rails.positions.dorm_player)

              api.fade_in()

              api.narration("Рабочие медленно начинают исполнять твои приказы.")
              api.line(State.player, "Бородатый — промывай раны!")
              api.line(State.player, "Громила — держи его крепче!")
              api.line(State.player, "Здесь есть кто-то, умеющий шить?!")
              api.line(c.dorm_woman, "...я умею.")
              api.line(State.player, "Ну так ищи иглу! Живей!")

              c.dorm_woman:rotate("right")
              c.dorm_grunt:rotate("left")
              c.dorm_woman:act(actions.move)
              c.dorm_grunt:act(actions.move)

              api.fade_out()

              for ch, p in pairs(old_positions) do
                level.move(ch, p)
              end
              item.drop(c.dorm_halfling, "inside")
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
      boring_flag = true,

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
          api.line(c.player, "(Если бы только была возможность куда-то увести этого охранника...)")
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
      name = "Talking alcohol",
      enabled = true,

      characters = {
        player = {},
        alcohol_crate = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.alcohol_crate.interacted_by == c.player
          and not State.combat
          and not State:exists(rails.entities.guard_1)
      end,

      run = function(self, rails, c)
        self.enabled = false

        api.narration("В ящике полным-полно съестных припасов различной ценности.")
        api.narration("Основная масса — старые консервы в невзрачных упаковках, но присутствуют и относительно свежие овощи и даже вполне сносное мясо.")
        api.narration("В центре композиции лежит единственный алкогольный напиток: бутылка дешёвого рома “Русалкино молоко”.")
        api.narration("Бутылка сияет, как бриллиант в короне, а русалка на этикетке так и завлекает на грех.")

        rails.bottles_taken = rails.bottles_taken + 1
        rails.source_of_first_alcohol = rails.source_of_first_alcohol or "storage_room"
        c.alcohol_crate:open()
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
        return not State.grids.solids[rails.entities.captain_door.position]
      end,

      run = function(self, rails, c)
        self.enabled = false
        rails.scenes.parasites_start.enabled = false

        rails.seen_water = true
        State.player.experience = experience.for_level[3]
        State:add(fx("assets/sprites/fx/mirage_spawn", "fx_under", State.player.position))
        sound("assets/sounds/level_up.mp3"):play()

        api.wait_seconds(8)
        api.notification("Разблокируй желтый рычаг на правой панели.", true)
        api.wait_seconds(3)
        api.update_quest({parasites = 2})
      end,
    },

    deck_fov_enter = {
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

    cauldron_after = {
      name = "Interacting with the cauldron at lunch",
      enabled = true,

      characters = {
        soup_cauldron = {},
        player = {},
        player_room_door = {},
        son_mary = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.soup_cauldron.interacted_by == c.player and rails.lunch_started
      end,

      _first_time = true,

      run = function(self, rails, c)
        c.soup_cauldron.interacted_by = nil

        if self._first_time then
          self._first_time = false
          api.narration("Несмотря на кошмарную обстановку вокруг, ароматное варево манит тебя, словно свет откровения.")
          api.narration("Ты был голодным и уставшим, но это поправимо.")
          api.narration("Миска ароматного супа затянет все раны — и душевные, и телесные.")
        end

        if api.options({
          "*Зачерпнуть полную тарелку*",
          "*Оставить трапезу на потом*",
        }) == 2 then
          api.narration("Желудок гудит на тебя, протестуя и обвиняя в предательстве.")
          api.narration("Может, он и прав — будет грустно умереть, пропустив такую трапезу.")
          return
        end

        api.narration("Ты зачерпываешь густой суп до самых краев; внутри тяжелой миски сплелись первое и второе, напиток и десерт.")
        api.line(c.player, "(Это место не походит на приятную трапезную)")
        api.line(c.player, "(Можно поесть побыстрее или найти более спокойную локацию)")

        local options_1 = {
          "*Быстро разобраться с едой*",
          "*Поесть в своей комнате*",
        }

        if rails.seen_water then
          options_1[3] = "*Поесть с видом на океан*"
        end

        local chosen_option_1 = api.options(options_1)

        if chosen_option_1 == 1 then
          api.narration("В конце концов, это всего лишь топливо.")
          api.narration("Ты опрокидываешь тарелку, заполняя рот порцией сочнейшего супа.")
          api.narration("Затем ещё, и ещё раз.")
          api.narration("И вот ты перед своим отражением — на самом дне миски.")
          api.line(c.player, "(Я начинаю привыкать к этой физиономии)")
        elseif chosen_option_1 == 2 then
          api.fade_out()
          level.move(c.player, rails.positions.player_room_eating)
          c.player_room_door:close()
          api.fade_in()

          api.narration("Здесь спокойнее, чем снаружи; тишину перебивает лишь негромкий храп.")
          api.narration("За приемом пищи в таких условиях не могут не прийти разные странные мысли.")
          api.narration("Зачем ты здесь?")
          api.narration("Как отсюда выбраться?")
          api.narration("Чей голос поселился в моей голове?")
          api.narration("Можно ли кому-то доверять?")
          api.narration("С каждой минутой вопросов становится всё больше, но это не может продолжаться вечно.")
          api.narration("В твоих силах дать ответ на большинство из них.")
          api.line(c.player, "(Как минимум вопрос с едой я закрыл)")
        else  -- chosen_option == 3
          api.fade_out()
          level.move(c.player, rails.positions.captain_deck_eating)
          rails.scenes.deck_fov_enter:run()
          c.player:rotate("up")
          api.center_camera()
          api.wait_seconds(1)
          api.fade_in()

          State.ambient:set_paused(true)
          local ambient = sound("assets/sounds/eating_at_bridge.mp3", .1):set_looping(true):play()

          api.narration("Усевшись в позе лотоса, поместив миску в свободное пространство между ног, ты уже несколько минут сосредоточенно всматриваешься в пространство за стеклом.")
          api.narration("Иногда ты вспоминаешь про изначальную цель, делаешь небольшой глоток супа...")
          api.narration("Лишь для того, чтобы вновь вернуться к просмотру завораживающей картины.")
          api.line(c.player, "(Такая тонкая граница между мной и миром)")
          api.line(c.player, "(Это же чертов спрессованный песок, почему мне не под силу его разбить?)")
          api.narration("И чего бы ты этим добился? Даже если бы смог добраться до водной глади...")
          api.narration("Одиночество посреди океана ничем не лучше твоей текущей участи.")
          api.line(c.player, "(Я ненавижу границы; чувствую себя быком, перед которым машут красной тряпкой)")
          api.line(c.player, "(Так глупо не уметь сопротивляться своей природе)")
          api.narration("А так ли нужно сопротивляться? Эта сила и делает тебя собой.")
          api.line(c.player, "Да к чёрту всё!")

          c.player:animate("main_hand_attack")
          sound("assets/sounds/hitting_window.mp3", .9):play()

          api.narration("Ты не старался, да? Сделал это просто от отчаянья?")
          api.narration("Ещё и суп разлил; впрочем, ты успел наесться.")
          api.narration("Из немого ступора тебя выводит крик.")
          api.line(c.son_mary, '<span color="e64e4b">КАКОГО ДЬЯВОЛА ТЫ ЗДЕСЬ ШУМИШЬ?</span>')
          api.narration("Отвечать не обязательно, у нас впереди много важных дел.")

          local options_2 = {
            [1] = "*Посидеть ещё немного*",
            [3] = "*Оставить это место*",
          }

          if rails.met_son_mary then
            options_2[2] = "*Поговорить с Сон Мари*"
          end

          ambient:stop()
          local chosen_option_2 = api.options(options_2)

          if chosen_option_2 == 1 then
            api.narration("Мир не исчезнет, если ты выделишь немного времени на отдых.")

            local heaven_ambient = sound("assets/sounds/heaven_ambient.mp3", .1):set_looping(true):play()
            api.fade_out()

            api.narration("Ты смыкаешь глаза, оставляешь кричащую голову на корабле...")
            api.narration("Погружаешься в далекое место, в мир, что остался лишь в твоей голове.")
            api.narration("Тут не холодно и не жарко, приятно пахнет, поют птицы.")
            api.narration("Не издают страшные кричащие звуки, нет — по-настоящему поют.")
            api.narration("По миру ходят гигантские фигуры, напоминающие ожившие горы; они никогда на тебя не наступят, не причинят вреда.")
            api.narration("И даже вода в случайной луже тут кристально прозрачная и на вкус как липовый мёд.")

            heaven_ambient:stop()
            sound("assets/sounds/eating_at_bridge_hate.mp3", .4):play()

            api.narration("Ты <hate>ненавидишь</hate> это место.")

            api.fade_in()

            api.narration("Ты просыпаешься в поту, с диким сердцебиением.")
            api.narration("Мир возвращает привычные холодные краски.")
            api.narration("Спёртый металлический  воздух, что ты бешено вдыхаешь — почему им так приятно дышать?")
            api.narration("Голова, видимо устав на тебя ругаться, смотрит куда-то в сторону входа.")
            api.line(c.player, "(Хорошо, что того мира больше нет)")
          elseif chosen_option_2 == 2 then
            api.line(c.player, "Выпустил пар.")
            api.line(c.player, "Ты не представляешь, как меня всё достало.")
            api.line(c.son_mary, "Дерьмовый день, да?")
            api.line(c.son_mary, "Иди прирежь кого-нибудь — всегда так делаю.")
            api.line(c.son_mary, "Ну, делал.")
            api.line(c.player, "Сейчас не в состоянии?")
            api.line(c.son_mary, "Пока. Не в состоянии.")
            api.line(c.son_mary, "История тут вспомнилась недавняя, лет 20 назад, кажется, было...")
            api.line(c.player, "Мне не интересно.")
            api.line(c.son_mary, "Послушай, тебе понравится.")
            api.line(c.son_mary, "Свадьба была у меня тогда; нашёл я одну весьма интересную особу.")
            api.line(c.son_mary, "Похитилась она как-то случайно в процессе одного из налётов.")
            api.line(c.son_mary, "Что-то было в ней такое, гхм, страшное.")
            api.line(c.son_mary, "Будто даже не боялась меня; изображала раболепие, но хи-и-итро так при этом поглядывала.")
            api.line(c.son_mary, "На корабле командовать стала ещё до свадьбы, меня это даже поначалу забавляло.")
            api.line(c.son_mary, "И как я только на эту чертову церемонию согласился... В мои года уже не поддаются на бабьи чары.")
            api.narration("Ты не можешь скрыть подобравшуюся ухмылку: таких сентиментов ты от мрачного пирата не ожидал.")
            api.line(c.son_mary, "Я выкинул её за борт сразу после свадьбы.")
            api.line(c.son_mary, "Только там этой мурене и место.")
            api.line(c.player, "И какова мораль этой басни?")
            api.line(c.son_mary, "Если кто-то пытается тобой водить — кидай его за борт.")
          else  -- chosen_option_2 == 3
            api.line(c.player, "Не буду перед тобой отчитываться. Я ухожу.")
            api.line(c.son_mary, "Наверное считаешь себя самым несчастным, брошенным всем миром вечным одиноким волком? К сожалению, не могу предложить успокаивающие объятия.")
            api.narration("Не отвечай, так будет казаться, что он сказал это самому себе.")
            api.line(c.player, "(О, да, ему лучше подходит)")
            api.narration("Но... Может он в чем-то прав? Раньше ты не был таким чувствительным. Слишком человечно для тебя.")
            api.line(c.player, "(Самое время перестать говорить с самим собой)")
          end
        end

        c.player:rest("long")
        State.ambient:set_paused(false)
        self.enabled = false
      end,
    },

    {
      name = "Dreamers discuss possessed",
      enabled = true,

      characters = {
        canteen_killer_1 = {},
        canteen_killer_2 = {},
        player = {},
      },

      start_predicate = function(self, rails, dt, c)
        local snapshot = tcod.snapshot()
        return (State.player.position - c.canteen_killer_1.position):abs() <= 5
          and snapshot:is_visible_unsafe(unpack(c.canteen_killer_1.position))
          and snapshot:is_visible_unsafe(unpack(c.canteen_killer_2.position))
      end,

      run = function(self, rails, c)
        self.enabled = false

        State.ambient:set_paused(true)
        local music = sound("assets/sounds/people_around_possessed_body.mp3", .3)
          :set_looping(true)
          :play()

        local killers_lines
        local canteen_killers = {c.canteen_killer_1, c.canteen_killer_2}
        local did_player_kill_possessed = State:exists(rails.entities.canteen_killer_3)
        if did_player_kill_possessed then
          table.insert(canteen_killers, rails.entities.canteen_killer_3)
          killers_lines = {
            "он мертв",
            "похоже, мертв",
            "труп",
            "умер мужик",
            "тут много крови",
            "он не живой",
          }
        else
          killers_lines = {
            "убит",
            "справились",
            "одного потеряли",
            "устранён",
            "я не ранен",
            "угрозы более не представляет",
          }
        end

        local talk_task = rails:run_task(function()
          for i, line in ipairs(killers_lines) do
            api.message.temporal(
              line, {source = canteen_killers[Math.loopmod(i, #canteen_killers)]}
            )
            api.wait_seconds(3.5)
          end
        end)

        if did_player_kill_possessed then
          api.narration("Несколько спящих столпились вокруг трупа, который ты ранее здесь оставил.")
          api.narration("В их лицах ни удивления, ни скорби, ни попыток как-то разобраться в ситуации.")
          api.narration("Они лишь бормочут очевидные истины.")
        elseif api.ability_check("investigation", 12) then
          api.narration("Недавно здесь прошёл бой; кто-то атаковал спящих, а им пришлось защищаться.", {check = {"investigation", true}})
          api.narration("Приглядевшись к кровавой бане, ты разглядываешь забитого нападавшего и предполагаемую жертву, которой голыми руками содрали лицо.")
          api.narration("Ранее, проходя мимо комнаты, ты видел странную фигуру.")
          api.narration("На месте жертвы легко мог оказаться ты.")
        else
          api.narration("Здесь произошло нечто вне рамок твоего понимания.", {check = {"investigation", false}})
          api.narration("Двое спящих стоят посреди кровавой бани и что-то бормочут под нос.")
          api.narration("Их кулаки покрыты кровью — вероятно, это они устроили побоище.")
        end

        rails:run_task(function()
          while
            rails:is_running(talk_task)
            and (State.player.position - c.canteen_killer_1.position):abs() <= 15
          do
            coroutine.yield()
          end
          music:set_looping(false)
          while music.source:isPlaying() do coroutine.yield() end
          State.ambient:set_paused(false)
        end)
      end,
    },

    {
      name = "Noticing flask dreamer",
      enabled = true,

      characters = {
        canteen_dreamer_flask = {},
        player = {},
      },

      start_predicate = function(self, rails, dt, c)
        return (c.canteen_dreamer_flask.position - c.player.position):abs() <= 3
          and tcod.snapshot():is_visible_unsafe(unpack(c.canteen_dreamer_flask.position))
      end,

      run = function(self, rails, c)
        self.enabled = false

        if not rails.flask_noticed and not api.ability_check("perception", 12) then
          return
        end

        api.narration("Из заднего кармана рабочего торчит металлическая фляга, на ней гравировка: “Первый глоток для здоровья, второй для веселья...”. Продолжение не разглядеть.", {check = {"perception", true}})
      end,
    },

    {
      name = "Stealing the flask",
      enabled = true,

      characters = {
        canteen_dreamer_flask = {},
        player = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.canteen_dreamer_flask.interacted_by == c.player
          and api.get_quest("alcohol") > 0
      end,

      _options = {
        "[Ловкость рук] *Украсть фляжку*",
        "Эй, обернись.",
      },

      _disadvantage = false,

      run = function(self, rails, c)
        c.canteen_dreamer_flask.interacted_by = nil

        api.narration("Нужная тебе фляга здесь, в заднем кармане рабочего, только протяни руку.")
        api.narration("Но ведь это... Воровство?")
        api.narration("Может есть другой способ?")

        self._options[99] = "*Уйти*"

        while true do
          local chosen_option = api.options(self._options, true)

          if chosen_option == 1 then
            if
              api.ability_check("sleight_of_hand", 14)
              and (not self._disadvantage or api.ability_check("sleight_of_hand", 14))
            then
              api.narration("Ты крадёшь, нет, аккуратно изымаешь фляжку из заднего кармана.", {check = {"sleight_of_hand", true}})
              api.narration("Рабочий не замечает, как в твоих руках оказывается фляжка с выгравированной надписью.")
              api.narration("“Первый глоток для здоровья, второй для веселья, третий для одуренья”")
              self:_good_ending(rails, c)
            else
              api.narration("Ты не вор.", {check = {"sleight_of_hand", false}})
              api.narration("Воровать постыдно и низко.")
              api.narration("А ты просто берёшь, что тебе позволено.")
              api.narration("С этой мыслью, ты вытягиваешь флягу из штанов рабочего.")
              api.narration("Он оборачивается, видит флягу в твоих руках.")
              api.line(c.canteen_dreamer_flask, "Убью...")
              self:_bad_ending(rails, c)
            end
            self.enabled = false
            break

          elseif chosen_option == 2 then
            self._disadvantage = true
            api.narration("Рабочий послушно оборачивается, его пустые глаза смотрят сквозь тебя.")
            api.line(c.canteen_dreamer_flask, "Да-а, я слушаю.")

            if api.options({
              "Можешь передать мне фляжку?",
              "Алкоголь запрещён. Отдавай флягу.",
            }) == 1 then
              api.narration("Рабочий вздрагивает, будто ты попросил что-то неприличное.")
              api.narration("Он достаёт флягу из кармана, но не передаёт её, только крепко сжимает в руках.")
              sound("assets/sounds/manipulating_flask_dreamer.mp3", .1):play()
              api.line(c.canteen_dreamer_flask, "Но ведь... Это моё...")
              api.line(c.canteen_dreamer_flask, "Не отдам моё...")
              api.narration("Он дрожит, как забитый зверь.")
              api.narration("Пока не поздно отступить.")

              if api.options({
                "[Убеждение] *убедить его отдать фляжку*",
                "Конечно твоё! Оставь себе, я уже ухожу.",
              }) == 2 then
                api.line(c.canteen_dreamer_flask, "Да. Моё. Любимое.")
                break
              end

              if api.ability_check("persuasion", 12) then
                api.narration("Он очень крепко держится за эту вещь. Она словно его часть.", {check = {"persuasion", true}})
                api.narration("Нужные слова находятся сами собой.")
                api.line(c.player, "Ценные вещи могут потеряться во время работы, я положу её в надежное место.")
                api.line(c.player, "У меня она будет в целости и сохранности, обещаю.")
                api.narration("Ты видишь, как он расслабляется; понимает, что ты лишь хочешь ему помочь.")
                api.line(c.canteen_dreamer_flask, "Пожалуйста, только не повредите.")
                api.narration("Фляжка у тебя, и без всякого воровства.")
                api.narration("Может быть, ты даже её вернёшь.")
                self:_good_ending(rails, c)
              else
                api.narration("Засмотрит грустными глазами до смерти?", {check = {"persuasion", false}})
                api.narration("И что он сделает, если ты просто её заберёшь?")
                api.narration("Ты без церемоний тянешься к фляге.")
                api.line(c.canteen_dreamer_flask, "НЕЕТ! МОЁ! ЭТО МОЁ!")
                self:_bad_ending(rails, c)
              end

            else  -- 22
              api.narration("Рабочий вздрагивает, будто ты попросил что-то неприличное.")
              api.narration("Он достаёт флягу из кармана, но не передаёт её, только крепко сжимает в руках")
              sound("assets/sounds/manipulating_flask_dreamer.mp3", .1):play()
              api.line(c.canteen_dreamer_flask, "Но ведь... Это моё...")
              api.line(c.canteen_dreamer_flask, "Не отдам моё...")
              api.narration("Он дрожит, как забитый зверь.")
              api.narration("Пока не поздно отступить.")

              if api.options({
                "[Расследование] *Придумать как изъять алкоголь*",
                "Конечно твоё! Оставь себе, я уже ухожу."
              }) == 2 then
                api.line(c.canteen_dreamer_flask, "Да. Моё. Любимое.")
                break
              end

              if api.ability_check("investigation", 12) then
                api.narration("Он очень крепко держится за эту вещь. Она словно его часть.", {check = {"investigation", true}})
                api.narration("Нужные слова находятся сами собой.")
                api.narration("Как и подходящая ёмкость под одним из столов.")
                api.line(c.player, "Тогда выливай всё содержимое в эту бутылку, её я изыму.")
                api.line(c.player, "Флягу оставишь себе.")
                api.line(c.canteen_dreamer_flask, "Конечно, конечно! Сейчас.")
                api.narration("Рабочий сразу расслабляется, понимая, что фляга останется при нём.")
                api.narration("Он выливает жидкость до последней капли.")
                api.narration("Она пахнет дубом, можжевеловыми ягодами и жжёным сахаром.")
                api.narration("И даже не пришлось воровать.")
                self:_good_ending(rails, c)
              else
                api.narration("И что он сделает, если ты просто её заберёшь?", {check = {"investigation", false}})
                api.narration("Засмотрит грустными глазами до смерти?")
                api.narration("Ты без церемоний тянешься к фляге.")
                api.line(c.canteen_dreamer_flask, "НЕЕТ! МОЁ! ЭТО МОЁ!")
                self:_bad_ending(rails, c)
              end
            end
            break

          else  -- chosen_option_1 == 3
            break
          end
        end
      end,

      _bad_ending = function(self, rails, c)
        hostility.make_hostile(c.canteen_dreamer_flask.faction)
        self.enabled = false
        c.canteen_dreamer_flask.interact = nil
      end,

      _good_ending = function(self, rails, c)
        State:remove(c.canteen_dreamer_flask.inventory.right_pocket)
        c.canteen_dreamer_flask.inventory.right_pocket = nil
        rails.bottles_taken = rails.bottles_taken + 1
        rails.source_of_first_alcohol = rails.source_of_first_alcohol or "flask"
        self.enabled = false
        c.canteen_dreamer_flask.interact = nil
      end,
    },

    {
      name = "Captain deck message",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return (State.player.position - rails.positions.captain_deck_message):abs() <= 1
      end,

      run = function(self, rails)
        self.enabled = false
        api.ability_check_message("history", 12,
          "Выгравированная надпись на незнакомом языке, в символах угадывается известный афоризм. Буквальный перевод — “Голова над всем телом”.",
          "Выгравированную надпись невозможно прочитать — грязь не смывали несколько десятков лет."
        )
      end,
    },

    {
      name = "Parasites message",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return (State.player.position - rails.positions.parasites_message):abs() <= 2
      end,

      run = function(self, rails)
        self.enabled = false
        api.ability_check_message("investigation", 10,
          "Табличка: “Опасно! Риск нападения паразитов! Не приближаться!”\nОна висит здесь очень давно. Неужели проблема настолько серьезная?",
          "Табличка: “Опасно! Риск нападения паразитов! Не приближаться!”"
        )
      end,
    },

    {
      name = "Storage room message",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return (State.player.position - rails.positions.storage_room_message):abs() <= 2
      end,

      run = function(self, rails)
        self.enabled = false

        api.message.positional("Яркая надпись маркером у двери: “Произведение допуска к кладовой осуществляется только доверенному персоналу”. Не очень осмысленно.", {source = {position = rails.positions.storage_room_message}})
      end,
    },

    {
      name = "Looting storage container #1",
      enabled = true,

      characters = {
        storage_container_1 = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.storage_container_1.interacted_by == State.player
      end,

      run = function(self, rails, c)
        self.enabled = false

        c.storage_container_1:open()
        api.message.temporal(
          "Ящик наполнен сотнями комплектов постельного белья. Оно постирано и выглажено, но всё равно кажется липким.",
          {source = c.storage_container_1}
        )
      end,
    },

    {
      name = "Looting storage container #2",
      enabled = true,

      characters = {
        storage_container_2 = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.storage_container_2.interacted_by == State.player
      end,

      run = function(self, rails, c)
        self.enabled = false

        c.storage_container_2:open()
        api.message.temporal(
          "Несколько красочных жестяных банок от известных кондитерских брендов. За каждой закреплен ярлык: соль, перец, сахар, лимонная кислота.",
          {source = c.storage_container_2}
        )
      end,
    },

    {
      name = "Looting storage container #3",
      enabled = true,

      characters = {
        storage_container_3 = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.storage_container_3.interacted_by == State.player
      end,

      run = function(self, rails, c)
        self.enabled = false

        c.storage_container_3:open()
        api.message.temporal(
          "В ящике стопка старых газет, видимо, для хозяйственных нужд.",
          {source = c.storage_container_3}
        )
      end,
    },

    {
      name = "Coal message",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return (State.player.position - rails.positions.coal_message_y):abs() <= 3
          and State.player.position[2] == rails.positions.coal_message_y[2]
      end,

      run = function(self, rails)
        self.enabled = false
        api.message.positional(
          "Груда спрессованного угля впитывает любой случайный лучик света. Расплавится ли пол, если её зажечь целиком?",
          {source = {position = rails.positions.coal_message_source}}
        )
      end,
    },

    {
      name = "Engine energy damage",
      enabled = true,

      _activation_period = {},
      start_predicate = function(self, rails, dt)
        return State.player.position >= rails.positions.engine_damage_start
          and State.player.position <= rails.positions.engine_damage_finish
          and Common.relative_period(6, dt, self._activation_period)
      end,

      run = function(self, rails)
        if api.saving_throw("con", 15) then return end
        health.damage(State.player, 1)
      end,
    },

    {
      name = "Looking at the engine",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position >= rails.positions.engine_message_start
          and State.player.position <= rails.positions.engine_message_finish
      end,

      run = function(self, rails)
        self.enabled = false

        api.ability_check_message("history", 16,
          "Такие монструозные двигатели никогда не имели серийного производства, а из-за сложности повторной сборки их не могли перевозить. Это помещение было костяком, поверх которого построили все остальные.",
          "Рычащая машина напоминает космическое чудовище, переваривающее молодую, едва родившуюся звезду. Это... завораживает."
        )
      end,
    },

    {
      name = "Attacking the engine",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return Fun.iter(State._aggression_log)
          :any(function(pair) return pair[1] == State.player and pair[2].engine_flag end)
      end,

      run = function(self, rails)
        self.enabled = false

        api.message.temporal("Пытаться его сломать бессмысленно; против такого монстра и оружие должно быть соответствующее.")
      end,
    },

    {
      name = "Interacting w/ guys in protective robes",
      enabled = true,

      characters = {
        protected_1 = {},
        protected_2 = {},
        protected_3 = {},
        player = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.protected_1.interacted_by == c.player
          or c.protected_2.interacted_by == c.player
          or c.protected_3.interacted_by == c.player
      end,

      run = function(self, rails, c)
        self.enabled = false

        api.narration("Одетые в полноразмерные защитные костюмы фигуры не реагируют на попытки привлечь внимание.")
        api.narration("Сквозь защитные стёкла не видно глаз; вероятно, твои они тоже не увидят.")
      end,
    },

    {
      name = "Looting money",
      enabled = true,

      _container_indexes = Fun.range(10):totable(),
      _current_active_container_i = nil,
      _first_time = true,
      _steals = false,

      start_predicate = function(self, rails, dt)
        if not self._containers then
          self._containers = Fun.range(10)
            :map(function(i) return  end)
            :totable()
        end

        self._current_active_container_i = Fun.iter(self._container_indexes)
          :filter(function(i)
            return rails.entities["loot_container_" .. i].interacted_by == State.player
          end)
          :nth(1)

        return self._current_active_container_i
      end,

      _contents = {
        {10, "Под слоями трухлявой одежды лежит несколько старых необналиченных зарплатных выписок; сумма за 10 месяцев работы не вызывает ничего, кроме смеха."},
        {80, "Развернув тонкий пергамент, ты находишь золотой кулон; внутри него истлевшая фотография и  гравировка: “Любимой жене и матери, возвращайся скорее”."},
        {120, "В глиняной миске лежит множество ржавых монет неопределенного происхождения и номинала, некоторые неплохо сохранились; с большой серебряной монеты на тебя глазеет морда странного клоуна."},
        {200, "Среди пустых бутылок премиального алкоголя лежит красочное издание в нераспакованной подарочной упаковке — “Житие святого Кайдена: Последний Император”."},
        {250, "На дня сундука спрятался кошелёк с фотографией дварфа в форме Экс-Адмирала — внутри стопка увесистых купюр с портретами Святых; 20 лет назад это было целое состояние."},
        {40, "Один из ящиков не закрывается полностью; за его задней стенкой ты находишь серебряные запонки дварфийской работы."},
        {70, "В газету завернуто золотое ожерелье; на местах, предназначенных для драгоценных камней зияет пустота: остался лишь один - агат."},
        {120, "Полусгнившая верхняя стенка при малейшем касании проваливается вглубь ящика, высвобождая на свет витиеватые амулеты, компактные жезлы и наборы рунных колец; тем у кого нет таланта — они не помощники."},
        {60, "Среди груд повседневной одежды сверкает платиновая ключница; на ней с десяток разнообразных ключей: здесь и кривой амбарный, и маленький почтовый, даже автомобильный — с солидной букой К в основании; тебе никогда не найти, что они открывают."},
        {50, "В шкафчике в неразобранном виде лежат декады бронзовых пластин с гравировкой ДВБ; в любой точке мира их можно обменять на еду и ночлег."},
      },

      run = function(self, rails)
        Table.remove(self._container_indexes, self._current_active_container_i)
        local container = rails.entities["loot_container_" .. self._current_active_container_i]
        local money, line = unpack(self._contents[self._current_active_container_i])

        if self._first_time then
          self._first_time = false

          api.narration(line)

          self._steals = api.options({
            "(Может пригодиться.)",
            "(Я не буду брать чужое.)",
          }) == 1

          if self._steals then
            api.line(State.player, "(Не похоже, что это сейчас кому-то нужно)")
            api.narration("Стоит чаще смотреть по сторонам, везде может быть нечто ценное.")
          else
            api.line(State.player, "(Я не вор.)")
            api.narration("Может быть, если не будет монетки на черный день — не будет и чёрного дня.")
          end
        else
          api.message.temporal(line, {source = container})
        end

        container:open()

        if self._steals then
          rails.money = rails.money + money
          sound("assets/sounds/picking_up_loot.mp3", .8):play()
        end
      end,
    },
  }
end
