import random

from ecs import Entity

from src.engine.acting.actions.build import Build
from src.engine.acting.actions.say import Say
from src.engine.ai.pather import PathTarget
from src.engine.rails_base import RailsBase, scene
from src.entities.ais.dummy_ai import wait_finish
from src.entities.physical.backslash_wall import BackslashWall
from src.entities.physical.horizontal_wall import HorizontalWall
from src.entities.physical.kaledeii import Kaledeii
from src.entities.physical.lord_bishop import LordBishop
from src.entities.physical.player import Player
from src.entities.physical.slash_wall import SlashWall
from src.entities.physical.soldier import Soldier
from src.entities.physical.vertical_wall import VerticalWall
from src.entities.special.level import Level
from src.lib.concurrency import wait_for, wait_seconds, wait_while
from src.lib.vector import add2, right, d2


class Rails(RailsBase):
    def __post_init__(self):
        self.characters = Entity(
            soldiers=list(self.level.find(Soldier)),
            kaledeii=next(self.level.find(Kaledeii)),
            bishop=next(self.level.find(LordBishop)),
        )

        self.positions = Entity(
            entrance=(87, 17),
            kaledeii_entrance=(16, 17),
            fortification_positions=[
                (74, 17), (75, 17), (76, 17), (76, 18), (76, 16),
            ],
            before_the_throne=(147, 17),
            observing_the_throne=(148, 19),
            observing_the_entrance=(109, 18),
        )

        self.quests = Entity()


    @scene()
    def start_vision(self, scene):
        c = self.characters
        p = self.positions

        scene.enabled = False

        self.player = next(self.level.find(Player))  # TODO make this automatic
        c.player = self.player
        memory = c.player.ai.memory
        memory.is_vision_disabled = False

        c.kaledeii.ai.pather.going_to = PathTarget.Some(p.kaledeii_entrance)
        yield from wait_finish(c.kaledeii)

        yield {c.kaledeii: Say("За мной.")}
        c.kaledeii.ai.pather.going_to = PathTarget.Some(p.entrance)
        yield from wait_for(2)

        for s in c.soldiers:
            s.ai.follower.subject = c.kaledeii

        c.player.ai.dummy.follower.subject = c.kaledeii
        yield from wait_finish(c.kaledeii)
        yield from wait_finish(*c.soldiers, threshold=2)

        for s in c.soldiers:
            s.ai.follower.subject = None

        builder1, builder2, *rest = c.soldiers

        yield {c.kaledeii: Say(f"{builder1.name.last} и {builder2.name.last}, блокируйте проход.")}

        @self.run_subscene(builder1, p.fortification_positions[:3])
        @self.run_subscene(builder2, p.fortification_positions[3:])
        def build_fortifications(executor, positions):
            for position in positions:
                executor.ai.pather.going_to = PathTarget.Some(add2(right, position))
                yield from wait_finish(builder1)
                yield {executor: Build(
                    position,
                    random.choice([HorizontalWall, VerticalWall, SlashWall, BackslashWall]),
                )}

        yield {c.kaledeii: Say("Остальные -- оборонительные позиции, оружие наготове.")}

        c.kaledeii.ai.pather.going_to = PathTarget.Some(p.before_the_throne)
        yield from wait_seconds(2)

        yield {c.player: Say("Стены сотрясаются от мощного удара вдали.", True)}
        yield

        memory.is_vision_disabled = True
        c.player.ai.dummy.clear()
        # noinspection PyUnresolvedReferences
        self.parent_level.rails.scene_by_name("player_wakes_up_1").enabled = True
        Level.change(c.player, self.parent_level, self.parent_level.rails.positions.player_bed)


    @scene(enabled=False)
    def talk_with_lord_bishop_1(self, scene):
        c = self.characters
        p = self.positions
        memory = c.player.ai.memory

        scene.enabled = False

        yield from wait_finish(c.kaledeii)
        memory.is_vision_disabled = False

        yield {c.kaledeii: Say("Ваше Превосходительство, следуйте за мной.")}
        yield {c.bishop: Say("Глупости! Кем он себя возомнил!")}
        yield {c.bishop: Say("Я останусь на своём положенном месте и не сдвинусь ни на шаг.")}
        yield {c.bishop: Say("Он защитит нас.")}

        yield from wait_seconds(1)

        yield {c.player: Say("Стены сотрясаются вновь.", True)}
        self.parent_level.rails.scene_by_name("player_wakes_up_2").enabled = True
        Level.change(c.player, self.parent_level, self.parent_level.rails.positions.player_bed)


    @scene(enabled=False)
    def talk_with_lord_bishop_2(self, scene):
        c = self.characters
        p = self.positions
        memory = c.player.ai.memory

        scene.enabled = False

        c.player.ai.dummy.pather.going_to = PathTarget.Some(p.observing_the_entrance)

        yield {c.kaledeii: Say("Вы не понимаете тяжесть нашей ситуации, лорд-епископ.")}
        yield {c.kaledeii: Say(
            "Стены Ковенанта пали, половина гарнизона мертва, я -- последний стоящий на ногах рыцарь, и я не справлюсь "
            "с ним в одиночку."
        )}

        yield from wait_for(7)
        yield {c.bishop: Say("Так и быть, я вам помогу.")}

        yield from wait_for(5)
        c.kaledeii.ai.pather.going_to = PathTarget.Some(p.observing_the_entrance)

        yield from wait_while(d2(c.player.p, p.observing_the_entrance) > 2)

        c.player.ai.dummy.clear()
