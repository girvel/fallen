import logging

from ecs import Entity

from assets.levels.vision.entities.physical.soldier import Soldier
from src.engine.ai.pather import PathTarget
from src.engine.rails_base import RailsBase, scene
from src.entities.physical.player import Player
from src.lib.concurrency import wait_while, wait_for
from src.lib.query import Query


class Rails(RailsBase):
    def __init__(self, level, ms):
        super().__init__(level, ms)

        self.characters = Entity(
            soldiers=level.query_all(lambda e: ~Query(e).character == Soldier.character),
        )

        self.positions = Entity()
        self.quests = Entity()

    @scene(lambda self: True)
    def start_vision(self, scene):
        c = self.characters

        scene.enabled = False

        yield
        self.player = self.level.query(lambda e: ~Query(e).character == Player.character).unwrap()

        for soldier in c.soldiers:
            @self.run_subscene(soldier)
            def run_lap(soldier):
                start_point = soldier.p
                soldier.ai.pather.going_to = PathTarget.Some((94, 17))
                yield
                yield from wait_while(lambda: soldier.ai.is_busy)

                soldier.ai.pather.going_to = PathTarget.Some(start_point)
                yield from wait_while(lambda: soldier.ai.is_busy)
