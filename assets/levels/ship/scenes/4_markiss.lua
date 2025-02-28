local quest = require("tech.quest")
local api = require("tech.railing").api


return function()
  return {
    markiss = {
      name = "Markiss dialogue",
      enabled = true,
      start_predicate = function(self, rails, dt, c)
        return c.markiss.interacted_by == c.player
      end,

      characters = {
        markiss = {},
        player = {},
      },

      _top_level_options = {
        "Ты — Кот.",
        "Ты не похож на остальных рабочих.",
        "Расскажи подробнее, чем ты занимаешься?",
      },

      _inactive_options = {
        [4] = "Не видел здесь полуорка? Такой зелёный и здоровый",
        [5] = "Не знаешь чего полезного про Сон Мари?",
        [6] = "Не знаешь, где тут найти ром?",
        [7] = "*отдать сигареты*",
        [8] = "И все-таки, почему ты помог мне?",
      },

      activate_option = function(self, i)
        self._top_level_options[i] = assert(self._inactive_options[i])
      end,

      _furry_recognized = nil,
      _interaction_i = 0,

      run = function(self, rails, c)
        c.markiss.interacted_by = nil
        api.rotate_to_player(c.markiss)
        self._interaction_i = self._interaction_i + 1

        if self._interaction_i == 1 then
          rails.scenes.son_mary_ally:activate_people_option(1)

          api.line(c.markiss, c.markiss.ai.point_i == 1
            and "Пропустите-с, направляюсь от кош-тельной за углём"
            or "Пропустите-с, несу уголь в кош-тельную"
          )
          api.line(c.player, "(Это... Кот?)")

          self._furry_recognized = api.ability_check("nature", 18)
          if self._furry_recognized then
            api.narration(
              "Он представитель расы зверолюдей с западного континента; их аномальная природа влияет на эмбрион в момент созревания, в результате дети рождаются с чертами разных зверей.",
              {check = {"nature", true}}
            )
          else
            api.narration("Определенно. Кот.", {check = {"nature", false}})
          end

        else
          local OPENING_LINES = {
            {},
            {
              "Здесь то — холодно, то — жарко",
              "Совсем как на моей родине",
            },
            {
              "Раньше в Руме шили-с хорошие штаны, отец рассказывал",
              "Теперь такие уже нигде не достать",
            },
            {
              "Я где-то оставил свою счастливую бритву",
              "Надеюсь, никто не порежется",
            },
            {
              "Для хорошей лепёшки нужны лишь мука, вода и соль",
              "Для хорошей жизни — и того меньше",
            },
            {
              "Интересно, куда ведёт эта дорога?",
              "Надеюсь, это будет райский остров",
            },
            {
              "Вопросы классификации мировоззрений чаще всего поднимают люди с очень неприятным мировоззрением",
              "И в целом, классификация редко приводит к чему-то хорошему",
            },
            {
              "Хороший хозяин кормит не только кошку, но и крыс",
              "Это я как крыса говорю",
            },
            {
              "В последнее время все так суетятся, как будто случилось что",
              "А как по мне, всё время что-то где-то случается. Не повод это для суеты",
            },
            {
              "Ты очень хороший слушатель, я это ценю",
              "Надо будет придумать тебе награду",
            },
            {
              "Я пока-с не придумал награду",
              "Но придумаю к нашей следующей встрече, в другом месте",
              "Не терпится увидеть это другое место",
            },
            {
              "И вновь привет, мой добрый друг!",
              "Всё так же бродишь ты вокруг",
            },
          }

          for _, line in ipairs(OPENING_LINES[math.min(self._interaction_i, #OPENING_LINES)]) do
            api.line(c.markiss, line)
          end
        end

        self._top_level_options[99] = "*уйти*"
        while true do
          local chosen_option_1 = api.options(self._top_level_options, true)

          if chosen_option_1 == 1 then
            api.line(c.markiss, "Действительно, друг? А я думаю, почему-c так хочется охотиться на мышей")

            local chosen_option_2 = api.options({
              "Ты мне — не друг!",
              "Почему ты назвал меня другом?",
            })

            if chosen_option_2 == 1 then
              api.line(c.markiss, "Ошибаешься, друг. Все мы связаны общими делами-с. Все заперты в одной кле-точ-ке.")
            else
              api.line(c.markiss, "Потому что ты мой друг-с. Мы связаны общим делом. Сидим в одной клеточке.")
            end

            local chosen_option_3 = api.options({
              "Нет у нас ничего общего, запомни это.",
              "Общее дело? Клеточка? Что ты имеешь в виду?",
            })

            if chosen_option_3 == 1 then
              api.line(c.markiss, "Хорошо, друг.")
            else
              api.line(c.markiss, "Ты спрашиваешь, хоть и знаешь? Это почти как молчать, если не знаешь.")

              local chosen_option_4 = api.options({
                "[Убеждение] *убедить его рассказать больше*",
                "Поменьше кури эту дрянь, не будут клеточки мерещиться.",
              })

              if chosen_option_4 == 1 then
                if api.ability_check("persuasion", 12) then
                  api.line(c.player, "(Такая речь запутает многих, но не меня. Поиграем по твоим правилам, кот)", {check = {"persuasion", true}})
                  api.line(c.player, "Конечно. Друг, кле-точ-ка, общее дело. А, не напомнишь, где ключик или дверка у этой клеточки?")
                  api.narration("Кот серьёзно задумывается, даже перестаёт дымить.")
                  api.line(c.markiss, "Мне кажется, все двери в твоей голове. А ключи стоит искать в сердце")
                  api.narration("Ты определенно переоценил свой уровень адаптации к абстрактной беседе.")
                else
                  api.narration("Он явно не понял с первого раза, нужно повторить вопрос несколько раз.", {check = {"persuasion", false}})
                  api.line(c.player, "Что за клеточка? Что за общее дело? Почему ты кот? О чем ты говоришь?")
                  api.narration("Кот лениво выдыхает дым.")
                  api.line(c.markiss, "Су-е-та...")
                  api.narration("Терминальный случай, тут ответа не добиться.")
                end
              else
                api.line(c.markiss, "Клеточка не исчезнет, даже если закрыть глаза")
                api.narration("Этот разговор начинает сводить тебя с ума, лучше сделать перерыв.")
              end
            end

          elseif chosen_option_1 == 2 then
            api.line(c.markiss, "Разве-с? Я чем-то выделяюсь, помимо ушек и шерсти-с?")

            local chosen_option_2 = api.options({
              "Если так подумать, то ничем...",
              "[Религия] *Может, в нём есть что-то потустороннее?*",
              "[Проницательность] *Может, есть что-то необычное в его поведении?*",
            })

            if chosen_option_2 == 1 then
              api.line(c.markiss, "Мудрая мыслишка, все мы разной породы, но суть внутри одна-с")

              local chosen_option_3 = api.options({
                "Меня начал утомлять этот разговор. Ты же не вызовешь никаких проблем тут?",
                "У нас с тобой и суть, и порода разные.",
              })

              if chosen_option_3 == 1 then
                api.line(c.markiss, "Никаких проблем-с, начальник!")
              else
                api.line(c.markiss, "Как скажешь, начальник!")
                api.line(c.markiss, "Но вот мне так не кажется, а я в корень смотрю, глаз намётан")
                api.narration("Кот игриво показывает на свой левый глаз.")
                api.line(c.markiss, "Сам посмотри")

                if api.ability_check("wis", 14) then
                  api.line(c.player, "Не буду я в твои глаза смотреть, есть дела поважнее.", {check = {"wis", true}})
                else
                  api.narration("Это существо — твой хороший друг.", {check = {"wis", false}})
                  api.narration("Были ли у тебя друзья ранее? Неважно.")
                  api.narration("Он станет первым.")
                  api.line(c.markiss, "Мы одной сути, друг-с")
                  api.narration("Внезапно он выпускает клубок густого дыма тебе в лицо.")
                  api.narration("Наваждение проходит.")
                  api.line(c.player, "Что за черт?! Как ты это сделал?")
                  api.line(c.markiss, "Магия-с, друг. Магия-с.")
                  api.narration("В голову приходит осознание — ты не сможешь ему навредить. Никак.")
                  api.narration("Придётся жить в этом проклятом мире.")
                end
              end

            else  -- chosen_option_2 == 2
              local success, check
              if chosen_option_2 == 2 then
                success = self._furry_recognized or api.ability_check("religion", 10)
                check = "religion"
              elseif chosen_option_2 == 3 then
                success = self._furry_recognized or api.ability_check("insight", 12)
                check = "insight"
              else
                error()
              end

              if success then
                api.narration("Жук попал в муравейник. Но почему-то не разоряет его.", {check = {check, true}})
                api.narration("Он таскает листочки и веточки с муравьями-рабочими.")
                api.line(c.player, "Зачем тебе всё это? Ты не один из них.")
                api.narration("Кот от удивления громко кашляет, глотая сигарету.")
                api.line(c.markiss, "Это-с. Черт-с. Ахх-с.")
                api.narration("Наконец он восстанавливает дыхание и достаёт новую сигарету.")
                api.line(c.markiss, "Это, черт, я не ожидал-с таки услышать, начальник!")
                api.line(c.markiss, "Я своего рода исследователь, токмо без лицензии-с")
                api.line(c.markiss, "Исследую-с куда глаза глядят")
                api.line(c.markiss, "Так и здесь оказался-с, и вот исследую-с!")

                local options = {
                  "Может, наисследовал что полезное?",
                  "Может ты находил *выход*?",
                  "Ладно, всё с тобой ясно, бродяга.",
                }

                while true do
                  local chosen_option_3 = api.options(options, true)

                  if chosen_option_3 == 1 then
                    api.line(c.markiss, "Да! И рад поделиться-с, начальник!")
                    api.line(c.markiss, "Двери-с тут кое-где хлипкие, кто сильный ударит, токмо так развалятся!")
                    api.line(c.player, "А ты пробовал?")
                    api.line(c.markiss, "Нет. У меня лапки")
                  elseif chosen_option_3 == 2 then
                    api.line(c.markiss, "Выход, начальник?")
                    api.line(c.markiss, "Выход есть всегда, иногда даже не один")
                    api.line(c.markiss, "У нас на родине есть примета.")
                    api.line(c.markiss, "Если потерялся, если стоишь не перепутье")
                    api.line(c.markiss, "Не иди прямо — там-с смерть тебя дожидается")
                    api.line(c.markiss, "А назад идти резона-с нет  — так снова на перепутье окажешься")
                    api.line(c.markiss, "И... Как же там дальше было-с")
                    api.line(c.markiss, "Пойдёшь направо — точно что-то про жену...")
                    api.line(c.markiss, "Налево — что-то про коня, хотя-с логичнее было бы про мужа...")
                    api.line(c.markiss, "Про что мы говорили?")
                    api.line(c.player, "Про выход")
                    api.line(c.markiss, "Не знаю я выхода, начальник! Ситуация безвыходная!")
                    api.line(c.markiss, "Хотя как говорится, выйдешь из клетки — окажешься в клетке побольше.")
                    api.line(c.markiss, "А в этом случае и двери, и стенки клетки теряют всякий смысл.")

                    local chosen_option_4 = api.options({
                      "Может, я сошёл с ума от общения с тобой, но в этом и правда что-то есть.",
                      "Если на твоей родине все такие дурные — мне вас очень жаль.",
                    })

                    if chosen_option_4 == 1 then
                      api.line(c.markiss, "Спасибо, э, как я там тебя называл?")
                      api.line(c.player, "Начальник, хотя зовут меня — %s" % c.player.inner_name)
                      api.line(c.markiss, "Не подходит тебе это имя, своё поищи")
                      api.line(c.player, "А имя должно как-то подходить? Вот допустим твоё?")
                      api.line(c.markiss, "Я — Маркисс")
                      c.markiss.name = "Маркисс"
                      api.line(c.player, "Вопросов больше не имею")
                    else  -- chosen_option_4 == 2
                      api.line(c.markiss, "Не все! Я один такой-сякой")
                    end
                  else  -- chosen_option_3 == 3
                    break
                  end
                end

              else  -- religion/insight check failed
                api.narration("Теневые коты, точно! Ты многое слышал о них.", {check = {check, false}})
                api.narration("Это опаснейшие суперхищники, контролирующие разум своих жертв.")
                api.narration("Тенекоты увлекают их разговором, заставляют потерять внимание...")
                api.narration("А потом жестоко расправляются одним ударом бритвенно-острого хвоста.")

                if api.ability_check("nature", 10) then
                  api.narration("И неважно, что их истребили 600 лет назад.", {check = {"nature", true}})
                end

                api.narration("Без сомнений — перед тобой один из Теневых котов.")
                api.line(c.player, "Понятно, я, пожалуй, пойду")
                api.line(c.markiss, "До встречи, начальник-с!")
              end
            end  -- (2)

          elseif chosen_option_1 == 3 then
            api.line(c.markiss, "Я-то? Сначала-с беру угля, да побольше, в хранилище")
            api.line(c.markiss, "Потом несу-тащу его в кош-тельную")
            api.line(c.markiss, "Эта работа требует большой воли и мастерства-с")
            api.line(c.markiss, "Иногда, можно не туда-с свернуть или забыть взять уголь")
            api.line(c.markiss, "Бывает, думаешь, как разойтись с другим рабочим-очим или, вот, мысль приходит.")
            -- TODO horror SFX
            api.line(c.markiss, "Зачем вообще всё это нужно.")
            api.line(c.markiss, "Оно когда-нибудь закончится?")
            -- TODO horror SFX
            api.line(c.markiss, "Но потом-с ты берёшь ещё одну порцию угля и снова всё хорошо.")

          elseif chosen_option_1 == 4 then
            api.line(c.markiss, "Бегал такой-дурной, да! Аж до потолка- подпрыгивал")
            api.line(c.markiss, "А потом я отвернулся на секундочку-с, а его и след простыл")
            api.line(c.markiss, "Есть такая порода-с людей, что невидимостью особой владеют")
            api.line(c.markiss, "Такие ещё-с работать очень не любят")
            api.line(c.markiss, "Не то что я!")
            api.narration("Кот уверенно указывает на себя большим пальцем.")

          elseif chosen_option_1 == 5 then
            api.line(c.markiss, "Сон Мари-с? Скверный, он, скверный.")
            api.line(c.markiss, "Имя слишком на моё похоже, я Маркисс, а он Мари-с")
            api.line(c.player, "Совсем не похоже, он Сон Мари, а ты? Как, ещё раз?")
            api.line(c.markiss, "Маркисс, а его имя лучше часто не произноси-с. К беде это.")
            api.line(c.player, "Может хватит загадок? Почему к беде?")
            api.line(c.markiss, "На Маркисс слишком похоже...")
            api.line(c.player, "Пойду-ка я, лучше, чем полезным займусь.")

          elseif chosen_option_1 == 6 then
            api.line(c.markiss, "Я такие напитки не пью-с, братец, и тебе не советую")
            api.line(c.markiss, "Пить — здоровью вредить.")
            api.narration("Кот делает глубокую затяжку.")

            if api.options({
              "Знаешь что? Я устал! Сам найду, без всех этих игр, поручений и прочей дряни.",
              "[Запугивание] Не братец я тебе... Мне нужен ром. Расскажи, где его найти.",
            }) == 1 then
              api.line(c.markiss, "Премного желаю-с удачи")
            elseif api.ability_check("intimidation", 12) then
              api.narration("Сам того не замечая, ты произносишь эти слова со скрипом зубов.", {check = {"intimidation", true}})
              api.narration("Лицо горит, брови безумно дергаются.")
              api.narration("А из ноздрей валит пар. Как же тебя всё достало!")
              api.line(c.markiss, "Не кипятись, товарищ! Не знал, что настолько-с фляга свистит")
              api.line(c.markiss, "О, фляга!")
              api.line(c.markiss, "Я как раз видел флягу в кармане одного из рабочих")
              api.line(c.markiss, "Там точно таится что-то согревающее")
              api.line(c.player, "Как выглядел тот рабочий?")
              api.line(c.markiss, "Голова дырявая у меня, товарищ, придется тебе самому поискать")
              rails:notice_flask()
            else
              api.line(c.markiss, "Совсем память плохая, братец!", {check = {"intimidation", false}})
              api.line(c.markiss, "От этой соломы-ломы мысль хорошая не идёт")
              api.line(c.markiss, "Найдёшь мне настоящих, Душнарских, пачку, а лучше две-с")
              api.line(c.markiss, "Сам тебе этот Ром-с достану")
              api.line(c.player, "И где мне их найти?")
              api.line(c.markiss, "А ты шутник, братец!")
              api.line(c.markiss, "Знал бы я — сам нашёл.")
              rails:sigi_update("needed")
            end

          elseif chosen_option_1 == 7 then
            api.narration("Он жадно хватает пачку, выплевывая предыдущую сигарету.")
            api.narration("Когтем вскрывает хлипкую упаковку и достаёт сигарету, обернутую в плотный тёмный табачный лист.")
            api.narration("Наконец, зажимает её пастью, поджигает и делает первую затяжку.")
            api.line(c.markiss, "Ухх, такие больше не делают. Дуушнары теперь по высокому бизнесу, а ведь раньше-то лучше всех-всех народные вещи делали.")
            api.line(c.player, "Ты кое-что обещал.")
            api.line(c.markiss, "Не злись, братец, но ром тебе я не найду.")
            api.line(c.player, "А по шее?")

            if rails.lunch_started then
              api.line(c.markiss, "Но скажу — где ты сам его найдёшь! У одного из работяг, что шел в столовую, должна быть фляжка")
              api.line(c.markiss, "Там и будет твоё сокровище")
            else
              api.line(c.markiss, "Но скажу — где ты сам его найдешь! Я видел фляжку у одного из работяг — ты сможешь найти его в столовой, когда начнется обед")
              api.line(c.player, "И когда же он начнется?")
              api.line(c.markiss, "Да ещё с час назад должен был! Верно проблемы какие-то за чёрными дверьми.")
              api.line(c.player, "Это метафора?")
              api.line(c.markiss, "Метафора, синекдоха, метонимия — всё это мне, неучёному коту, неизвестно.")
              api.line(c.markiss, "Я всегда говорю-с напрямую")
            end
            api.update_quest({sigi = quest.COMPLETED})
            rails:notice_flask()

          elseif chosen_option_1 == 8 then
            api.line(c.markiss, "М-м? Помог?")
            api.line(c.player, "Ты знаешь, о чём я говорю, ты отнёс меня в комнату и ждал, пока я приду в себя")
            api.line(c.markiss, "Мне показалось, что мы ещё должны встретиться, в этой жизни или в следующей")
            api.line(c.markiss, "Хотелось бы в этой. Может, на том острове, куда мы плывём")
            api.line(c.player, "Острове? Скажи всё, что про него знаешь!")
            api.line(c.markiss, "Ничего, как и ты! Остров, как остров")
            api.line(c.markiss, "Религиозные культы и могущественные дома, делящие любовь народа, будто куски пирога")
            api.line(c.markiss, "Люди, что грызут друг другу глотки за богатство и власть")
            api.line(c.markiss, "Всё как в остальном мире")
            api.line(c.player, "И правда. Мир не меняется")
            api.line(c.markiss, "Мир не меняется, но можно поменяться самому, а?")
            api.line(c.player, "Не будем торопить события.")

          else  -- if chosen_option_1 == 99
            break
          end  -- (1)
        end  -- main dialogue loop
      end,
    },

    markiss_attacked = {
      name = "Markiss attacked",

      enabled = true,

      characters = {
        markiss = {},
      },

      start_predicate = function(self, rails, dt, c)
        return State:check_aggression(State.player, c.markiss)
      end,

      _counter = 0,
      _line_entities = {},

      run = function(self, rails, c)
        local lines = {
          "Ух, было-с близко",
          "Ты действительно-с хочешь поранить кота?",
          "Ай больно-больно! Хотя нет — не больно",
          "Это всё внутренние ограничения; расслабься, соберись с духом",
          "Не получилось? Очень жаль.",
          "Почти попадание! Не бросай попытки-с, совершенствуйся",
          "На следующий раз точно получится",
        }

        self._counter = self._counter + 1
        if State:exists(self._line_entities[1]) then
          State:remove_multiple(self._line_entities)
        end
        self._line_entities = api.message.temporal(
          lines[math.min(#lines, self._counter)], {source = c.markiss}
        )
      end,
    },
  }
end
