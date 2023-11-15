from enum import Enum
from pathlib import Path

from ecs import Entity, exists

from assets.levels.main.library.physical.brother import Brother
from assets.levels.main.library.physical.girl import Girl
from assets.levels.main.library.physical.mother import Mother
from src.library.actions.attack import Attack
from src.library.actions.leave import Leave
from src.library.actions.no_action import NoAction
from src.library.actions.say import Say
from src.engine.acting.damage import Weapon, DamageKind
from src.library.ai_modules.follower import Follower
from src.library.ai_modules.pather import Pather
from src.engine.rails_base import RailsBase, Scene
from src.library.ais.dummy_ai import wait_finish
from src.library.ais.io import Quest, Notification
from src.library.items.bun import Bun
from src.library.items.lily import Lily
from src.library.physical.frog import Frog
from src.library.physical.rabid_dog import RabidDog
from src.library.special.level import Level
from src.lib import vector
from src.lib.concurrency import wait_for, wait_while
from src.lib.query import Q
from src.lib.vector import d2, add2


class DogQuestEnding(Enum):
    NotYetEnded = 0
    Win = 1
    Loss = 2
    DumbassDeath = 3


class Rails(RailsBase):
    dog_quest_ending: DogQuestEnding = DogQuestEnding.NotYetEnded

    def __post_init__(self):
        self.characters = Entity(
            player=self.get_player(),
            mother=next(self.level.find(Mother)),
            brother=next(self.level.find(Brother)),
            rabid_dog=next(self.level.find(RabidDog)),
            girl=None,
            frogs=list(self.level.find(Frog))
        )

        self.positions = Entity(
            street=(181, 42),
            before_away=(93, 28),
            away=(139, 0),
            vision_start=(33, 19),
            mother_reappearance=(191, 55),
            player_bed=(208, 57),
            beside_the_bed=(207, 58),
            kinds_yard_entrance=(185, 45),
            girl_appearance=(162, 42),
            girl_runs_away=(183, 54),
        )

        self.quests = Entity(
            find_someone_to_fight=Quest("Найти с чем подраться"),
        )

        self.vision_level = None


    @Scene.new()
    def introduction(self, scene):
        scene.enabled = False

        c = self.characters
        p = self.positions
        q = self.quests
        memory = c.player.ai.memory

        self.disable_complex_ai(c.mother)

        yield from self.start_cutscene()
        yield from self.center_camera()

        yield {c.brother: Say("О, секунду, совсем забыл.")}
        yield {c.player: Say("Улыбка брата излучает теплоту.", True)}
        yield {c.mother: Say("Хью, нам пора идти.")}
        yield {c.brother: Say("Мам, иди вперёд, я догоню.")}

        c.mother.ai.composite[Pather].going_to = p.street

        yield from wait_for(2)

        yield {c.player: Say(
            "Вы стоите в обшарпанной деревянной прихожей. Цветочные горшки усеивают каждую горизонтальную поверхность;"
            " странное жёсткое чувство упирается в кадык.",
            True,
        )}

        yield from wait_while(lambda: d2(c.mother.p, c.brother.p) < 7)

        yield {c.brother: Say("Вот, смотри.")}
        yield {c.player: Say("В твоих руках оказывается длинный свёрток льняной ткани.", True)}
        c.player.weapon = Weapon(8, DamageKind.Slashing)

        yield from self.options({
            (look := "Развязать бечёвку"): NoAction(),
            "Укоризненно смотреть на брата": NoAction(),
        })

        if memory.last_selected_option == look:
            c.player.traits.naivety += 1
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

            c.brother.ai.composite[Pather].going_to = p.before_away
            yield

            yield {c.player: Say(
                "Брат подскакивает и, блеснув зелёными глазами и одной рукой придерживая кожаную сумку, уходит.",
                True
            )}
            yield from wait_for(3)

            yield {c.player: Say("Ты проглатываешь подступившую слабость и снова смотришь на меч.", True)}
            yield from wait_for(3)

            c.mother.ai.composite[Follower].subject = c.brother

            yield {c.player: Say("Он красиво блестит.", True)}
        else:
            c.player.traits.pain += 1

            yield {c.player: Say("Брат морщится, пряча взгляд.", True)}

            yield {c.brother: Say("Мне надо это сделать.")}
            yield {c.brother: Say("")}
            yield {c.brother: Say("Не смотри на меня так.")}
            yield {c.brother: Say("")}
            yield {c.brother: Say("Ты не знаешь, о чём говоришь. Я тебе потом объясню.")}

            yield {c.mother: Say("Хью!")}
            yield {c.brother: Say("Это я!")}

            c.brother.ai.composite[Pather].going_to = p.before_away
            yield
            yield {c.player: Say("Брат поворачивается и уходит, растерянно взмахнув рукой.", True)}

            yield from wait_for(2)
            yield {c.player: Say("В его глазах видна боль.", True)}

            c.mother.ai.composite[Follower].subject = c.brother

            yield from self.options({"Развязать бечёвку": NoAction()})
            yield {c.player: Say("Это меч. Очень красивый.", True)}

        c.brother.ai.enable_speech = True
        yield from wait_for(10)
        memory.add_quest(q.find_someone_to_fight)

        yield from self.end_cutscene()

        memory.notification_queue.append(Notification("Управление",
            "<y>wasd </y>- движение<br/>"
            "<y>r </y>- достать/убрать оружие<br/>"
            "<y>мышь </y>- присмотреться к объекту"
        ))


    @Scene.new(lambda self: d2(self.characters.brother.p, self.positions.before_away) <= 2)
    def brother_path_middlepoint(self, scene):
        scene.enabled = False
        yield from wait_for(30)
        self.characters.brother.ai.composite[Pather].going_to = self.positions.away
        yield from ()


    @Scene.new(lambda self:
        exists(self.characters.brother)
        and self.characters.brother.level is self.characters.player.level
        and d2(self.characters.brother.p, self.positions.away) <= 20
        and d2(self.characters.brother.p, self.characters.player.p) <= self.characters.player.senses.vision
    )
    def brother_stops_player(self, scene):
        c = self.characters
        p = self.positions

        scene.enabled = False
        self.brother_leaves.enabled = False
        c.brother.ai.enable_speech = False
        yield from self.start_cutscene()
        yield from self.center_camera()

        c.mother.ai.composite[Follower].subject = None
        c.brother.ai.composite[Pather].going_to = c.player.p
        c.brother.ai.composite[Follower].subject = c.player

        yield from wait_while(lambda: d2(self.characters.brother.p, c.player.p) > 5 or c.brother.act is not None)

        yield {c.brother: Say("Перестань.")}
        yield {c.brother: Say("Я не могу взять тебя с собой.")}
        yield {c.brother: Say("Иди домой.")}

        c.player.traits.naivety += 1
        c.player.traits.pain += 1
        c.player.traits.curiosity += 1

        c.brother.ai.composite[Follower].subject = c.mother
        c.brother.ai.composite[Pather].going_to = c.mother.p
        c.mother.ai.composite[Pather].going_to = p.away

        self.brother_leaves.enabled = True

        yield from wait_while(lambda: exists(c.brother))

        yield from self.end_cutscene()


    @Scene.new(lambda self: any(
        d2(e.p, self.positions.away) <= 3 for e in [self.characters.brother, self.characters.mother]
    ))
    def brother_leaves(self, scene):
        c = self.characters

        scene.enabled = False

        yield from wait_for(25)
        yield {c.brother: Leave()}
        self.enable_complex_ai(c.mother)


    def is_player_killing_the_dog(self):
        return (
            self.characters.rabid_dog.health.amount.current <= 0
            and self.characters.player in self.characters.rabid_dog.health.last_damaged_by
        )

    @Scene.new(lambda self: (
        self.characters.player.health.amount.current <= 0
        or self.is_player_killing_the_dog()
    ))
    def player_dies(self, scene):
        scene.enabled = False

        c = self.characters
        p = self.positions
        memory = c.player.ai.memory

        if self.is_player_killing_the_dog():
            self.dog_quest_ending = DogQuestEnding.Win

            self.girl_gives_flower.enabled = True
        elif c.rabid_dog in c.player.health.last_damaged_by:
            self.dog_quest_ending = DogQuestEnding.Loss
        else:
            self.dog_quest_ending = DogQuestEnding.DumbassDeath

        yield from self.start_cutscene()

        memory.is_vision_disabled = True
        yield from c.player.ai.wait_seconds(2)

        self.disable_complex_ai(c.mother)
        c.mother.ai.composite[Pather].going_to = p.mother_reappearance

        c.player.health.amount.reset_to_max()

        self.vision_level = self.ms.add(Level(self.ms, Path("assets/levels/vision"), False, self.genesis))
        self.vision_level.rails.parent_level = c.player.level
        yield from self.plane_shift(self.vision_level, p.vision_start)


    @Scene.new(enabled=False)
    def player_wakes_up_1(self, scene):
        c = self.characters
        p = self.positions
        memory = c.player.ai.memory

        scene.enabled = False

        yield from self.center_camera()
        memory.is_vision_disabled = False

        yield {c.player: Say("Что происходит?")}
        c.mother.ai.composite[Pather].going_to = p.beside_the_bed
        yield from wait_finish(c.mother)

        self.vision_level.rails.talk_with_lord_bishop_1.enabled = True
        yield from self.plane_shift(self.vision_level, self.vision_level.rails.positions.observing_the_throne)


    @Scene.new(enabled=False)
    def player_wakes_up_2(self, scene):
        c = self.characters
        p = self.positions
        memory = c.player.ai.memory

        scene.enabled = False
        yield from self.center_camera()

        yield {c.player: Say("<Сдавленный вскрик>")}
        yield {c.player: Say("Зрение сходится; ты в своей комнате.", True)}

        yield {c.mother: Say("Всё хорошо.")}
        yield {c.mother: Say("Ты дома.")}
        yield {c.mother: Say("Ты в безопасности.")}

        yield {c.player: Say("Что происходит?")}

        yield {c.mother: Say("Ты бредишь.")}

        self.vision_level.rails.talk_with_lord_bishop_2.enabled = True

        yield from self.plane_shift(self.vision_level, self.vision_level.rails.positions.observing_the_throne)

        self.enable_complex_ai(c.mother)


    @Scene.new(lambda self: d2(self.characters.player.p, self.positions.kinds_yard_entrance) <= 2, enabled=False)
    def girl_gives_flower(self, scene):
        c = self.characters
        p = self.positions

        scene.enabled = False
        yield from self.start_cutscene()
        yield from self.center_camera()

        c.girl = Girl(p=p.girl_appearance, level=self.level)
        yield from self.create_entity(c.girl)
        c.girl.ai.composite[Pather].going_to = add2(c.player.p, vector.left)

        yield from wait_while(lambda: d2(c.girl.p, c.player.p) > 10)
        yield {c.player: Say("Девочка твоего возраста.", True)}
        yield {c.player: Say("Взъерошенные рыжие волосы, грязь на лице, грубое льняное платье.", True)}

        yield from wait_finish(c.girl)

        yield from c.player.ai.wait_seconds(1)
        yield {c.girl: Say(f"Я {c.girl.name.first}.")}

        yield from c.player.ai.wait_seconds(1.5)
        yield {c.player: Say(f"{c.girl.name.first}, пряча взгляд, суёт тебе что-то в руку и убегает.", True)}
        c.player.inventory.add_item(Lily())

        c.girl.ai.composite[Pather].going_to = p.girl_runs_away
        yield from wait_finish(c.girl)
        yield {c.girl: Leave()}

        yield from self.end_cutscene()


    @Scene.new(lambda self: ~Q(self.characters.player.act)[Attack].target.character == Frog.character)
    def player_attacks_frog(self, scene):
        c = self.characters

        scene.enabled = False

        c.player.traits.brutality += 1

        yield from self.start_cutscene()
        yield from self.center_camera()

        if self.dog_quest_ending == DogQuestEnding.NotYetEnded:
            yield {c.player: Say("Нет, этого недостаточно.")}
        else:
            yield {c.player: Say("Хм.")}

        yield from self.end_cutscene()

        self.player_attacks_frog_again.enabled = True


    @Scene.new(
        lambda self: ~Q(self.characters.player.act)[Attack].target.character == Frog.character,
        enabled=False,
    )  # TODO write & use is_attacking
    def player_attacks_frog_again(self, scene):
        scene.enabled = False

        c = self.characters

        c.player.traits.brutality += 1

        yield from self.start_cutscene()
        yield from self.center_camera()

        yield {c.player: Say("А в этом что-то есть.")}

        yield from self.end_cutscene()


    @Scene.new(
        lambda self: d2(self.characters.mother.p, self.characters.player.p) < 5,
        enabled=False,
    )
    def mother_gives_player_bun(self, scene):
        scene.enabled = False

        c = self.characters

        self.disable_complex_ai(c.mother)

        yield from self.start_cutscene()
        yield from self.center_camera()

        yield {c.mother: Say("Я булочки испекла. Кушай, приходи в себя.")}

        mother_initial_p = c.mother.p
        c.mother.ai.composite[Pather].going_to = c.player.p

        yield from wait_finish(c.mother)
        c.player.inventory.add_item(Bun())
        c.mother.ai.composite[Pather].going_to = mother_initial_p

        yield from wait_finish(c.mother)
        if self.dog_quest_ending == DogQuestEnding.DumbassDeath:
            yield {c.mother: Say("Кстати, это было глупо.")}

        yield from self.end_cutscene()
        self.enable_complex_ai(c.mother)
