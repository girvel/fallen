from levels.afterlife.assets.physical.old_sarr import OldSarr
from src.engine import permanent_storage
from src.engine.input.hotkeys import GameEnd
from src.engine.rails.rails_base import RailsBase
from src.engine.rails.scene import Scene
from src.assets.actions.no_action import NoAction
from src.assets.actions.say import Say
from src.assets.physical.player import Player


class Rails(RailsBase):
    def __post_init__(self):
        self.normal_comments = [
            ["Умер? Ну ладно, это случается."],
            ["О, ты снова умер."],
            ["О, это снова ты."],
            ["Привет."],
            ["О."],
            ["Привет."],
            ["Тяжело быть смертным, а?"],
            ["Мне всегда было интересно, каково это -- умереть?"],
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

    def after_creation(self):
        self.characters = {
            'player': self.get_player,
            'old_sarr': next(self.level.find(OldSarr)),
        }


    @Scene.new()
    class talk_with_old_sarr:
        player: Player
        old_sarr: OldSarr

        def run(self, rails: "Rails"):
            player_time_alive = self.player.tick_counter

            yield from rails.start_cutscene()
            yield from rails.center_camera()

            yield {self.player: Say("Диковинная мастерская, озарённая оранжеватым светом.", True)}
            yield {self.player: Say("Тебе кажется, что ты здесь не один.", True)}

            if player_time_alive <= 25:
                counter = permanent_storage.read_key("ultra_fast_death_counter", -1) + 1  # TODO should be 0
                permanent_storage.write_key("ultra_fast_death_counter", counter)

                yield {self.old_sarr: Say(
                    rails.ultra_fast_death_comments[counter]
                    if counter < len(rails.ultra_fast_death_comments) else
                    "..."
                )}

            elif (
                player_time_alive < 100 and
                player_time_alive < permanent_storage.read_key("death_time_record", float('inf'))
            ):
                permanent_storage.write_key("death_time_record", player_time_alive)

                counter = permanent_storage.read_key("fast_death_counter", -1) + 1
                permanent_storage.write_key("fast_death_counter", counter)

                yield {self.old_sarr: Say(
                    rails.fast_death_comments[counter]
                    if counter < len(rails.fast_death_comments) else
                    "..."
                )}

            else:
                counter = permanent_storage.read_key("normal_death_counter", -1) + 1
                permanent_storage.write_key("normal_death_counter", counter)

                if counter < len(rails.normal_comments):
                    for line in rails.normal_comments[counter]:
                        yield {self.old_sarr: Say(line)}

                else:
                    yield {self.player: Say("Ты чувствуешь на себе злобный взгляд.", True)}

            yield {self.old_sarr: Say("Действуем?")}

            option = yield from rails.options({
                (agree := "Ага."): NoAction(),
                (ask := "А что происходит?"): NoAction(),
                "Осмотреться": NoAction(),
            })

            if option == ask:
                yield {self.old_sarr: Say("Рот закрой.")}
            elif option == agree:
                yield {self.old_sarr: Say("Ага.")}
            else:
                for line in [
                    "С тобой определённо точно кто-то разговаривает, кто-то стоящий неподалёку.",
                    "Он материален и - скорее всего - человекоподобен, но ты не можешь его рассмотреть.",
                    "Как будто бы ты видишь его глазами, но твоё сознание не способно на нём сфокусироваться.",
                    "Стены высечены из чёрного камня, окон нет. Вдоль одной из граней пола идёт массивная бронзовая "
                        "труба.",
                    "На ней открыта задвижка; в трубе -- быстрый поток света, мерцающий оттенками.",
                    "Столы завалены металлическими инструментами и приборами непонятного назначения.",
                    "В углу стоит мягко светящееся пурпурное растение в горшке.",
                    "Мощёный серый пол подмораживает босые стопы.",
                ]:
                    yield {self.player: Say(line, True)}

                yield from self.player.ai.wait_seconds(2)

            yield {self.player: Say("Собеседник дёргает за рычаг.", True)}
            yield
            raise GameEnd
