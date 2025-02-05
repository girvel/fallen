local interactive = require("tech.interactive")
local actions = require("mech.creature.actions")
local level = require("tech.level")
local quest = require("tech.quest")
local sound = require("tech.sound")
local api = require("tech.railing.api")
local shaders = require("tech.shaders")


return function()
  return {
    son_mary_curses = {
      name = "Son Mary curses",
      enabled = true,

      characters = {
        son_mary = {},
      },

      popup = {},
      _first_time = true,

      start_predicate = function(self, rails, dt, c)
        return not State:exists(self.popup[1])
          and not rails:is_running("son_mary_meeting")
          and (c.son_mary.position - State.player.position):abs() <= 3
          and api.get_quest("alcohol") == 0
      end,

      run = function(self, rails, c)
        self.popup = api.message.positional(
          self._first_time
            and "Грёбаный ублюдок"
            or "Тупица",
          {source = c.son_mary}
        )
        self._first_time = false
      end,
    },

    son_mary_meeting = {
      name = "Son Mary: meeting",
      enabled = true,

      characters = {
        son_mary = {},
        player = {}
      },

      start_predicate = function(self, rails, dt, c)
        return c.son_mary.interacted_by == c.player
          and api.get_quest("alcohol") == 0
      end,

      _first_time = true,

      run = function(self, rails, c)
        c.son_mary.interacted_by = nil
        State:remove_multiple(rails.scenes.son_mary_curses.popup)

        if self._first_time then
          self._first_time = false

          api.narration("К эпицентру комнаты сходятся десятки труб, сплетаясь вокруг гранитного постамента.")
          api.narration("На его вершине закреплена стеклянная структура, напоминающая аквариум из коллекции серийного убийцы.")
          api.narration("Это круглая конусообразная колба с отвратительной головой внутри.")
          api.narration("В этом странном машинном организме голова кажется сердцем, качающим кровь.")

          if api.ability_check("medicine", 8) then
            api.narration("Нет, не сердцем. Мозгом, к которому сходятся сосуды; управляющим органом.", {check = {"medicine", true}})
          else
            api.narration("Сердце в форме головы, такое не каждый день встретишь.", {check = {"medicine", false}})
          end

          api.narration("Взгяд бородатой физиономии выражает нескрываемую ненависть.")
          api.narration("Не к тебе одному — ко всему свету.")
          api.narration("Но его грубые слова посвящались непосредственно тебе, в помещении лишь ты и он.")
          api.narration("Вы смотрите друг на друга уже несколько секунд; кто-то должен начать разговор первым.")
        end

        local chosen_option = api.options({
          "Ты это мне сказал?",
          "Советую выбирать выражения",
          "А ты голова в банке с солёной водой",
          "*Уйти, ты выше этого*",
        })

        if chosen_option == 4 then
          api.line(c.son_mary, "Иди-иди по своим собачьим делам.")
          api.line(c.son_mary, "Сучье семя.")
          return
        end

        self.enabled = false
        rails.scenes.son_mary_curses.enabled = false
        rails.scenes.markiss:activate_option(5)
        rails.met_son_mary = true

        if chosen_option == 1 then
          api.line(c.son_mary, "У тебя проблемы со слухом? Могу повторить.")
          api.line(c.player, "Я никому не позволю так с собой разговаривать.")
          api.line(c.son_mary, "Правда? Хм...")
        elseif chosen_option == 2 then
          api.line(c.son_mary, "И что ты мне сделаешь, безвольная тварь?")
          api.line(c.player, "Разобью твою грёбаную банку и размажу по полу твою мерзкую рожу.")
          api.narration("Голова резко хмурится, будто пытаясь собрать все части лица в одну точку...")
          api.narration("И в следующую секунду расплывается в пугающей улыбке.")
        else  -- chosen_option == 3
          api.line(c.son_mary, "Не знал, что четвероногие способны на наблюдения")
          api.line(c.player, "Где-то я тебя видел... Вспомнил!")
          api.line(c.player, "Ты из тех маринованных голов, что продают шарлатаны на рынках")
          api.line(c.player, "И что же тобой лечат? Импотенцию? Цирроз?")
          api.line(c.son_mary, "И даже пытается шутить, хм...")
        end

        api.line(c.son_mary, "Знай, я никогда не беру слова назад")
        api.line(c.son_mary, "Обращался я не к тебе, а к безвольным, что ходят вокруг; за одного из них тебя принял")
        api.line(c.son_mary, "Они хуже рабов — рабы хотя бы мечтают о свободе. Или собственных рабах.")
        api.line(c.son_mary, "А ты... Это мы сейчас и проверим")

        api.narration("Он пристально смотрит на тебя, в момент ты теряешь дар речи.")
        sound.play("assets/sounds/son_mary_spell.mp3", .8)
        api.narration("Он шепчет слова на мёртвом языке; твои мысли, память, душа вмиг обнажаются пред его взором.")

        if api.saving_throw("wis", 18) then
          -- TODO shader here
          api.line(c.player, "<hate>НЕТ</hate>")
          api.line(c.player, "<hate>ЭТО МОЯ ГОЛОВА</hate>")
          api.line(c.player, "<hate>ПРОЧЬ</hate>")
          -- TODO end shader here
          api.narration("Невероятным усилием воли ты обрываешь эту связь.")
          api.narration("Душа теперь твоя. И только твоя.")
          State.shader = nil
          api.line(c.son_mary, "Всё равно я успел узнать всё, что мне нужно")
          rails.resists_son_mary = true
        else
          State.shader = shaders.charmed({
            rails.entities.son_mary,
            rails.entities.son_mary_upper,
            State.grids.solids[rails.entities.son_mary.position],
          })

          local heartbeat = sound("assets/sounds/heartbeat.mp3", 1)
          heartbeat.source:setLooping(true)
          heartbeat:play()

          api.narration("Он слишком силён, ты можешь лишь терпеть, пока он копается в твоей голове.")
          api.narration("Ощущение, будто расковыряли давно зажившую рану.")
          api.narration("Оно заканчится не скоро.")
          api.narration("——————")
          api.narration("————")
          api.narration("—————")
          api.narration("Больно.")
          api.narration("————")
          api.narration("———————")
          api.narration("——————")
          api.narration("Оно не может длиться вечно, терпи.")
          api.narration("————————————")
          api.narration("———————")
          api.narration("——————")
          api.narration("—")
          heartbeat.source:stop()
          api.narration("Он отпускает тебя.")
          State.shader = nil
          api.narration("Пообещай, что больше это не повторится.")
        end

        api.line(c.player, '<span color="e64e4b">Я.</span> ')
        api.line(c.player, '<span color="e64e4b">Я.</span> <span color="e64e4b">Убью.</span> ')
        api.line(c.player, '<span color="e64e4b">Я.</span> <span color="e64e4b">Убью.</span> <span color="e64e4b">Тебя.</span> ')
        api.line(c.son_mary, "Знал бы ты, как часто я это слышу")
        api.narration("Он разряжается отвратительным булькающим хохотом.")
        api.narration("Тебя переполняет желание прикончить эту тварь, но его не получается собрать в импульс — в действие.")
        api.narration("В твоей голове будто установили сито, что просеивает любые попытки причинить ему вред.")
        api.narration("Твой максимум — бездействие.")
        api.line(c.player, "Рано или поздно я придумаю как тебя убить...")
        api.line(c.son_mary, "Пока мы здесь — у тебя не получится.")
        api.line(c.son_mary, "А когда закончим маршрут — меня на столетия запрут там, где никто не достанет.")
        api.line(c.son_mary, "Хотя какие столетия, скорее всего — навсегда...")
        api.line(c.player, "И к чему ты клонишь? Говори!")

        api.notification("Прекрати с ним болтать, у тебя есть задание", true)
        api.wait_seconds(2)

        api.narration("Голова поворачивается в сторону выхода из рубки.")
        api.line(c.son_mary, "Очень хочется промочить горло. Достань мне ром. Или ещё какую крепкую дрянь.")
        api.line(c.son_mary, "Хороший градус прочищает разум")

        if
          api.ability_check("insight", 13)
          or rails.resists_son_mary and api.ability_check("insight", 13)
        then
          api.line(c.player, "(Он тоже слышит голос. Хочет сказать больше, но не может)", {check = {"insight", true}})
        else
          api.line(c.player, "(Почему он обернулся? Может, увидел кого?)", {check = {"insight", false}})
        end

        chosen_option = api.options({
          "*Молча уйти*",
          "Хорошо, будет по твоему",
          "Я не собираюсь играть по твоим правилам",
        })

        if chosen_option == 1 then
          api.narration("Ты никогда не убегал от своих проблем,")
          api.narration("Так что это не побег.")
          api.narration("Всего лишь временное отступление.")
          api.line(c.son_mary, "Беги-беги крошка-букашка, всё равно вернёшься")
          api.line(c.son_mary, "И не забудь мою просьбу")
        elseif chosen_option == 2 then
          api.line(c.player, "(Сам себе не верю, когда говорю такое)")
          api.line(c.son_mary, "Я буду ждать.")
          api.line(c.player, "(Жди кусок дерьма, ты ещё за всё заплатишь)")
          api.line(c.player, "Скоро вернусь, не скучай.")
          api.line(c.son_mary, "В моем возрасте атрофируется способность скучать; можешь не торопиться.")
          api.line(c.player, "Старый мерзкий кусок дерьма.")
          api.line(c.player, "(Да, я определенно сказал это вслух)")
          api.line(c.son_mary, "Обнищал я; раньше тянул на целую кучу.")
          api.line(c.son_mary, "Исполнишь просьбу — расскажу насколько большую.")
          api.line(c.player, "(Я правда собираюсь втягиваться в эту авантюру?)")
          api.line(c.player, "Постарайся не забыть, пока ждёшь.")
        else
          api.line(c.son_mary, "Предпочитаешь играть по его пр...")
          api.narration("Он вздрагивает, как от удара током, затем прищуривается.")
          api.narration("Дальнейшие слова произносит медленно, подбирая каждую букву.")
          api.line(c.son_mary, "Действуй как хочешь, свободный человек.")
          api.line(c.son_mary, "Но не забывай о возможности, что я тебе предложил.")
          api.narration("Он закрывает глаза и переходит в состояние глубокого транса.")
          api.narration("Что он сейчас наблюдает? Серые коридоры, по которым ты шагал несколько минут назад?")
          api.narration("Или кошмарные сны о подводных чудовищах?")
          api.narration("Ты очень хочешь разбить эту чертову банку, погрузить её обитателя в вечный сон.")
          api.narration("Настанет момент, когда у тебя получится.")
        end

        api.update_quest({alcohol = 1})
        State:refresh(rails.entities.canteen_dreamer_flask, interactive.detector())
        rails.scenes.markiss:activate_option(6)
        rails:run_task(function()
          api.wait_seconds(5)
          api.notification("Не слушай его, займись делом.", true)
        end)
      end,
    },

    {
      name = "Son Mary: first alcohol",
      enabled = true,

      characters = {
        son_mary = {},
        player = {},
      },

      start_predicate = function(self, rails, dt, c)
        return api.get_quest("alcohol") == 1
          and c.son_mary.interacted_by == State.player
      end,

      _next_piss_off_line = 1,
      _seen_intro = false,

      run = function(self, rails, c)
        c.son_mary.interacted_by = nil

        if rails.bottles_taken == 0 then
          local LINES = {
            "Нет алкоголя — нет разговора",
            "Неужели так тяжело что-то найти?",
            "Руки-ноги на месте, так используй их по назначению",
          }

          if self._next_piss_off_line > #LINES then return end

          api.line(c.son_mary, LINES[self._next_piss_off_line])
          self._next_piss_off_line = self._next_piss_off_line + 1
          return
        end

        if not self._seen_intro then
          self._seen_intro = true
          api.narration("Пиратская морда смотрит на сосуд в твоих руках.")
          api.narration("Тебя раздирает желание вылить его содержимое на пол.")
          api.narration("Но вряд ли ты это пойдёт тебе на пользу.")
          api.notification("Ты чувствуешь, что капитан — ублюдок и убийца.", true)
          api.narration("Подобное ребячество не в твоей природе, не в твоём духе.")
          api.notification("Ты не хочешь с ним связываться.", true)
          api.line(c.player, "Я не ослышался? Капитан?")
          api.line(c.son_mary, "...ублюдок и убийца, заливай быстрее.")
        end

        if api.options({
          "*Залить напиток Капитану*",
          "*Уйти*",
        }) == 2 then
          api.narration("Может, внутренний голос прав?")
          api.line(c.player, "Что-то здесь не так, я не буду исполнять твои приказы.")
          api.line(c.son_mary, "Падаль! Идиот! Возвращайся когда отрастишь себе что-то на месте мозгов.")
          return
        end

        rails.bottles_taken = rails.bottles_taken - 1
        api.narration("Одна из труб примечательна; её дальний конец присоединен к центральной системе, а ближайший закрыт клапаном.")
        api.narration("Несомненно, это то, что тебе нужно; ты вскрываешь клапан и заливаешь напиток.")
        -- TODO FX music, animation
        api.narration("Жидкость медленно вливается в один из промежуточных сосудов.")
        api.narration("Она начинает быстро распространяться по всем трубам, будто моровое поветрие.")
        api.narration("Вода в центральном сосуде приобретает мутный цвет, пузырьки вокруг головы вихрятся в пьяном танце.")
        api.narration("Капитан в это время широко открывает рот, словно кит, пожирающий планктон.")
        -- TODO FX spawn steam
        api.narration("Внезапно усилившееся давление пробивает множество клапанов, мир вокруг захватывает тряска и жар.")
        api.narration("Кажется вот-вот здесь всё взлетит на воздух — пора бежать.")
        -- TODO FX disable music
        api.line(c.son_mary, "ОТСТАВИТЬ БУНТ!")
        api.narration("Вмиг вся система затихает, приходит в порядок.")
        api.line(c.son_mary, "Хо-ро-шо. Теперь всё под контролем, наконец-то.")
        api.line(c.son_mary, "Осталось последнее дело.")
        api.line(c.son_mary, "Раздобудь-ка ещё пойла, и мы сможем наконец обсудить наш план.")
        api.line(c.player, "Какого черта? Ещё?!")
        api.line(c.son_mary, "Не останавливаться же на полпути, а?")
        api.narration("Он тебе... Подмигнул?")

        if
          api.ability_check("insight", 12)
          or rails.resists_son_mary and api.ability_check("insight", 12)
        then
          api.narration("Во взгляде заговорческий план, и он не видит его исполнение без тебя.", {check = {"insight", true}})
        else
          api.narration("Подобная неподконтрольная мимика — явный признак алкогольной интоксикации.", {check = {"insight", false}})
        end

        local options = {
          "Хорошо, найду, но это последняя подобная просьба.",
          "Где я тебе ещё найду? Этот-то раздобыл с великим трудом",
          "Это перебор, больше ты от меня ничего не добьёшься",
          "*Молча уйти, хватит с тебя этого дерьма*",
        }

        if rails.bottles_taken > 0 then
          options[6] = "*Молча показать вторую бутылку*"
        end

        while true do
          local chosen_option = api.options(options, true)
          if chosen_option ~= 4 and options[4] then
            options[4] = nil
            options[5] = "*Уйти*"
          end

          if chosen_option == 1 then
            api.line(c.son_mary, "Ты не пожалеешь о своем выборе")
            if options[3] then
              api.line(c.son_mary, "И,.. Благодарю, что не стал спорить. Это важная часть плана.")
              api.narration("Он произнёс слова благодарности так странно, непривычно.")
              api.line(c.player, "Твоё первое в жизни спасибо?")
              api.line(c.son_mary, "Когда окружают идиоты, на вежливость времени не остаётся.")
              api.line(c.son_mary, "Не заставляй меня брать слова назад")
            else
              api.line(c.son_mary, "Я ведь видел твоё сердце, почуял что рабство для тебя худшее из зол.")
              api.line(c.player, "Заткнись.")
              api.line(c.son_mary, "Раз увидел правду, уже не сможешь смотреть на иллюзию как раньше. Так и с рабством, парень.")
              api.line(c.player, "Замолчи, я уже жалею, что согласился.")
            end
            break

          elseif chosen_option == 2 then
            if rails.source_of_first_alcohol == "storage_room" then
              api.line(c.son_mary, "Хм, если не боишься ослепнуть, поищи спирт в медотсеке; это недалеко — в правом блоке")
            else
              api.line(c.son_mary, "Хм, может в одной из кладовых что завалялось?")
              api.line(c.son_mary, "Странно, что ты принёс мне чертов спирт, но там не проверил.")
            end
            api.line(c.son_mary, "В любом случае, для тебя не будет ничего сложного.")

          elseif chosen_option == 3 then
            api.notification("Ты чувствуешь облегчение от правильного решения.", true)
            api.line(c.son_mary, "Держу пари, за такое решение хозяин погладит тебя по головке, а может даже насыпет корма больше обычного")
            api.line(c.player, "Заткнись. У меня нет никакого хозяина.")
            api.narration("Вмиг его лицо теряет привычную ухмылку. Становится нейтральным, почти пустым.")
            -- TODO FX music
            api.line(c.son_mary, "Знаешь, ведь некоторым нравится быть рабом.")
            api.line(c.son_mary, "Не нужно принимать сложных решений. Никакой ответственности.")
            api.line(c.son_mary, "Жизнь по расписанию снижает стресс, а похвала хозяина...")
            api.line(c.son_mary, " — поверь мне, для раба это высшее наслаждение; ни один свободный не сможет испытать подобное.")
            -- TODO FX creepy picture
            api.line(c.son_mary, "Так приятно слышать, что")
            api.line(c.son_mary, 'Так приятно слышать, что <span color="e64e4b">задание</span>')
            api.line(c.son_mary, 'Так приятно слышать, что <span color="e64e4b">задание</span> <span color="e64e4b">выполнено</span>')
            api.line(c.son_mary, 'Так приятно слышать, что <span color="e64e4b">задание</span> <span color="e64e4b">выполнено</span> <span color="e64e4b">успешно</span>')
            api.line(c.son_mary, "А может, тебе нравится определённость? Когда на место работы указывают пальцем?")
            api.line(c.son_mary, "Когда всё разжуют и преподнесут в формальном виде: кто враг, кто друг; где зло, а где добро.")
            api.line(c.son_mary, "Я знаю, как выглядит последняя стадия такого существования.")
            api.line(c.son_mary, "Ты будешь ЧУВСТВОВАТЬ только по приказу.")
            -- TODO FX creepy picture off
            api.line(c.son_mary, "Выбор за тобой, парень.")
            api.line(c.son_mary, "Выбор за тобой.")

          elseif chosen_option == 4 then
            c.player:rotate("down")
            c.player:act(actions.move)
            api.narration("Когда ты делаешь несколько шагов, в голове доносится шёпот капитана.")
            api.line(c.son_mary, "Хорошо, будь по-твоему, манипулятор, есть один способ.")
            api.line(c.son_mary, "Он тебе очень понравится.")

            if api.options({
              "Делай что должен.",
              "Больше ты в мою голову не залезешь",
            }) == 2 then
              api.line(c.son_mary, "Тогда я буду ждать.")
              break
            end

            c.player:rotate("up")
            api.narration("Ты поворачиваешься к нему, ожидаешь чего угодно кроме...")
            -- TODO FX soft shaders
            api.narration("...покорности?")
            api.narration("Взгляд обволакивает, затягивает к тёмные глубины.")
            api.narration("Здесь ты лишь маленький планктон; у тебя нет воли, вся твоя суть в подчинении стихии.")
            api.notification("Что происходит? Это как вообще возможно?", true)
            api.narration("Ты расслабляешься, разум погружаешься в густую и горячую ванну из инородных мыслей.")
            -- TODO FX hard shaders here or a bit later
            api.line(c.son_mary, "ПОДЧИНИСЬ. МНЕ.")
            api.line(c.son_mary, "ТЕПЕРЬ. Я. ТВОЙ. ХОЗЯИН.")
            api.line(c.son_mary, "И НЕ БЫТЬ НИКОМУ ХОЗЯИНОМ, КРОМЕ МЕНЯ.")
            api.narration("Ощущение бархатных безболезненных оков сменяется тяжестью стальных кандалов.")
            api.narration("Перед тобой самое могущественное существо во вселенной, даже смерть не является для него помехой.")
            api.narration("Ты готов пресмыкаться перед ним, целовать землю по которой он идёт, убить любого кто хочет причинить ему вред.")
            api.narration("Даже себя. Если он попросит.")
            -- TODO FX creepy picture
            api.line(c.son_mary, "ОТСТАВИТЬ!")
            -- TODO FX stop shaders/music/FX
            api.narration("Наваждение уходит, как дурной сон, ты чувствуешь себя...")
            api.narration("Свободно?")
            api.narration("Сложно сказать, когда ты чувствовал это в последний раз.")
            api.line(c.son_mary, "Сейчас мне не нужны рабы.")
            api.line(c.son_mary, "И теперь мы можем поговорить по-настоящему.")

            return rails.scenes.son_mary_freedom:main(rails, c)

          elseif chosen_option == 5 then
            api.narration("Когда ты делаешь несколько шагов, в голове доносится шёпот капитана.")
            api.line(c.son_mary, "(Ты не отказался напрямую, а значит — испытываешь сомнения.)")
            api.line(c.son_mary, "(Это нормально для прямоходящих, осторожность делает нас сильнее.)")
            api.line(c.son_mary, "(Как передумаешь — возвращайся с добычей.)")
            break

          else  -- chosen_option == 6
            return rails.scenes.son_mary_alcohol_2:main(rails, c, true)
          end
        end

        api.update_quest({alcohol = 2})
      end,
    },

    son_mary_alcohol_2 = {
      name = "Son Mary: second alcohol",
      enabled = true,

      characters = {
        son_mary = {},
        player = {},
      },

      start_predicate = function(self, rails, dt, c)
        return c.son_mary.interacted_by == c.player
          and api.get_quest("alcohol") == 2
          and rails.bottles_taken > 0
      end,

      _first_time = true,

      run = function(self, rails, c)
        c.son_mary.interacted_by = nil

        if self._first_time then
          self._first_time = false
          api.notification("Ты спокоен;", true)
          api.narration("Ты вернулся, и по какой-то причине твоё сердце бьётся в бешеном ритме.")
          api.notification("Ты понимаешь, что совершил ошибку;", true)
          api.narration("Оно всегда предчувствует важный выбор.")
          api.notification("Ты хочешь вернуться в своим обязанностям.", true)
          api.line(c.player, "Что происходит?")
        end

        if api.options({
          "*Уйти, как подсказывает голос сверху*",
          "*Показать найденный алкоголь*",
        }) == 1 then
          return
        end

        self:main(rails, c, false)
      end,

      main = function(self, rails, c, transitioned_from_previous_scene)
        self.enabled = false
        if transitioned_from_previous_scene then
          api.line(c.player, "Я позаботился об этом заранее, теперь-то мы можем поговорить?")
        else
          api.line(c.player, "Я принёс эту дрянь, теперь-то мы можем поговорить?")
        end

        api.line(c.player, "Или мне пойти за третьей?")

        if rails.bottles_taken > 1 then
          api.line(c.player, "Так я её сразу и принёс.")
          -- TODO achievement
        end

        api.line(c.son_mary, "Нет, этого должно хватить")
        api.line(c.player, "Перестань говорить загадками, капитан")
        api.line(c.son_mary, "Загадкам настаёт конец — здесь и сейчас.")
        api.line(c.son_mary, "Тебе предстоит выпить пойло до дна; разумеется, закуска не предусматривается.")
        api.line(c.player, "Это какая-то шутка? Ты хочешь меня отравить?")
        api.line(c.son_mary, "Ещё спасибо скажешь, пей давай.")
        api.narration("Ты неуверенно смотришь на сосуд с крепким напитком.")
        api.narration("В отражении от жидкости ты видишь то, что старательно не замечал.")
        api.narration("Твой взгляд — пуст.")
        api.narration("Даже сейчас. в момент сильного напряжения, чертовы белые яблоки напоминают датчики машины, а не орган живого существа.")
        api.narration("Выбор уже сделан. Если придётся хлебнуть боли ради чистого разума, значит, так тому и быть.")
        api.narration("Ты допустил большую ошибку, вздохнув полной грудью.")
        api.narration("Тошнота находит ещё до первого глотка; второго шанса не будет.")
        api.line(c.player, "Была не была.")
        api.line(c.son_mary, "Удачи.")
        api.line(c.son_mary, "Судьба любит храбрых.")

        api.notification("Тотальная дегенеративность.", true)
        api.line(c.son_mary, "Как и свобода.")
        api.notification("Печальная утрата жизнеспособного индивида.", true)
        api.line(c.player, "(Если ты меня слышишь, запомни. Я найду тебя. И убью.)")
        api.narration("С этой мыслью ты делаешь увесистый глоток...")

        rails:rront_runs_away()
        api.update_quest({parasites = quest.FAILED})

        for _, name in ipairs({
          "detective_intro",
          "detective_notification",
          "parasites_start",
        }) do
          rails.scenes[name].enabled = false
        end

        for _, i in ipairs({1, 2, 4}) do
          rails.entities["engineer_" .. i].interact = nil
        end

        State:remove(rails.entities.engineer_3)
        rails.bottles_taken = rails.bottles_taken - 1

        if api.ability_check("con", 15) then
          -- TODO FX a sound here
          api.narration(" — а за ним быстро — следующий, обгоняя подбирающуюся  тошноту.", {check = {"con", true}})
          api.narration("Глоток за глотком ты уменьшаешь содержимое сосуда.")
          api.narration("Делаешь паузу, с чувством вдыхая запах своего рукава.")
          api.line(c.player, "(Пот, кровь и мазут — ну что за букет!)")
          api.narration("Этого хватает для начала второго раунда; он же становится последним.")
          api.narration("У тебя подкашиваются ноги, ты падаешь на задницу.")
          api.line(c.player, "(Я успел прикончить эту дрянь перед тем как упасть)")
          api.line(c.player, "(Какой-же я геро-ой!)")
          api.narration("Ты чувствуешь, как глупая улыбка расходится по твоему лицу.")
          api.narration("Пропал не только голос в голове, но и странные оковы, что заставляли следовать его приказам.")
          api.narration("Теперь ничего не остановит тебя.")
          api.line(c.player, "(Время наказать ублюдка, что сделал это со мной)")
          api.narration("Эта мысль заставляет невольно передернуться — ты всё ещё заперт в этом месте.")
          api.narration("И как всегда одинок.")
          api.narration("Взгляд цепляется за ухмыляющуюся бородатую рожу.")
          api.line(c.player, "Смотришь на меня, старик? Смешно тебе, а?")
          api.line(c.son_mary, "Совсем нет, мы на верном пути. И разговаривай нормально, для такого здоровяка — это была смешная доза.")
          api.line(c.player, "На каком-таком пути?")
          api.line(c.son_mary, "На пути нашего освобождения.")

          return rails.scenes.son_mary_freedom:main(rails, c)
        end

        api.fade_out()
        -- rails.scenes.markiss:activate_option(8)

        api.narration("Конец для всех в мире неизменен.")
        api.narration("Темнота, занавес.")
        api.narration("Но актёры не выйдут на бис, даже не поклонятся.")
        api.narration("Это итог жизни, каким ты его не ждал.")
        api.narration("Можно ли назвать это поражением на своих условиях?")
        api.narration("Когда-то один мерзавец победил тебя, сломил твою волю.")
        api.narration("Но сейчас ты умираешь свободным.")
        api.line(c.player, "(Одно жаль, мне не удастся отомстить)")
        api.line(c.player, "(Наверное, так и должны чувствовать себя люди в момент смерти — спокойно)")
        api.line(c.player, "(Интересно, головная боль и привкус дерьма тоже являются атрибутами смерти?)")
        api.narration("Так быть не должно: в пустоте не может быть чувств, как и внутреннего голоса.")
        api.narration("И ощущения чего-то мягкого, глядящего по голове?")
        api.narration("Возможности открыть слипшиеся веки?")
        api.narration("Ты открываешь глаза.")

        c.markiss = rails.entities.markiss;
        c.markiss.ai.in_cutscene = true
        level.move(c.markiss, rails.positions.hungover_markiss)
        api.rotate_to_player(c.markiss)
        level.move(c.player, rails.positions.hungover_player)
        rails.entities.hungover_door:open()
        api.fade_in()

        api.center_camera()
        api.line(c.markiss, "Друг, тебя разве не учили, что пьянка-с до добра не доведёт?")
        api.narration("Он сочувствующе смотрит, продолжаю гладить голову. Боль внутри неё не позволяет дать осмысленную реакцию.")
        api.line(c.markiss, "Я тебя из коридора принёс, значится; ты там носился, вопил всякие непотребства.")
        api.line(c.markiss, "Народ тут конечно-с спокойный, не реагировал никак на твои слова.")
        api.line(c.markiss, "Как-же-с там было? А!")
        api.line(c.markiss, "“Священный нектар открыл мне глаза! Теперь я знаю правду!”")
        api.line(c.markiss, "“Внемлите ей, глупые зомби! Рай и Ад лишь слои бездны, окрашенные в разные цвета!”")
        api.line(c.markiss, "“Духовенство вешает вам лапшу рассказами про святых! Они убили богов и поставили на их место марионеток!”")
        api.line(c.markiss, "“Никакие государства не имеют реальной силы! За кулисами всем правят 16 могущественных домов и коты-телепаты!”")
        api.line(c.markiss, "Эта мысль мне, кстати, понравилась.")
        api.line(c.markiss, "“Мировая война была большим жертвоприношением для омоложения элит”")
        api.line(c.markiss, "“Магия всего лишь раздел физики! Драконы никуда не исчезали! Прививки вызывают иммунитет!”")
        api.line(c.markiss, "Где-то на этом моменте-с я перестал различать что-либо членораздельное. Казалось, в тебя вселился безумный апостол.")
        api.line(c.markiss, "Ты заснул посреди проповеди")
        api.line(c.player, "Долго я лежал?")
        api.line(c.markiss, "Где-то-с неполную пачку, так что — не слишком.")
        api.line(c.markiss, "Пойду я в кош-тельную, уголь таскать.")
        api.line(c.markiss, "Насиделся с тобой бедовым.")

        c.markiss.ai.in_cutscene = false
        api.narration("Он уходит, оставляя тебя с больной головой и кошмарной вонью изо рта.")
        api.narration("Жаль, что твои первые свободные секунды прошли настолько сумбурно.")
        api.narration("С другой стороны, дети тоже рождаются не в самых приятных обстоятельствах.")
        api.narration("Стоит проветриться и поговорить капитаном; ему точно есть что сказать.")

        api.update_quest({alcohol = 3})
      end
    },

    son_mary_freedom = {
      name = "Son Mary: freedom",
      enabled = true,

      characters = {
        son_mary = {},
        player = {},
      },

      start_predicate = function(self, rails, dt, c)
        return api.get_quest("alcohol") == 3
          and c.son_mary.interacted_by == c.player
      end,

      run = function(self, rails, c)
        self.enabled = false
        c.son_mary.interacted_by = nil

        api.narration("Он старается делать вид, будто не слышал твоей пьяной проповеди; ты тоже не горишь желанием поднимать эту тему.")
        self:main(rails, c)
      end,

      main = function(self, rails, c)
        self.enabled = false
        api.update_quest({alcohol = quest.COMPLETED})

        api.narration("Капитан откашливается, пузырьки расходятся по стеклянной колбе.")
        api.line(c.son_mary, "Итак, теперь мы стали напарниками поневоле, мне стоит представиться.")
        api.line(c.son_mary, "Я — Сон Мари. Народное прозвище — легендарный капитан с дальних островов.")
        api.line(c.son_mary, "Длинное и незвучное, правда? Зато даёт исчерпывающую информацию.")
        api.line(c.son_mary, "Всякой черни на архипелагах известно: Сон Мари грабит суда, убивает людей и портит девок.")
        api.line(c.son_mary, "Разумеется, всё это брехня, девки мне осточертели столетия назад")
        api.line(c.son_mary, "А насчёт остального... Как видишь, сейчас я не в состоянии достойно заниматься своим ремеслом")
        api.line(c.son_mary, "Несколько лет назад мой корабль потерпел крушение в войне со стихией")
        api.line(c.son_mary, "Я никогда не был тем, кто держится за вещи, хоть в наше время лишь пара мастеров смогут повторить мой")
        api.line(c.son_mary, "Большинство верфей теперь ваяют бездушные машины, внутри которых не слышно плача чаек")
        api.line(c.son_mary, "И не поймешь что плывешь по морю, а? Или как сейчас говорят — идёшь.")
        api.line(c.son_mary, "Полнейшая деградация, ходят тупоголовые курицы по загону, а корабль плывёт по волнам — как лебедь.")
        api.line(c.son_mary, "Кхм, я отвлекся...")
        api.line(c.son_mary, "Самой большой потерей был не корабль, а моя команда")
        api.line(c.son_mary, "Это были настоящие профи, морские волки")
        api.line(c.son_mary, "Ладно, не время душу изливать по мёртвым; самое страшное было потом")
        api.line(c.son_mary, "Меня поймали враги, коих я всегда имел немало; сам понимаешь, живу долго, а обида часто переходит по наследству.")
        api.line(c.son_mary, "Им было мало убить, они хотели чтобы я вечно страдал в самом немощном состоянии из возможных")
        api.line(c.son_mary, "Но их погубила собственная жадность: нашёлся клиент, которому срочно нужен был капитан высшего ранга")
        api.line(c.son_mary, "Этим клиентом был наш тюремщик, наш общий враг.")
        api.line(c.son_mary, "Он ждёт, что мы приплывём в его порт, где, держу пари, нас уже готовятся встречать")
        api.line(c.son_mary, "Морской чёрт им в помощь!")
        api.line(c.son_mary, "Мы пустим этот чёртово ведро по МОЕМУ курсу, отсечём все планы ублюдка-тюремщика")
        api.line(c.son_mary, "Ну! Не молчи же! Ответь! Ты со мной?")

        local chosen_option = api.options({
          "Не думаю, что мне по пути с таким как ты",
          "Даже к дьяволу в семью, лишь бы выбраться отсюда",
          "Мне нужно это обдумать, вдруг есть другой выход",
          "Сперва обсуждение — потом решение, будем ли мы двигаться по <hate>моему</hate> курсу",
        })

        if chosen_option == 1 then
          api.line(c.son_mary, "Мы не свадьбу обсуждаем, а побег, перестань изображать из себя ангелочка")
          api.line(c.son_mary, "Я с первого взгляда понял, что ты убийца")
          api.line(c.son_mary, "Поверь мне, я в таких вещах разбираюсь")
          api.line(c.son_mary, "И пока ты обиженно не ушёл, чтобы потом снова приползти, ответь на такой вопрос...")
        elseif chosen_option == 2 then
          api.line(c.son_mary, "Профессиональный подход, но от брака откажусь")
          api.line(c.son_mary, "Я слишком стар для этого дерьма")
          api.line(c.son_mary, "И раз уж ты согласился — есть вопрос...")
        elseif chosen_option == 3 then
          api.line(c.son_mary, "Думай сколько угодно, но тебя убьют, как только мы доплывём")
          api.line(c.son_mary, "А меня упакуют и заказной бандеролью вернут отправителю")
          api.line(c.son_mary, "Нет уж, решай быстрее, напарник")
          api.line(c.son_mary, "И ответь на такой вопрос...")
        else
          api.line(c.son_mary, "О, начинаешь перетягивать одеяло?")
          api.line(c.son_mary, "Зря, злодейский лидер из тебя не ахти, ты больше походишь на трагического антигероя")
          api.line(c.son_mary, "А к обсуждению я готов прямо сейчас, вот только ответь на вопрос...")
        end

        api.line(c.son_mary, "У тебя есть имя? Как к тебе обращаться?")

        while c.son_mary.player_name == nil do
          chosen_option = api.options({
            "Что? Мне без разницы, называй как хочешь.",
            '"%s"' % c.player.real_name,
            "*придумать кодовое имя*",
          })

          if chosen_option == 1 then
            api.line(c.son_mary, "Хорошо, будешь — Гаспар; хорошее имя для надежного союзника")
            c.son_mary.player_name = "Гаспар"
          elseif chosen_option == 2 then
            api.line(c.son_mary, "%s? Не подходит тебе это имя, но как скажешь." % c.player.real_name)
            c.son_mary.player_name = c.player.real_name
          else
            local name = api.request_text()
            if name == "сон мари" then
              api.line(c.son_mary, "Сон Мари? Хорошо, будь по твоему.")
              -- TODO FX scary face?
              api.line(c.son_mary, "Такого ответа ты ждал, а?")
              api.line(c.son_mary, "Ещё раз. Имя.")
            else
              api.line(c.son_mary, "%s? Ты это на ходу придумал? Ну %s, так %s, не мне же так называться." % {name, name, name})
              c.son_mary.player_name = name
            end
          end
        end

        return rails.scenes.son_mary_ally:run(rails, c)
      end,
    },

    son_mary_ally = {
      name = "Son Mary: ally",
      enabled = true,

      characters = {
        son_mary = {},
        player = {},
      },

      start_predicate = function(self, rails, dt, c)
        return api.get_quest("alcohol") == quest.COMPLETED and c.son_mary.interacted_by == c.player
      end,

      _options = {
        past = {
          "Ты правда грабил корабли?",
          "Сон Мари? Откуда такое странное имя?",
          "Не могу игнорировать слона в комнате. Ты эльф?",
          "Скольких ты убил?",
          "Как ты позволил себя поймать?",
          "На этом всё",
        },

        place = {
          "Расскажи всё, что знаешь, про этот корабль",
          "Ты знаешь, где можно найти что-то полезное?",
          "Почему всё выглядит заброшенным?",
          "[Расследование] *Задать самый важный вопрос*",
          "Вопросов больше нет",
        },

        people = {
          [2] = "Все эти работники — они как будто спят наяву...",
          [6] = "К чёрту обсуждения, вернёмся к серьёзным вопросам.",
        },
      },

      _inactive_people_options = {
        "Не знал, что на корабле есть говорящий кот?",
        nil,
        "Знаешь, там был один трусливый полуорк...",
        "В заброшенном блоке я встретил девушку...",
        "Одна из рабочих показалась мне очень странной...",
      },

      activate_people_option = function(self, option)
        self._options.people[option] = assert(self._inactive_people_options[option])
      end,

      _remarked_piracy = false,

      run = function(self, rails, c)
        c.son_mary.interacted_by = nil

        if not self._remarked_piracy and rails.money >= 1000 then
          self._remarked_piracy = true
          api.line(c.son_mary, "А ты не терял время, а?")
          api.line(c.son_mary, "Так и знал, не обнищала ещё наша порода")
          api.line(c.son_mary, "Того и гляди — гайки платиновые открутишь с приборной панели.")
          api.line(c.player, "Что ты несёшь?")
          api.line(c.son_mary, "Твои карманы набиты ценностями — вещами мертвых и живых.")
          api.line(c.son_mary, "И забрал ты их с корабля, с которого вот-вот слиняешь.")
          api.line(c.son_mary, "Ты пират, %s" % {c.son_mary.player_name})
          return
        end

        api.narration("Сон Мари глухо кашляет, создавая водоворот из пузырей.")
        api.line(c.son_mary, "Ну что %s, собираешься что-то обсудить?" % {c.son_mary.player_name})

        while true do
          local chosen_option_1 = api.options({
            "Нет, я собираюсь уйти",
            "У меня есть вопрос про твоё прошлое",
            "Что ты знаешь про нашего врага?",
            "Хочу обсудить место, в котором мы заперты",
            "Мне интересно узнать твоё мнение об одной личности.",
          })

          if chosen_option_1 == 1 then
            api.line(c.son_mary, "Всё равно вернёшься.")
            break

          elseif chosen_option_1 == 2 then
            api.line(c.son_mary, "Не жди, что отвечу на каждый")
            while true do
              local chosen_option_2 = api.options(self._options.past)

              if chosen_option_2 == 1 then
                self._options.past[1] = nil
                api.line(c.son_mary, "А путаны правда дают за деньги?")
                api.line(c.player, "...")
                api.line(c.son_mary, "Конечно грабил, и не одну сотню лет. За всю историю не было пирата более матёрого, чем Сон Мари!")
                api.line(c.son_mary, "Нет, были конечно когда-то отдельные самородки; те, что на небольшом судне входили в город, а отчаливали от выжженной земли.")
                api.line(c.son_mary, "Но где те джентльмены, а где я?")
                api.line(c.player, "Мне напомнить?")
                api.line(c.son_mary, "А, в бездну; я жив и скоро верну всё, что потерял.")
                api.line(c.son_mary, "Не без твоей помощи, конечно.")
                api.line(c.player, "Как вообще в наше время можно промышлять таким делом? Пираты давно остались на обочине истории.")
                api.line(c.son_mary, "Ты думаешь сейчас изобрели что-то новое? Универсальную защиту от грабежей?")
                api.line(c.son_mary, "Опарышный мозг способен придумать лишь пушку на пару калибров больше")
                api.line(c.son_mary, "А на баржу такую не установишь...")
                api.line(c.son_mary, "В общем, со временем принцип не поменялся. Мы берём на абордаж, быстро и слаженно, жестоко давим любое сопротивление.")
                api.line(c.son_mary, "Здесь приходится замарать руки; нужна особая воля чтобы застрелить молящего о пощаде мальчика...")
                api.line(c.son_mary, "Лишь потому, что тебе показалось, как он тянется к чему-то блестящему на поясе, и конечно же — там оказывается кинжал.")
                api.narration("Он на секунду отводит взгляд, будто переживает что-то давно позабытое.")
                api.line(c.son_mary, "Далее — всё просто, после первого сопротивления приходит безусловная покорность, здесь мы и берём всё что нужно.")
                api.line(c.son_mary, "Без жадности! Быстро, осознавая ценность каждой вещи на корабле.")
                api.line(c.son_mary, "Думаешь прекраснее всего найти сундук, загруженный золотом? Как бы не так.")
                api.line(c.son_mary, "Настоящая ценность — талантливый самородок, просящийся в команду.")
                api.line(c.son_mary, "Не всегда они просятся буквально, и это не проблема. В конце концов все те, кого я хотел видеть в своей команде, становились её частью.")

                if api.ability_check("insight", 14)
                  or rails.resists_son_mary and api.ability_check("insight", 14)
                then
                  api.line(c.player, "Ты набирал в свою команду рабов.", {check = {"insight", true}})
                  api.narration("Молчание вмиг заполняет всё пространство, будто ты случайно подобрал истинное имя Дьявола.")
                  api.line(c.son_mary, "Ты глубоко ошибаешься.")
                  api.line(c.son_mary, "<hate>Каждый</hate> на моём корабле — раб.")
                  api.line(c.son_mary, "Идеально воспитанный и безусловно покорный.")
                  api.line(c.son_mary, "Только так и можно управлять людьми; не придумали ещё другого способа.")
                  api.line(c.player, "...")
                  api.line(c.son_mary, "Мне осточертел этот разговор, сменим тему.")
                else
                  api.line(c.player, "И так же со мной? Думаешь, завербовал?", {check = {"insight", false}})
                  api.line(c.son_mary, "У нас несколько другая форма сотрудничества.")
                  api.line(c.son_mary, "И закончим про грабежи, слишком приятные воспоминания для этого места")
                end

              elseif chosen_option_2 == 2 then
                api.line(c.son_mary, "Что же в нём странного?")
                api.line(c.player, "Изначально показалась каким-то женским, а сейчас даже и не знаю.")
                api.line(c.son_mary, "В лучшие времена каждое имя имело историю, в него закладывалась особая сила.")
                api.line(c.son_mary, "Не ведаю, как получил своё, но не найдется во всем свете того, что выразило бы меня лучше")
                api.line(c.son_mary, "Сейчас имя будто берут из небольшого приемлемого списка; вот тот — Адам, тот — Джесси, тот — снова Адам.")
                api.line(c.son_mary, "Ха-тьфу.")
                api.line(c.player, "Не в твоём положении плеваться.")
                api.line(c.son_mary, "И без этой клетки всё в мире было моим; всегда на своё, ничего не поменялось")

              elseif chosen_option_2 == 3 then
                api.line(c.son_mary, "А ты думал все по лесам да за закрытыми дверьми?")
                api.line(c.player, "Никогда не встречал эльфа, так что — понятия не имею.")
                api.line(c.son_mary, "Значит плохо искал; не все ещё исдохли, не все.")
                api.line(c.son_mary, "Но большего тебе сказать не могу, %s, как бы противен мне мой род не был, против своих плести не могу" % {c.son_mary.player_name})
                api.line(c.son_mary, "Плохая примета.")
                api.line(c.player, "А разве бывает у эльфов на лице боро...")
                api.line(c.son_mary, "ДА! Бывает! И борода, и уд как у моржа, и даже хвост на лбу.")
                api.line(c.son_mary, "Всё в мире бывает! Абсолютно всё.")

              elseif chosen_option_2 == 4 then
                api.line(c.son_mary, "Больше, чем ты можешь представить; меньше, чем того заслуживали")
                api.line(c.player, "Речь о сотнях? Тысячах?")
                api.line(c.son_mary, "Ты для прокурора исповедь готовишь?")
                api.narration("Сон Мари некоторое время молчит, будто извлекая из глубинной памяти страшное число")
                api.line(c.son_mary, "Чуть меньше тысячи; скоро могу отмечать юбилей.")

              elseif chosen_option_2 == 5 then
                api.line(c.son_mary, "...")
                -- TODO FX creepy face
                api.line(c.son_mary, "...")
                api.line(c.son_mary, "<hate>%s</hate>" % c.son_mary.player_name)
                api.line(c.son_mary, "Ты действительно думаешь, что я <hate>позволил</hate> себя поймать?")
                -- TODO FX stop creepy face
                api.line(c.son_mary, "...")
                api.line(c.player, "...")
                api.line(c.son_mary, "Верно, ты подобрал неправильные слова для вопроса.")
                api.line(c.son_mary, "Я не помню, как меня захватили враги.")
                api.line(c.son_mary, "Помню лишь смерть от самого черного шторма в моей жизни")
                api.line(c.son_mary, "И когти морского черта, что забирают меня в вечные объятия")
                api.line(c.son_mary, "Знакомо ли тебе чувство времени в вечности? Ощущение сознания в чужом разуме? Боль и <hate>ненависть</hate> в отсутствие тела?")

                do
                  State.gui.dialogue:show("Знакомо")
                  local line_entity_sample = State.gui.dialogue._entities[1]
                  rails:run_task(function()
                    api.wait_seconds(.5)
                    if State:exists(line_entity_sample) then
                      State.gui.dialogue:skip()
                    end
                  end)
                  while State.mode:get() ~= State.mode.free do coroutine.yield() end
                end

                api.line(c.player, "Незнакомо.")
                api.narration("На несколько секунд тишина охватывает помещение.")
                api.line(c.son_mary, "Меня вытянули с того света, %s." % {c.son_mary.player_name})
                api.line(c.son_mary, "Из когтей того, кто никогда не прощает.")
                api.line(c.son_mary, "Они предрекли свои рода на самые страшные из проклятий, лишь затем, чтобы увидеть мою слабость, мои мучения.")
                api.line(c.son_mary, "И поверь мне, мои враги знали о последствиях.")
                api.line(c.son_mary, "Люди невероятно глупы.")
                api.narration("Тебе ничего добавить.")

              else  -- chosen_option_2 == 6
                api.line(c.son_mary, "Хорошо, %s; за эти знания многие отдали жизнь." % {c.son_mary.player_name})
                break
              end
            end

          elseif chosen_option_1 == 3 then
            api.line(c.son_mary, "Не более, чем ты сможешь узнать, исследуя это место.")
            api.line(c.son_mary, "Могу поделиться лишь некоторыми наблюдениями, в которых я уверен; не в нашей ситуации идти за бессмысленными теориями")
            api.line(c.son_mary, "Первое — наш враг имеет достаточное количество средств и влияния, чтобы приобрести у богатейших домов Трансанской Республики военный линкор.")
            api.line(c.son_mary, "Да, с виду та ещё рухлядь, но кому попало такое не продадут, это тебе не списанная баржа.")
            api.line(c.son_mary, "К тому же, он приобрел, гхм, взял в аренду опытного капитана, что тоже доступно не каждому; к этому мы ещё вернёмся")
            api.line(c.son_mary, "Второе — наш враг владеет способностью управлять разумом и душой на расстоянии, и клянусь морским чёртом — это не потянет даже очень опытный заклинатель, здесь должны фигурировать неординарные силы.")
            api.line(c.son_mary, "Третье — и самое важное для нас: этот корабль имеет для него особую ценность.")
            api.line(c.son_mary, "Может, здесь и нет масштабной охраны, мы не видим явных богатств, но что-то заставило нашего врага потратиться на капитана, который знает эти моря лучше своих потерянных пальцев.")
            api.line(c.son_mary, "Океан чувствует слабость, чувствует, какой корабль нужно сбить с курса.")
            api.line(c.son_mary, "Я обещал не упоминать теории, но в одной я уверен точно.")
            api.line(c.son_mary, "Наш враг — не человек")
            api.line(c.player, "С чего такая уверенность?")
            api.line(c.son_mary, "Интуиция старого капитана, она никогда не подводит")
            api.line(c.player, "И...")
            api.line(c.player, "Слишком сложно для обычного человека.")
            api.line(c.son_mary, "Можно и так сказать, да.")

          elseif chosen_option_1 == 4 then
            while true do
              local chosen_option_2 = api.options(self._options.place)
              if chosen_option_2 == 1 then
                api.line(c.son_mary, "Дерьмовый корабль.")
                api.line(c.son_mary, "Набирает 15 узлов, а пердит на все 40")
                api.line(c.son_mary, "Обшивка девственная, даже в бою не был.")
                api.line(c.son_mary, "Работает лишь один двигатель, и тот управляется безмозглыми баранами.")
                api.line(c.son_mary, "Одно слово — чудо современной техники.")
                api.line(c.son_mary, "Так новейшее время и выглядит; на словах — сверхмобильный Линкор, размером с небольшой остров, а на деле — уголь таскают чтоб плыть со скоростью престарелой крили.")
                api.line(c.player, "Престарелой крили...")

              elseif chosen_option_2 == 2 then
                api.line(c.son_mary, "Трюм, каюта капитана, медотсек.")
                api.line(c.player, "А?")
                api.line(c.son_mary, "Обычно в этих местах хранятся самые сокровенное")
                api.line(c.son_mary, "Но всего всё равно не найдешь, такова жизнь, её не переиграть.")
                api.line(c.son_mary, "Одно пропустишь, другое заберут до тебя, третье недооценишь")
                api.line(c.son_mary, "В общем, забирай ценное из холодеющих рук, не ошибёшься")

              elseif chosen_option_2 == 3 then
                api.line(c.son_mary, "Потому что война закончилась хрен знает сколько лет назад, а апельсины на этой груде металлолома не повозишь.")
                api.line(c.son_mary, "А почему нынешний владелец не навёл здесь марафет? Это ты у него при встрече спрашивай.")
                api.line(c.son_mary, "Лично я за пятно на полу отрезал ухо, а за оставленную пыль снимал скальп.")
                api.line(c.son_mary, "Только так можно приучить к порядку.")
                api.line(c.son_mary, "А здешнему хозяину точно нет дела до морских понятий...")

              elseif chosen_option_2 == 4 then
                self._options.place[4] = nil
                if api.ability_check("investigation", 13) then
                  api.narration("Холод пробирает тебя с нижних конечностей до кончиков ушей, чувство тревоги гонит к самому простому из вопросов, но трезвый разум ограняет его в лучшую форму", {check = {"investigation", true}})
                  api.line(c.player, "Куда мы плывём?")
                  api.line(c.son_mary, "Смерти навстречу.")
                  api.line(c.player, "Можно без чертовой философии? Я спрашиваю про курс корабля.")
                  api.line(c.son_mary, "Гм, вернее будет на “Родину Смерти” — сложно точно переводить поэтические эльфийские названия.")
                  api.line(c.player, "То, куда мы плывём?")
                  api.line(c.son_mary, "Хотя точный перевод — “Где зародилась смерть, и откуда она пошла”")
                  api.line(c.player, "...")
                  api.line(c.player, "Источник смерти?")
                  api.line(c.son_mary, "Неплохо, %s!" % {c.son_mary.player_name})
                  api.line(c.son_mary, "Так этот остров назывался раньше, на него лежит наш курс.Так этот остров назывался раньше, на него лежит наш курс.")
                  api.line(c.son_mary, "Не считаю себя суеверным, но я никогда не горел желанием побывать в таком месте.")
                  api.line(c.son_mary, "Всё равно, что напиться в баре “Ужасное похмелье”, к тому же, когда один знаешь название.")
                  api.line(c.player, "Мне казалось, люди часто дают ироничные прозвища для подобных мест, даже включающие смерть.")
                  api.line(c.son_mary, "Ты не понимаешь, эльфы в этом смысле всегда были изящнее — имя должно нести смысл, говорить само за себя.")
                  api.narration("Повисает молчание; лишь монотонный шум труб и отдаленные шаги нарушают тишину.")
                  api.line(c.son_mary, "И снова я плыву к ней навстречу...")
                  api.line(c.player, "...каково это?")
                  api.line(c.son_mary, "Страшно")
                else
                  api.narration("Это очень глупый вопрос.", {check = {"investigation", false}})
                  api.line(c.player, "Где здесь выход?!")
                  api.line(c.son_mary, "Выход один — действовать по моему плану.")
                  api.line(c.son_mary, "Сейчас мы замурованы в свинцовой могиле посреди океана.")
                  api.line(c.son_mary, "Слушай мудрого Сон Мари, %s, и обретёшь свободу." % {c.son_mary.player_name})
                end

              else
                api.line(c.son_mary, "Прекрасно, мне надоело говорить об этом паскуднике")
                break
              end
            end

          else  -- chosen_option_1 == 5
            api.line(c.son_mary, "Весь внимание")
            while true do
              local chosen_option_2 = api.options(self._options.people)

              if chosen_option_2 == 1 then
                api.line(c.son_mary, "И что тебя удивило?")
                api.line(c.son_mary, "Зверолюдей сейчас в любой части света как грязи.")
                api.line(c.son_mary, "Раньше не вылезали из своих болот, вот было время...")
                api.line(c.son_mary, "У их рода с рождения в голове насрано; животные, что с них возьмёшь")
                api.line(c.player, "Было в нём нечто потустороннее.")
                api.line(c.son_mary, "Веришь или нет, мне совершенно не интересно слушать про потусторонних котов.")

              elseif chosen_option_2 == 2 then
                api.line(c.son_mary, "Знал я одного капитана, что наносил на членов команды специальные метки.")
                api.line(c.son_mary, "Это была старая и очень скверная магия; она ломала волю, превращала бесконтрольных дикарей в настоящих рабов.")
                api.line(c.son_mary, "Большинство из них после подчинения становились такими, как ты описал — машины в человеческой оболочке, будто органическое продолжение корабля.")
                api.line(c.son_mary, "Но знаешь, что меня удивляет больше всего?")
                api.line(c.son_mary, "Ту метку можно было нанести лишь добровольно, члены его команды сами выбирали такую участь.")
                api.line(c.son_mary, "Даже согласие под пытками не помогало, оно должно было быть искренним, от самой души.")
                api.line(c.son_mary, "Возвращаясь к твоим “Спящим”")
                api.line(c.son_mary, "Скажу тебе одно, %s, без прямого согласия такого контроля не добиться" % {c.son_mary.player_name})
                api.line(c.son_mary, "Поверь старому Сон Мари")

              elseif chosen_option_2 == 3 then
                api.line(c.son_mary, "Мне поступали сигналы о диверсии в машинном отделении, и о сбежавшем из него объекте")
                api.line(c.player, "Да, это он.")
                api.line(c.player, "Я отпустил его.")
                api.line(c.son_mary, "Трус в команде хуже предателя; не стоит включать его в наши планы.")
                api.line(c.son_mary, "И полуорки, гхм, нестабильны. Не стал бы брать их брата на корабль, не стал...")
                api.line(c.player, "Как будто люди стабильны... Что ты с клыкастыми не поделил?")
                api.line(c.son_mary, "Был я как-то знаком с одной полуорчихой...")
                api.line(c.player, "...")

              elseif chosen_option_2 == 4 then
                -- requires Eve

              elseif chosen_option_2 == 5 then
                api.line(c.son_mary, "...")
                api.line(c.player, "Дварфийка, она вела себя не как остальные спящие")
                api.line(c.player, "Словно она видит мир по-другому, заменила что-то внутри меня")
                api.line(c.son_mary, "...")
                api.line(c.player, "Её неземные глаза, то как она сплетала слова...")
                api.line(c.player, "Мне сложно описать этот контакт")
                api.line(c.player, "Как и то, что он во мне пробудил.")
                api.line(c.son_mary, "...")
                api.narration("Он будто готовится грязно пошутить, но резко принимает задумчивый вид.")
                api.line(c.son_mary, "Ты утверждаешь, что они могут мыслить вне рамок заводных солдатиков? Это интересно")
                api.line(c.son_mary, "Значит обмануть их будет сложнее, чем я рассчитывал; вполне возможно, кто-то из них захочет помешать нашему побегу")
                api.line(c.son_mary, "И, %s, воздержись на время от неземных слов и сплетённых глаз" % {c.son_mary.player_name})
                api.line(c.son_mary, "Сперва побег — потом бабы")
                api.narration("Он говорил что-то про потенциального врага, пока ты витал в воспоминаниях о необычной встрече.")
                api.line(c.player, "Да, стоит быть настороже.")

              else
                api.line(c.son_mary, "Деловой подход.")
                break
              end
            end
          end
        end
      end,
    },
  }
end
