import logging

from ecs import Entity

from src.engine.acting.actions.build import Build
from src.engine.acting.actions.cast_fire_storm import CastFireStorm
from src.entities.physical.kaledeii import Kaledeii
from src.entities.physical.soldier import Soldier
from src.engine.acting.actions.say import Say
from src.engine.ai.pather import PathTarget
from src.engine.rails_base import RailsBase, scene
from src.entities.ais.dummy_ai import wait_finish
from src.entities.physical.player import Player
from src.entities.physical.thick_wall import ThickWall
from src.lib.concurrency import wait_for, wait_seconds


class Rails(RailsBase):
    def __init__(self, level, ms):
        super().__init__(level, ms)

        self.characters = Entity(
            soldiers=list(level.find(Soldier)),
            kaledeii=next(level.find(Kaledeii)),
        )

        self.positions = Entity(
            entrance=(87, 17),
            kaledeii_entrance=(16, 17),
        )

        self.quests = Entity()

    @scene(lambda self: True)
    def start_vision(self, scene):
        c = self.characters
        p = self.positions

        scene.enabled = False

        self.player = next(self.level.find(Player))  # TODO make this automatic
        c.player = self.player

        c.kaledeii.ai.pather.going_to = PathTarget.Some(p.kaledeii_entrance)
        yield from wait_finish(c.kaledeii)

        yield {c.kaledeii: Say("За мной.")}
        yield {c.kaledeii: CastFireStorm()}
        yield from wait_seconds(10)
        # yield from wait_for(2)
        #
        # for s in c.soldiers:
        #     s.ai.follower.subject = c.kaledeii
        #
        # c.player.ai.dummy.follower.subject = c.kaledeii
        #
        # c.kaledeii.ai.pather.going_to = PathTarget.Some(p.entrance)
        # yield from wait_finish(c.kaledeii, *c.soldiers)
        #
        # for s in c.soldiers:
        #     s.ai.follower.subject = None
        #
        # c.player.ai.dummy.follower.subject = None

        yield from self.end_cutscene()
