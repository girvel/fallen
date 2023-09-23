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
        super().__init__(level)

        self.characters = Entity(
            mother=level.query(lambda e: ~Query(e).character == Mother.character).unwrap(),
            brother=level.query(lambda e: ~Query(e).character == Brother.character).unwrap(),
        )

        self.positions = Entity(
            street=(181, 42),
        )

    def run(self):
        c = self.characters
        p = self.positions
        memory = self.player.ai.memory

        yield from self.start_cutscene()

        yield {c.mother: Say("Хью, нам пора идти.")}
        yield {c.brother: Say("О, секунду, совсем забыл об одной замечательной вещице.")}
        yield {c.brother: Say("Мам, иди вперёд, я догоню.")}

        c.mother.ai.pather.going_to = PathTarget.Some(p.street)

        yield {self.player: Say(
            "Вы стоите в обшарпанной деревянной прихожей; цветочные горшки усеивают каждую горизонтальную поверхность;"
            " странное жёсткое чувство упирается в кадык."
        )}

        yield from wait_for(5)

        yield {c.brother: Say("Вот, смотри.")}
        yield {self.player: Say("В твоих руках оказывается длинный свёрток льняной ткани.")}

        yield from self.options({"Развязать бечёвку": None})  # TODO option not to look straight away

        yield {self.player: Say("Это меч. Очень красивый.", True)}

        yield from self.end_cutscene()
