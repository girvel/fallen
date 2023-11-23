from ecs import Entity

from assets.levels.death.library.physical.old_sarr import OldSarr
from src.engine import permanent_storage
from src.engine.input.hotkeys import GameEnd
from src.engine.rails_base import RailsBase, Scene
from src.library.actions.no_action import NoAction
from src.library.actions.say import Say


class Rails(RailsBase):
    def __post_init__(self):
        self.characters = Entity(
            old_sarr=next(self.level.find(OldSarr)),
        )

        self.normal_comments = [
            ["Умер? Ну ладно, это случается."],
            ["О, ты снова умер."],
            ["О, это снова ты."],
            ["Привет."],
            ["О."],
            ["Привет."],
            ["Тяжело быть смертным, а?"],
            ["Мне всегда было интересно, какого это -- умереть?"],
            ["У тебя не очень хорошо выходит, да?"],
            ["У тебя правда всё не очень хорошо выходит."],
            ["Уугх."],
            ["Если честно, слегка надоедает."],
            ["Как часто можно умирать?"],
            ["Мне надоело."],
            ["Это вообще не самый опасный мир, как ты умудряешься?"],
            ["Ты мне назло умираешь?"],
            ["Серьёзно?"],
            ["У тебя суицидальные наклонности, да?"],
            ["Мм."],
            ["Мммм."],
            ["Ты в курсе, что ты не единственный, кого мне надо перезапускать?",
             "Чтоб ты понимал, твой брат ещё более пришибленный, чем ты.",
             "Ты представляешь, как тяжело сводить две асинхронные петли?"],
            ["Чёрт тебя дери."],
            ["Пекло."],
            ["Да хватит уже!"],
            ["Ящерица поганая."],
            ["Я с вами, идиотами, работать больше не буду."],
        ]

        self.ultra_fast_death_comments = [
            "Ты как так смог?",
            "Это не смешно.",
            "Ты издеваешься надо мной?",
        ]

        self.fast_death_comments = [
            "Ты быстро, однако.",
            "Ты только что тут был.",
            "Это новый рекорд.",
        ]

    @Scene.new()
    def talk_with_old_sarr(self, scene):
        scene.enabled = False
        self.characters.player = self.get_player()

        c = self.characters
        memory = c.player.ai.memory

        player_time_alive = c.player.tick_counter

        yield from self.start_cutscene()
        yield from self.center_camera()

        yield {c.player: Say("Диковинная мастерская, озарённая оранжеватым светом.", True)}
        yield {c.player: Say("Тебе кажется, что ты здесь не один.", True)}

        if player_time_alive <= 25:
            counter = permanent_storage.read_key("ultra_fast_death_counter", -1) + 1
            permanent_storage.write_key("ultra_fast_death_counter", counter)

            yield {c.old_sarr: Say(
                self.ultra_fast_death_comments[counter]
                if counter < len(self.ultra_fast_death_comments) else
                "..."
            )}

        elif (
            player_time_alive < 100 and
            player_time_alive < (record := permanent_storage.read_key("death_time_record", float('inf')))
        ):
            permanent_storage.write_key("death_time_record", player_time_alive)

            counter = permanent_storage.read_key("fast_death_counter", -1) + 1
            permanent_storage.write_key("fast_death_counter", counter)

            yield {c.old_sarr: Say(
                self.fast_death_comments[counter]
                if counter < len(self.fast_death_comments) else
                "..."
            )}

        else:
            counter = permanent_storage.read_key("normal_death_counter", -1) + 1
            permanent_storage.write_key("normal_death_counter", counter)

            if counter < len(self.normal_comments):
                for line in self.normal_comments[counter]:
                    yield {c.old_sarr: Say(line)}

            else:
                yield {c.player: Say("Ты чувствуешь на себе злобный взгляд.", True)}

        yield {c.old_sarr: Say("Действуем?")}

        yield from self.options({
            (agree := "Ага."): NoAction(),
            (ask := "А что происходит?"): NoAction(),
            "Осмотреться": NoAction(),
        })

        if memory.last_selected_option == ask:
            yield {c.old_sarr: Say("Рот закрой.")}
        elif memory.last_selected_option == agree:
            yield {c.old_sarr: Say("Ага.")}
        else:
            for line in [
                "С тобой определённо точно кто-то разговаривает, кто-то стоящий неподалёку.",
                "Он материален и скорее всего человекоподобен, но ты не можешь его рассмотреть.",
                "Как будто бы ты видишь его глазами, но твоё сознание не способно на нём сфокусироваться.",
                "Стены высечены из чёрного камня, окон нет. Вдоль одной из граней пола идёт массивная бронзовая труба.",
                "На ней открыта задвижка; в трубе -- быстрый поток света, мерцающий оттенками.",
                "Столы завалены металлическими инструментами и приборами непонятного назначения.",
                "В углу стоит мягко светящееся пурпурное растение в горшке.",
                "Мощёный серый пол подмораживает босые стопы.",
            ]:
                yield {c.player: Say(line, True)}

            yield from c.player.ai.wait_seconds(2)

        yield {c.player: Say("Собеседник дёргает за рычаг.", True)}
        yield
        raise GameEnd
