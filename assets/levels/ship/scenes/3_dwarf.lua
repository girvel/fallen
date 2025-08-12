local sprite = require("tech.sprite")
local railing = require("tech.railing")
local api = railing.api


return function()
  return {
    dwarf_signals_talking = {
      name = "Dwarf signals she wants to talk",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return (rails.entities.engineer_4.position - State.player.position):abs() >= 7
      end,

      run = function(self, rails)
        self.enabled = false
        -- TODO sound
        api.rotate_to_player(rails.entities.engineer_4)
        api.message.temporal("Постой, не уходи", {source = rails.entities.engineer_4})
      end,
    },

    dwarf_talks_about_rront = {
      name = "Dwarf talks about Rront",
      enabled = false,
      start_predicate = function(self, rails, dt)
        return rails.entities.engineer_4.interacted_by == State.player
      end,

      run = function(self, rails)
        self.enabled = false
        rails.scenes.dwarf_signals_talking.enabled = false
        rails.scenes.son_mary_ally:activate_people_option(5)
        rails.entities.engineer_4.portrait = sprite.image("assets/sprites/portraits/dwarf.png")

        local is_rront_alive = rails.entities.engineer_3.hp > 0

        api.rotate_to_player(rails.entities.engineer_4)
        api.narration("Дварфийка сосредоточенно всматривается в твой живот.")

        if api.ability_check("perception", 10) then
          api.narration("Нет, выше, — она смотрит прямо в сердце.", {check = {"perception", true}})
        else
          api.narration("Видимо, пряча от тебя взгляд.", {check = {"perception", false}})
        end

        api.narration("Она несколько раз открывает рот, пытаясь найти нужные слова.")

        if is_rront_alive then
          api.line(rails.entities.engineer_4, "Ты спас его.")
          api.line(rails.entities.engineer_4, "Хотя должен был убить.")
          api.line(rails.entities.engineer_4, "Перчатки что были на нём...")
          api.line(rails.entities.engineer_4, "Я отдала их, потому что он чувствовал боль.")
        else
          api.line(rails.entities.engineer_4, "Эти перчатки...")
          api.line(rails.entities.engineer_4, "Я отдала их, потому что он чувствовал боль.")
        end

        api.line(rails.entities.engineer_4, "Это противоречит указанию, я знаю.")
        api.line(rails.entities.engineer_4, "Но в моем сердце выбиты другие правила, я посчитала их выше текущих.")

        if is_rront_alive then
          api.line(rails.entities.engineer_4, "Почему ты отпустил его? Почему нарушил указания?")

          api.options({
            "Я не знаю, почему отпустил, мои действия не обязательно должны иметь объяснение",
            "Я понял, что он не виноват, логичнее было его отпустить.",
            "Я увидел, что он напуган, вот-вот обмочится. На такого рука у меня не поднялась.",
            "Я не собираюсь в чем-то перед тобой отчитываться.",
            "Я отпустил его, потому что могу. Других объяснений не будет.",
          })
        else
          api.line(rails.entities.engineer_4, "А ты убил его.")
          api.line(rails.entities.engineer_4, "Но отдал мне перчатки.")
          api.line(rails.entities.engineer_4, "Почему?")

          api.line(State.player, "(Она хочет знать ответ? Всё очень просто)")

          api.options({
            "Я не знаю, почему их дал; мои действия не обязательно должны иметь объяснение",
            "Я понял, что они принадлежат тебе, логичнее было вернуть всё к порядку.",
            "Я увидел, что у тебя обожжены руки, перчатки должны защитить от дальнейших повреждений.",
            "Я не собираюсь в чем-то перед тобой отчитываться.",
            "Я сделал это, потому что могу. Других объяснений не будет.",
          })
        end

        api.narration("Дварфийка поднимает голову, смотрит прямо в твои глаза.")
        api.narration("На секунду кажется, что она выше тебя.")

        api.line(rails.entities.engineer_4, "Твой ответ неважен.")
        api.line(rails.entities.engineer_4, "Ведь он исходит от тебя лично, каким бы ни был.")
        api.line(rails.entities.engineer_4, "В этом ты похож на того, кого %s." % {
          is_rront_alive and "отпустил" or "убил"
        })
        api.line(rails.entities.engineer_4, "И не похож на меня.")
        api.line(rails.entities.engineer_4, "Свобода — это благо, дарованное немногим, постарайся распоряжаться ей достойно.")

        api.narration("Она тянется под робу, отстегивает что-то со своей шеи.")
        api.narration("Достаёт маленький каменный амулет с вырезанным солнцем.")
        api.line(rails.entities.engineer_4, "Это то немногое, чем я могу помочь.")
        api.narration("Она протягивает руку.")

        if api.ability_check("religion", 16) then
          api.narration("Солнце у дварфов символизирует бога Торрга, вечно борющегося с тьмой — как в виде кошмарных подземных созданий, так и в дварфийских сердцах.", {check = {"religion", true}})
          api.narration("Он давно мертв, как и тьма, с которой он боролся.")
          api.narration("Амулет — осколок былой веры, не более чем ценность для любителей древности.")
          api.narration("Но найти его в таком месте... Кто-то мог бы увидеть в этом чудо.")
        else
          api.narration("Всего лишь безделушка; она не имеет фактической ценности.", {check = {"religion", false}})
          api.narration("Но символ солнца почему-то вызывает у тебя уверенность.")
          api.line(State.player, "“Где-то светит солнце”")
        end

        State.player.bag.amulet = 2 - api.options({
          "*принять амулет*",
          "*отказаться от амулета*",
        })
      end,
    },
  }
end
