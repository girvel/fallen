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
          and not rails:is_running("son_mary_1")
          and (c.son_mary.position - State.player.position):abs() <= 3
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

    son_mary_1 = {
      name = "Talking to Son Mary the first time",
      enabled = true,

      characters = {
        son_mary = {},
        player = {}
      },

      start_predicate = function(self, rails, dt, c)
        return c.son_mary.interacted_by == c.player
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
          api.line(c.player, "Где-то я тебя видел… Вспомнил!")
          api.line(c.player, "Ты из тех маринованных голов, что продают шарлатаны на рынках")
          api.line(c.player, "И что же тобой лечат? Импотенцию? Цирроз?")
          api.line(c.son_mary, "И даже пытается шутить, хм...")
        end

        api.line(c.son_mary, "Знай, я никогда не беру слова назад")
        api.line(c.son_mary, "Обращался я не к тебе, а к безвольным, что ходят вокруг; за одного из них тебя принял")
        api.line(c.son_mary, "Они хуже рабов — рабы хотя бы мечтают о свободе. Или собственных рабах.")
        api.line(c.son_mary, "А ты… Это мы сейчас и проверим")

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
          State:set_shader()
          api.line(c.son_mary, "Всё равно я успел узнать всё, что мне нужно")
          rails.resists_son_mary = true
        else
          State:set_shader(shaders.charmed({
            rails.entities.son_mary,
            rails.entities.son_mary_upper,
            State.grids.solids[rails.entities.son_mary.position],
          }))

          api.narration("Он слишком силён, ты можешь лишь терпеть, пока он копается в твоей голове.")
          api.narration("Ощущение, будто расковыряли давно зажившую рану.")
          local heartbeat = sound("assets/sounds/heartbeat.mp3", 1)
          heartbeat.source:setLooping(true)
          sound.play({heartbeat})
          heartbeat.source:play()
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
          State:set_shader()
          api.narration("Пообещай, что больше это не повторится.")
        end

        api.line(c.player, '<hate>Я.</hate> <hate offset="2">Убью.</hate> <hate offset="4">Тебя.</hate>')
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

        if api.ability_check("insight", 13) then
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
        rails:run_task(function()
          api.wait_seconds(15)
          api.notification("Не слушай его, займись делом.", true)
        end)
      end,
    },
  }
end
