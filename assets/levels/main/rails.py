import logging

from ecs import Entity

from src.engine.acting.actions.say import Say
from src.engine.ai.pather import PathTarget
from src.engine.rails_base import RailsBase
from src.entities.physical.brother import Brother
from src.entities.physical.mother import Mother
from src.lib.concurrency import wait_for
from src.lib.query import Query


class Rails(RailsBase):
    def __init__(self, level):
        self.characters = Entity(
            mother=level.query(lambda e: ~Query(e).character == Mother.character).unwrap(),
            brother=level.query(lambda e: ~Query(e).character == Brother.character).unwrap(),
            player=level.player,
        )

        self.positions = Entity(
            street=(181, 42),
        )

    def run(self):
        c = self.characters
        p = self.positions
        memory = c.player.ai.memory

        memory.cinematic_mode = True  # TODO cinematic mode

        yield {c.mother: Say("Хью, нам пора идти.")}
        yield {c.brother: Say("О, секунду, совсем забыл об одной замечательной вещице.")}
        yield {c.brother: Say("Мам, иди вперёд, я догоню.")}

        c.mother.ai.pather.going_to = PathTarget.Some(p.street)

        yield from ({c.player: Say(
            "Вы стоите в обшарпанной деревянной прихожей; цветочные горшки усеивают каждую горизонтальную поверхность;"
            " странное жёсткое чувство упирается в кадык."
        )} for _ in range(5))  # TODO mind
        # TODO fix that line

        yield {c.brother: Say("Вот, смотри.")}
        yield {c.player: Say("В твоих руках оказывается длинный свёрток льняной ткани.")}  # TODO mind

        memory.options = {"Развязать бечёвку": None}
        yield

        yield {c.player: Say("Это меч. Очень красивый.")}  # TODO mind

        memory.cinematic_mode = False
