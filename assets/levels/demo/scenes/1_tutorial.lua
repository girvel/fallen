local shaders = require("tech.shaders")
local api = require("tech.railing").api
local mech = require("mech")


return function()
  return {
    {
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
  }
end
