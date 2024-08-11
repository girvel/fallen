local shaders = require("tech.shaders")
local api = require("tech.railing").api
local mech = require("mech")


return function()
  return {
    intro = {
      name = "Introduction",
      enabled = true,
      start_predicate = function(self, rails, dt) return true end,

      run = function(self, rails, dt)
        self.enabled = false

        State.player:rotate("up")
        State.gui.disable_ui = true
        local old_fov = State.player.fov_radius
        State.player.fov_radius = 0

        api.narration('... никогда не забуду тебя ненавидеть\n\n\t\t<span color="8b7c99">[Пробел]</span>')
        api.narration("...")
        api.narration("... не забуду тебя ненавидеть")
        api.narration("... не на ви деть")
        api.narration("... тебя <hate>ненавидеть</hate>")

        State.gui.disable_ui = false

        api.narration("Эти слова повторял <hate>Я</hate>?")
        api.narration("Или они были для <hate>Меня</hate>?")

        api.notification("приведи себя в порядок", true)
        api.wait_seconds(3)

        api.narration("А кем были те “Я” и “Меня”?")
        api.narration("Это так … странно?")
        api.narration("Я чувствую как холодно спереди")
        api.narration("Ру-кам?")
        api.narration("И тесно снизу")
        api.narration("Но-гам?")
        api.narration("Почему всё должно быть черно-белым.")
        api.narration("Отчего они не видят <hate>красный</hate> цвет.")

        State.player.fov_radius = old_fov
        State:set_shader(shaders.black_and_white)
        api.wait_seconds(0.2)
        State:set_shader(shaders.black_and_white_and_red)
        api.wait_seconds(0.5)
        State:set_shader()

        api.narration("Руки инстинктивно отскакивают от потока ледяной воды")
        api.narration("Перед тобой мутное зеркало и видавший лучшую жизнь умывальник")
        api.narration("Справа неопрятный сортир")
        api.narration("Стены спаяны из металлических листов, от них эхом отражается любой звук")
        api.narration("Один из звуков - храп с дальней кровати.")
        api.narration("Почему-то он не раздражает, кажется родным.")

        api.line(State.player, "Передо мной зеркало")
        api.line(State.player, "В нём я")
        api.line(State.player, "Но кто <hate>я</hate>?")

        State.player.experience = mech.experience_for_level[2]
        State.gui.character_creator:refresh()
      end,
    },

    {
      name = "Player created the character",
      enabled = true,
      start_predicate = function(self, rails, dt) return State.player.class end,

      run = function(self, rails, dt)
        self.enabled = false
        local comments = {
          {
            str = "Чувствую, горы могу свернуть",
            dex = "Моим рефлексам позавидует мангуст",
            con = "Здоровья у меня как у быка",
            int = "Похоже, мозги мне не отшибло",
            wis = "Глаза и уши наконец настроились",
            cha = "Какой же красавец в зеркале",
          },
          {
            str = "И силы не занимать, лучше не стой на моём пути",
            dex = "И координация на отличном уровне, не терпится размяться",
            con = "И я пышу здоровьем, точно не лягу с пары ударов",
            int = "И голова работает, начинаю что-то вспоминать",
            wis = "И я сосредоточен на задаче, внимателен, собран",
            cha = "И я красив, мало кто может похвастаться таким глубоким взглядом.",
          },
          {
            str = "Но очень неприятно быть таким слабым",
            dex = "Но я так неуклюж, тело будто движется с задержкой",
            con = "Но надо быть осторожнее, пара ударов и не нужны будут такие качества",
            int = "Мало того, ещё и умён!",
            wis = "И… Кажется я сбился с мысли",
            cha = "Но в зеркало лучше лишний раз не смотреть",
          },
        }

        local sorted_abilities = Fun.iter(State.player.abilities)
          :map(function(...) return {...} end)
          :totable()
        table.sort(
          sorted_abilities,
          function(t1, t2) return t1[2] < t2[2] end
        )

        api.line(State.player, comments[1][sorted_abilities[6][1]])
        api.line(State.player, comments[2][sorted_abilities[5][1]])
        api.line(State.player, comments[3][sorted_abilities[1][1]])

        -- (picking the name goes here)

        api.notification("Пройдись и приготовься выходить", true)
        api.narration("В голове вновь раздается странный звон.")
        State.player:rotate("down")
        api.narration("Ты оборачиваешься, но там только письменный стол с запиской.")
        api.line(State.player, "Стоит осмотреться")
      end,
    },

    {
      name = "Player leaves the room before reading the note",
      enabled = true,
      start_predicate = function(self, rails, dt)
        return State.player.position == rails.positions.player_room_exit
          and State:exists(rails.entities.note)
      end,

      run = function(self, rails, dt)
        self.enabled = false
        api.line(State.player, "Возможно, следует вернуться к той записке на столе")
        api.line(State.player, "Кто-то оставил её для меня")
      end,
    },
  }
end
