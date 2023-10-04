import logging
from pathlib import Path

from ecs import Entity, exists

from src.engine.acting.actions.leave import Leave
from src.engine.acting.actions.no_action import NoAction
from src.engine.acting.actions.say import Say
from src.engine.acting.damage import Weapon, DamageKind
from src.engine.ai.pather import PathTarget
from src.engine.rails_base import RailsBase, scene
from assets.levels.main.entities.physical.brother import Brother
from assets.levels.main.entities.physical.mother import Mother
from src.entities.ais.io import Quest
from src.entities.special.level import Level
from src.lib.concurrency import wait_for, wait_while
from src.lib.query import Query
from src.lib.vector import d2, grid_set, map_grid


class Rails(RailsBase):
    def __init__(self, level, ms):
        super().__init__(level, ms)

        self.characters = Entity(
            player=self.player,
            mother=level.query(lambda e: ~Query(e).character == Mother.character).unwrap(),
            brother=level.query(lambda e: ~Query(e).character == Brother.character).unwrap(),
        )

        self.positions = Entity(
            street=(181, 42),
            before_away=(93, 28),
            away=(139, 0),
            vision_start=(33, 19),
        )

        self.quests = Entity(
            find_someone_to_fight=Quest("Найти и порубить кого-нибудь")
        )

        self.vision_level = None

    @scene(lambda self: True)
    def introduction(self):
        c = self.characters
        p = self.positions
        q = self.quests
        memory = c.player.ai.memory

        self.disable_current_scene()
        yield from self.start_cutscene()
        yield from self.center_camera()

        yield {c.brother: Say("О, секунду, совсем забыл.")}
        yield {c.player: Say("Улыбка брата излучает теплоту.", True)}
        yield {c.mother: Say("Хью, нам пора идти.")}
        yield {c.brother: Say("Мам, иди вперёд, я догоню.")}

        c.mother.ai.pather.going_to = PathTarget.Some(p.street)

        yield from wait_for(2)

        yield {c.player: Say(
            "Вы стоите в обшарпанной деревянной прихожей; цветочные горшки усеивают каждую горизонтальную поверхность;"
            " странное жёсткое чувство упирается в кадык.",
            True
        )}

        yield from wait_while(lambda: d2(c.mother.p, c.brother.p) < 7)

        yield {c.brother: Say("Вот, смотри.")}
        yield {c.player: Say("В твоих руках оказывается длинный свёрток льняной ткани.", True)}
        c.player.weapon = Weapon(5, DamageKind.Slashing)

        yield from self.options({
            (look := "Развязать бечёвку"): NoAction(),
            "Укоризненно смотреть на брата": NoAction(),
        })

        if memory.last_selected_option == look:
            c.player.traits.naivity.move(1)
            yield {c.player: Say("Это меч. Очень красивый.", True)}

            yield {c.brother: Say("Кавалерийская шашка. Настоящая.")}
            yield {c.brother: Say("Это вещь.")}

            yield {c.player: Say("Это вещь.")}
            yield {c.player: Say("Где ты его достал?")}

            yield {c.brother: Say("Не спрашивай.")}
            yield {c.brother: Say("И не показывай маме.")}

            yield {c.mother: Say("Хью!")}

            yield {c.brother: Say("Это я!")}
            yield {c.brother: Say("Приглядывай пока за хозяйством, а?")}

            c.brother.ai.pather.going_to = PathTarget.Some(p.before_away)
            yield

            yield {c.player: Say(
                "Брат подскакивает и, блеснув зелёными глазами и одной рукой придерживая кожаную сумку, уходит.",
                True
            )}
            yield from wait_for(3)

            yield {c.player: Say("Ты проглатываешь подступившую слабость и снова смотришь на меч.", True)}
            yield from wait_for(3)

            c.mother.ai.follower.subject = c.brother

            yield {c.player: Say("Он красиво блестит.", True)}
        else:
            c.player.traits.pain.move(1)

            yield {c.brother: Say("Это шашка...")}
            yield {c.player: Say("Брат морщится, пряча взгляд.", True)}

            yield {c.brother: Say("Мне надо это сделать.")}
            yield {c.brother: Say("")}
            yield {c.brother: Say("Не смотри на меня так.")}
            yield {c.brother: Say("")}
            yield {c.brother: Say("Ты не знаешь, о чём говоришь. Я тебе потом объясню.")}

            yield {c.mother: Say("Хью!")}
            yield {c.brother: Say("Это я!")}

            c.brother.ai.pather.going_to = PathTarget.Some(p.before_away)
            yield
            yield {c.player: Say("Брат поворачивается и уходит, растерянно взмахнув рукой.", True)}

            yield from wait_for(2)
            yield {c.player: Say("В его глазах видна боль.", True)}

            c.mother.ai.follower.subject = c.brother

            yield from self.options({"Развязать бечёвку": NoAction()})
            yield {c.player: Say("Это меч. Очень красивый.", True)}

        yield from wait_for(10)
        memory.add_quest(q.find_someone_to_fight)

        yield from self.end_cutscene()


    @scene(lambda self: d2(self.characters.brother.p, self.positions.before_away) <= 2)
    def brother_path_middlepoint(self):
        self.disable_current_scene()
        self.characters.brother.ai.pather.going_to = PathTarget.Some(self.positions.away)
        yield  # TODO non-async scenes


    @scene(lambda self:
        exists(self.characters.brother)
        and self.characters.brother.level is self.characters.player.level
        and d2(self.characters.brother.p, self.positions.away) <= 20
        and d2(self.characters.brother.p, self.characters.player.p) <= self.characters.player.senses.vision
    )
    def brother_stops_player(self):
        c = self.characters
        p = self.positions

        self.disable_current_scene()
        yield from self.start_cutscene()
        yield from self.center_camera()

        c.mother.ai.follower.subject = None
        c.brother.ai.pather.going_to = PathTarget.Some(c.player.p)
        c.brother.ai.follower.subject = c.player

        yield from wait_while(lambda: d2(self.characters.brother.p, c.player.p) > 5 or c.brother.act is not None)

        yield {c.brother: Say("Перестань.")}
        yield {c.brother: Say("Я не могу взять тебя с собой.")}
        yield {c.brother: Say("Иди домой.")}

        c.player.traits.naivity.move(1)
        c.player.traits.pain.move(1)
        c.player.traits.chaos.move(1)

        c.brother.ai.follower.subject = c.mother
        c.brother.ai.pather.going_to = PathTarget.Some(c.mother.p)
        c.mother.ai.pather.going_to = PathTarget.Some(p.away)

        yield from wait_while(lambda:
            d2(self.characters.brother.p, self.positions.away) > 3
            and d2(self.characters.brother.p, c.player.p) <= c.player.senses.vision + 10
        )

        yield from self.end_cutscene()


    @scene(lambda self: any(
        d2(e.p, self.positions.away) <= 3 for e in [self.characters.brother, self.characters.mother]
    ))
    def brother_and_mother_leave(self):
        c = self.characters

        self.disable_current_scene()

        yield {c.mother: Leave(), c.brother: Leave()}


    @scene(lambda self: self.characters.player.health.amount.current <= 0)
    def player_dies(self):
        c = self.characters
        p = self.positions

        self.disable_current_scene()
        yield from self.start_cutscene()

        self.vision_level = self.ms.add(Level(self.ms, Path("assets/levels/vision"), False))
        yield

        c.player.health.amount.reset_to_max()
        Level.change(c.player, self.vision_level, p.vision_start)



        yield from self.end_cutscene()
