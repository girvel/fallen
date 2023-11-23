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

        self.death_counter = permanent_storage.read_key("death_counter", 0) + 1
        permanent_storage.write_key("death_counter", self.death_counter)

        # self.sarr_comments = [
        #
        # ]

    @Scene.new()
    def talk_with_old_sarr(self, scene):
        scene.enabled = False
        self.characters.player = self.get_player()

        c = self.characters
        memory = c.player.ai.memory

        yield from self.start_cutscene()
        yield from self.center_camera()

        yield {c.player: Say("Диковинная мастерская, озарённая оранжеватым светом.", True)}
        yield {c.player: Say("Тебе кажется, что ты здесь не один.", True)}

        # TODO NEXT special deaths

        yield {c.old_sarr: Say("Умер? Ну ладно, это случается.")}
        yield {c.old_sarr: Say("Действуем?")}

        yield from self.options({
            (ask := "А что происходит?"): NoAction(),
            (agree := "Ага."): NoAction(),
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
