from ecs import OwnedEntity

from src.engine.acting.actions.say import Say
from src.engine.ai.pather import PathTarget


class Rails(OwnedEntity):
    rails_flag = None

    def run(self):
        c = self.characters
        p = self.positions
        memory = c.player.ai.memory

        memory.cinematic_mode = True

        yield {c.mother: Say("Хью, нам пора идти.")}
        yield {c.brother: Say("О, секунду, совсем забыл об одной замечательной вещице.")}
        yield {c.brother: Say("Мам, иди вперёд, я догоню.")}

        c.mother.ai.pather.going_to = PathTarget.Some(p.street)
        yield from wait_for(lambda: c.mother.p == p.street)

        yield {c.mind: Say(
            "Вы стоите в обшарпанной деревянной прихожей; цветочные горшки усеивают каждую горизонтальную поверхность;"
            " странное жёсткое чувство упирается в кадык."
        )}

        yield {c.brother: Say("Вот, смотри.")}
        yield {c.mind: Say("В твоих руках оказывается длинный свёрток льняной ткани.")}

        memory.options = {"Развязать бечёвку": None}
        yield

        yield {c.mind: Say("Это меч. Очень красивый.")}

        memory.cinematic_mode = False
