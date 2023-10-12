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
from src.entities.physical.player import Player
from src.entities.physical.slash_wall import SlashWall
from src.entities.physical.soldier import Soldier
from src.entities.physical.vertical_wall import VerticalWall
from src.entities.special.level import Level
from src.lib.concurrency import wait_for, wait_seconds
from src.lib.vector import add2, right


class Rails(RailsBase):
    def __post_init__(self):
        self.characters = Entity(
            soldiers=list(self.level.find(Soldier)),
            kaledeii=next(self.level.find(Kaledeii)),
        )

        self.positions = Entity(
            entrance=(87, 17),
            kaledeii_entrance=(16, 17),
            fortification_positions=[
                (74, 17), (75, 17), (76, 17), (76, 18), (76, 16),
            ],
            before_the_throne=(147, 17),
            observing_the_throne=(148, 19),
        )

        self.quests = Entity()

    @scene()
    def start_vision(self, scene):
        c = self.characters
        p = self.positions

        scene.enabled = False

        self.player = next(self.level.find(Player))  # TODO make this automatic
        c.player = self.player

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

        c.player.ai.dummy.clear()
        # noinspection PyUnresolvedReferences
        self.parent_level.rails.scene_by_name("player_wakes_up_1").enabled = True
        Level.change(c.player, self.parent_level, self.parent_level.rails.positions.player_bed)
