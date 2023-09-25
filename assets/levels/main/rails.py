from ecs import Entity

from src.engine.acting.actions.leave import Leave
from src.engine.acting.actions.say import Say
from src.engine.acting.damage import Weapon, DamageKind
from src.engine.ai.pather import PathTarget
from src.engine.rails_base import RailsBase, scene
from assets.levels.main.entities.physical.brother import Brother
from assets.levels.main.entities.physical.mother import Mother
from src.lib.concurrency import wait_for, wait_while
from src.lib.query import Query
from src.lib.vector import d2


class Rails(RailsBase):
    def __init__(self, level):
        super().__init__(level)

        self.characters = Entity(
            mother=level.query(lambda e: ~Query(e).character == Mother.character).unwrap(),
            brother=level.query(lambda e: ~Query(e).character == Brother.character).unwrap(),
        )

        self.positions = Entity(
            street=(181, 42),
            away=(1, 5),
        )

    @scene(lambda self: True)
    def introduction(self):
        self.scene_by_name("introduction").enabled = False

        c = self.characters
        p = self.positions
        memory = self.player.ai.memory

        yield from self.start_cutscene()
        yield from self.center_camera()

        yield {c.brother: Say("О, секунду, совсем забыл.")}
        yield {self.player: Say("Улыбка брата излучает теплоту.", True)}
        yield {c.mother: Say("Хью, нам пора идти.")}
        yield {c.brother: Say("Мам, иди вперёд, я догоню.")}

        c.mother.ai.pather.going_to = PathTarget.Some(p.street)

        yield from wait_for(2)

        yield {self.player: Say(
            "Вы стоите в обшарпанной деревянной прихожей; цветочные горшки усеивают каждую горизонтальную поверхность;"
            " странное жёсткое чувство упирается в кадык.",
            True
        )}

        yield from wait_while(lambda: d2(c.mother.p, c.brother.p) < 7)

        yield {c.brother: Say("Вот, смотри.")}
        yield {self.player: Say("В твоих руках оказывается длинный свёрток льняной ткани.", True)}
        self.player.weapon = Weapon(5, DamageKind.Slashing)

        yield from self.options({
            (look := "Развязать бечёвку"): None,
            "Укоризненно смотреть на брата": None,
        })

        if memory.last_selected_option == look:
            self.player.traits.naivity += 1
            yield {self.player: Say("Это меч. Очень красивый.", True)}

            yield {c.brother: Say("Кавалерийская шашка. Настоящая.")}
            yield {c.brother: Say("Это вещь.")}

            yield {self.player: Say("Это вещь.")}
            yield {self.player: Say("Где ты его достал?")}

            yield {c.brother: Say("Не спрашивай.")}
            yield {c.brother: Say("И не показывай маме.")}

            yield {c.mother: Say("Хью!")}

            yield {c.brother: Say("Это я!")}
            yield {c.brother: Say("Приглядывай пока за хозяйством, а?")}

            c.brother.ai.pather.going_to = PathTarget.Some(p.away)
            yield

            yield {self.player: Say(
                "Брат подскакивает и, блеснув зелёными глазами и одной рукой придерживая кожаную сумку, бежит в сторону речки.",
                True
            )}
            yield from wait_for(3)

            yield {self.player: Say("Ты проглатываешь подступившую слабость и снова смотришь на меч.", True)}
            yield from wait_for(3)

            c.mother.ai.follower.subject = c.brother

            yield {self.player: Say("Он красиво блестит.", True)}
        else:
            self.player.traits.pain += 1

            yield {c.brother: Say("Это шашка...")}
            yield {self.player: Say("Брат морщится, пряча взгляд.", True)}

            yield {c.brother: Say("Мне надо это сделать.")}
            yield {c.brother: Say("")}
            yield {c.brother: Say("Не смотри на меня так.")}
            yield {c.brother: Say("")}
            yield {c.brother: Say("Ты не знаешь, о чём говоришь. Я тебе потом объясню.")}

            yield {c.mother: Say("Хью!")}
            yield {c.brother: Say("Это я!")}

            c.brother.ai.pather.going_to = PathTarget.Some(p.away)
            yield
            yield {self.player: Say("Брат поворачивается и уходит, растерянно взмахнув рукой.", True)}

            yield from wait_for(2)
            yield {self.player: Say("В его глазах видна боль.", True)}

            c.mother.ai.follower.subject = c.brother

            yield from self.options({"Развязать бечёвку": None})
            yield {self.player: Say("Это меч. Очень красивый.", True)}

        yield from wait_for(10)

        yield from self.end_cutscene()

        # TODO make them leave the level
        # TODO scene begins when the player comes to the hall?

    @scene(lambda self: all(
        d2(e.p, self.positions.away) <= 3 for e in [self.characters.brother, self.characters.mother]
    ))
    def brother_and_mother_leave(self):
        c = self.characters

        self.scene_by_name("brother_and_mother_leave").enabled = False  # TODO more portable way to do it

        yield {c.mother: Leave(), c.brother: Leave()}
