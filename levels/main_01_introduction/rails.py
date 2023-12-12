from enum import Enum
from pathlib import Path
from typing import Annotated

from ecs import Entity, exists

from levels.main_01_introduction.library.physical.brother import Brother
from levels.main_01_introduction.library.physical.girl import Girl
from levels.main_01_introduction.library.physical.mother import Mother
from src.engine.acting.aggressive import Aggressive
from src.engine.acting.damage import Weapon
from src.engine.acting import damage_kind
from src.engine.rails.rails_base import RailsBase
from src.engine.rails.scene import Scene, keep_ai, maybe_exists
from src.lib import vector
from src.lib.concurrency import wait_for, wait_while
from src.lib.query import Q
from src.lib.vector.vector import d2, add2, int2
from src.library.actions.leave import Leave
from src.library.actions.no_action import NoAction
from src.library.actions.say import Say
from src.library.actions.teleport import Teleport
from src.library.ai_modules.follower import Follower
from src.library.ai_modules.pather import Pather
from src.library.ais.dummy_ai import wait_finish
from src.library.ais.io import Quest, Notification
from src.library.items.bun import Bun
from src.library.items.lily import Lily
from src.library.physical.frog import Frog
from src.library.physical.player import Player
from src.library.physical.rabid_dog import RabidDog
from src.library.special.level import Level


class VisionVersion(Enum):
    Undefined = 0
    Continuous = 1
    Interrupted = 2


class Rails(RailsBase):
    vision_version: VisionVersion = VisionVersion.Undefined
    vision_level: Level | None = None
    afterlife_level: Level | None = None
    dumbass_death: bool = False

    positions: dict[str, int2]
    quests: dict[str, Quest]
    locks: dict[str, object | None]


    def __post_init__(self):
        self.characters = {
            'player': self.get_player(),
            'mother': next(self.level.find(Mother)),
            'brother': next(self.level.find(Brother)),
            'rabid_dog': next(self.level.find(RabidDog)),
            'girl': None,
            'frogs': list(self.level.find(Frog)),
        }

        self.positions = {
            'street': (181, 42),
            'brother_leaving_midpoint': (93, 28),
            'brother_leaving_endpoint': (139, 0),
            'vision_shift': (33, 19),
            'mother_reappearance': (191, 55),
            'player_bed': (208, 57),
            'beside_the_bed': (207, 58),
            'kinds_yard_entrance': (185, 45),
            'girl_appearance': (162, 42),
            'girl_runs_away': (183, 54),
            'afterlife_shift': (5, 3),
            'vision_start': None,
        }

        self.quests = {
            'find_someone_to_fight': Quest("Найти с чем подраться"),
        }

        self.locks = {
            'mother_leaving': None,
            'mother_taking_care': None,
        }


    @Scene.new()
    class introduction:
        mother: Mother
        brother: Annotated[Brother, keep_ai]
        player: Annotated[Player, keep_ai]

        def run(self, rails: "Rails"):
            rails.locks['mother_leaving'] = rails.lock_complex_ai(self.mother)

            yield from wait_while(lambda: ~Q(self.player).ai is None)

            memory = self.player.ai.memory

            yield from rails.start_cutscene()
            yield from rails.center_camera()

            yield from rails.notify(Notification("Управление",
                "С помощью клика <y>мыши</y> по символу на сцене можно присмотреться к объекту"
            ))

            yield {self.brother: Say("О, секунду, совсем забыл.")}
            yield {self.player: Say("Улыбка брата излучает теплоту.", True)}
            yield {self.mother: Say("Хью, нам пора идти.")}
            yield {self.brother: Say("Мам, иди вперёд, я догоню.")}

            self.mother.ai.composite[Pather].going_to = rails.positions["street"]

            yield from wait_for(2)

            yield {self.player: Say(
                "Вы стоите в обшарпанной деревянной прихожей. Горшки с цветами усеивают каждую горизонтальную "
                "поверхность; странное жёсткое чувство упирается в кадык.",
                True,
            )}

            yield from wait_while(lambda: d2(self.mother.p, self.brother.p) < 7)

            yield {self.brother: Say("Вот, смотри.")}
            yield {self.player: Say("В твоих руках оказывается длинный свёрток льняной ткани.", True)}
            self.player.weapon = Weapon(8, damage_kind.slashing)

            selected_option = yield from rails.options({
                (look := "Развязать бечёвку"): NoAction(),
                "Укоризненно смотреть на брата": NoAction(),
            })

            if selected_option == look:
                self.player.traits.naivety += 1
                yield {self.player: Say("Это меч. Очень красивый.", True)}

                yield {self.brother: Say("Кавалерийская шашка. Настоящая.")}
                yield {self.brother: Say("Это вещь.")}

                yield {self.player: Say("Это вещь.")}
                yield {self.player: Say("Где ты его достал?")}

                yield {self.brother: Say("Не спрашивай.")}
                yield {self.brother: Say("И не показывай маме.")}

                yield {self.mother: Say("Хью!")}

                yield {self.brother: Say("Это я!")}
                yield {self.brother: Say("Приглядывай пока за хозяйством, а?")}

                self.brother.ai.composite[Pather].going_to = rails.positions["brother_leaving_midpoint"]
                yield

                yield {self.player: Say(
                    "Брат подскакивает и, блеснув зелёными глазами и одной рукой придерживая кожаную сумку, уходит.",
                    True
                )}
                yield from wait_for(3)

                yield {self.player: Say("Ты проглатываешь подступившую слабость и снова смотришь на меч.", True)}
                yield from wait_for(3)

                self.mother.ai.composite[Follower].subject = self.brother

                yield {self.player: Say("Он красиво блестит.", True)}
            else:
                self.player.traits.pain += 1

                yield {self.player: Say("Брат морщится, пряча взгляд.", True)}

                yield {self.brother: Say("Мне надо это сделать.")}
                yield {self.brother: Say("")}
                yield {self.brother: Say("Не смотри на меня так.")}
                yield {self.brother: Say("")}
                yield {self.brother: Say("Ты не знаешь, о чём говоришь. Я тебе потом объясню.")}

                yield {self.mother: Say("Хью!")}
                yield {self.brother: Say("Это я!")}

                self.brother.ai.composite[Pather].going_to = rails.positions["brother_leaving_midpoint"]
                yield
                yield {self.player: Say("Брат поворачивается и уходит, растерянно взмахнув рукой.", True)}

                yield from wait_for(2)
                yield {self.player: Say("В его глазах видна боль.", True)}

                self.mother.ai.composite[Follower].subject = self.brother

                yield from rails.options({"Развязать бечёвку": NoAction()})
                yield {self.player: Say("Это меч. Очень красивый.", True)}

            self.brother.ai.enable_speech = True
            yield from wait_for(10)
            memory.add_quest(rails.quests["find_someone_to_fight"])

            yield from rails.notify(Notification("Управление",
                "<y>wasd</y> - движение<br/>"
                "<y>r</y> - достать/убрать оружие<br/><br/>"
                "Все горячие клавиши доступны в панели \"Управление\""
            ))

            yield from rails.end_cutscene()


    @Scene.new()
    class brother_path_midpoint:
        brother: Annotated[Brother, keep_ai]

        def start_predicate(self, rails: "Rails"):
            return d2(self.brother.p, rails.positions["brother_leaving_midpoint"]) < 2

        def run(self, rails: "Rails"):
            yield from wait_for(30)
            self.brother.ai.composite[Pather].going_to = rails.positions["brother_leaving_endpoint"]


    @Scene.new()
    class brother_stops_player:
        brother: Annotated[Brother, keep_ai]
        mother: Annotated[Mother, maybe_exists]
        player: Annotated[Player, keep_ai]

        def start_predicate(self, rails: "Rails"):
            return (
                d2(self.brother.p, rails.positions["brother_leaving_endpoint"]) <= 20 and
                d2(self.brother.p, self.player.p) <= self.player.senses.vision
            )

        def run(self, rails: "Rails"):
            self.brother.ai.enable_speech = False

            self.mother.ai.composite[Follower].subject = None
            self.brother.ai.composite[Pather].going_to = self.player.p
            self.brother.ai.composite[Follower].subject = self.player

            yield from rails.start_cutscene()
            yield from rails.center_camera()

            yield from wait_while(lambda: d2(self.brother.p, self.player.p) > 5 or self.brother.act is not None)

            yield {self.brother: Say("Перестань.")}
            yield {self.brother: Say("Я не могу взять тебя с собой.")}
            yield {self.brother: Say("Иди домой.")}

            self.player.traits.naivety += 1
            self.player.traits.pain += 1
            self.player.traits.curiosity += 1

            self.brother.ai.composite[Follower].subject = self.mother
            self.brother.ai.composite[Pather].going_to = self.mother.p
            self.mother.ai.composite[Pather].going_to = rails.positions["brother_leaving_endpoint"]

            yield from self.player.ai.wait_seconds(5)

            yield from rails.end_cutscene()


    # TODO this should be considered cutscene even though it does not enable cutscene mode
    @Scene.new()
    class brother_leaves:
        brother: Annotated[Brother, keep_ai]
        mother: Annotated[Mother, maybe_exists]

        def start_predicate(self, rails: "Rails"):
            return d2(self.brother.p, rails.positions["brother_leaving_endpoint"]) <= 3

        def run(self, rails: "Rails"):
            yield from wait_for(25)
            yield {self.brother: Leave()}
            rails.unlock_complex_ai(self.mother, rails.locks["mother_leaving"])

    # def _is_player_killing_the_dog(self):
    #     return self.characters.rabid_dog in (~Q(self.characters.player).last_killed or ())
    #
    # @Scene.new(lambda self: (
    #     self.characters.player.health.amount.current <= 0
    #     or self._is_player_killing_the_dog()
    # ))
    # def player_has_vision(self, scene):
    #     scene.enabled = False
    #
    #     c = self.characters
    #     p = self.positions
    #     memory = c.player.ai.memory
    #
    #     p.vision_start = c.player.p
    #
    #     if self._is_player_killing_the_dog() or not exists(c.mother):
    #         self.vision_version = VisionVersion.Continuous
    #
    #         self.girl_gives_flower.enabled = True
    #     else:
    #         self.vision_version = VisionVersion.Interrupted
    #
    #         if c.rabid_dog not in c.player.health.last_damaged_by:
    #             self.dumbass_death = True
    #
    #     yield from self.start_cutscene()
    #
    #     if c.player.health.amount.current > 0:
    #         yield from c.player.ai.wait_seconds(2)
    #         yield {c.player: Say("Что-то не так.")}
    #         yield {c.player: Say("Железный вкус на языке, зрение разошлось на две половины.", True)}
    #         yield {c.player: Say("Ты пытаешься вдохнуть, но не можешь.", True)}
    #
    #     yield from c.player.ai.wait_seconds(2)
    #     memory.is_vision_disabled = True
    #     yield from c.player.ai.wait_seconds(2)
    #
    #     c.player.health.amount.reset_to_max()
    #
    #     self.vision_level = self.ms.add(Level(self.ms, Path("levels/vision"), False, self.genesis))
    #     self.vision_level.rails.parent_level = c.player.level
    #     yield from self.plane_shift(self.vision_level, p.vision_shift)
    #
    #     if self.vision_version == VisionVersion.Interrupted:
    #         self.locks.mother_taking_care = self.lock_complex_ai(c.mother)
    #         yield {c.mother: Teleport(p.mother_reappearance)}
    #
    #
    # @Scene.new(enabled=False)
    # def player_wakes_up_1(self, scene):
    #     c = self.characters
    #     p = self.positions
    #     memory = c.player.ai.memory
    #
    #     scene.enabled = False
    #
    #     yield from self.center_camera()
    #
    #     yield {c.player: Say("Что происходит?")}
    #     c.mother.ai.composite[Pather].going_to = p.beside_the_bed
    #     yield from wait_finish(c.mother)
    #
    #     self.vision_level.rails.talk_with_lord_bishop_1.enabled = True
    #     yield from self.plane_shift(self.vision_level, self.vision_level.rails.positions.observing_the_throne)
    #
    #
    # @Scene.new(enabled=False)
    # def player_wakes_up_2(self, scene):
    #     c = self.characters
    #     p = self.positions
    #     memory = c.player.ai.memory
    #
    #     scene.enabled = False
    #     yield from self.center_camera()
    #
    #     yield {c.player: Say("<Сдавленный вскрик>")}
    #     yield {c.player: Say("Зрение сходится; ты в своей комнате.", True)}
    #
    #     yield {c.mother: Say("Всё хорошо.")}
    #     yield {c.mother: Say("Ты дома.")}
    #     yield {c.mother: Say("Ты в безопасности.")}
    #
    #     yield {c.player: Say("Что происходит?")}
    #
    #     yield {c.mother: Say("Ты бредишь.")}
    #
    #     self.vision_level.rails.talk_with_lord_bishop_2.enabled = True
    #
    #     yield from self.plane_shift(self.vision_level, self.vision_level.rails.positions.observing_the_throne)
    #
    #     self.unlock_complex_ai(c.mother, self.locks.mother_taking_care)
    #
    #
    # @Scene.new(lambda self: d2(self.characters.player.p, self.positions.kinds_yard_entrance) <= 2, enabled=False)
    # def girl_gives_flower(self, scene):
    #     c = self.characters
    #     p = self.positions
    #
    #     scene.enabled = False
    #     yield from self.start_cutscene()
    #     yield from self.center_camera()
    #
    #     c.girl = Girl(p=p.girl_appearance, level=self.level)
    #     yield from self.create_entity(c.girl)
    #     c.girl.ai.composite[Pather].going_to = add2(c.player.p, vector.left)
    #
    #     yield from wait_while(lambda: d2(c.girl.p, c.player.p) > 10)
    #     yield {c.player: Say("Девочка твоего возраста.", True)}
    #     yield {c.player: Say("Взъерошенные рыжие волосы, грязь на лице, грубое льняное платье.", True)}
    #
    #     yield from wait_finish(c.girl)
    #
    #     yield from c.player.ai.wait_seconds(1)
    #     yield {c.girl: Say(f"Я {c.girl.name.first}.")}
    #
    #     yield from c.player.ai.wait_seconds(1.5)
    #     yield {c.player: Say(f"{c.girl.name.first}, пряча взгляд, суёт тебе что-то в руку и убегает.", True)}
    #     c.player.inventory.add_item(Lily())
    #
    #     c.girl.ai.composite[Pather].going_to = p.girl_runs_away
    #     yield from wait_finish(c.girl)
    #     yield {c.girl: Leave()}
    #
    #     yield from self.end_cutscene()
    #
    #
    # @Scene.new(lambda self: any(
    #     victim.character == Frog.character
    #     for victim in (~Q(self.characters.player.act)[Aggressive].get_victims(self.characters.player) or ())
    # ))
    # def player_attacks_frog(self, scene):
    #     c = self.characters
    #
    #     scene.enabled = False
    #
    #     c.player.traits.brutality += 1
    #
    #     yield from self.start_cutscene()
    #     yield from self.center_camera()
    #
    #     if self.vision_version == VisionVersion.NotYetEnded:
    #         yield {c.player: Say("Нет, этого недостаточно.")}
    #     else:
    #         yield {c.player: Say("Хм.")}
    #
    #     yield from self.end_cutscene()
    #
    #     self.player_attacks_frog_again.enabled = True
    #
    #
    # @Scene.new(
    #     lambda self: any(
    #         victim.character == Frog.character
    #         for victim in (~Q(self.characters.player.act)[Aggressive].get_victims(self.characters.player) or ())
    #     ),
    #     enabled=False,
    # )
    # def player_attacks_frog_again(self, scene):
    #     scene.enabled = False
    #
    #     c = self.characters
    #
    #     c.player.traits.brutality += 1
    #
    #     yield from self.start_cutscene()
    #     yield from self.center_camera()
    #
    #     yield {c.player: Say("А в этом что-то есть.")}
    #
    #     yield from self.end_cutscene()
    #
    #
    # @Scene.new(
    #     lambda self: exists(self.characters.mother) and d2(self.characters.mother.p, self.characters.player.p) < 10,
    #     enabled=False,
    # )
    # def mother_gives_player_bun(self, scene):
    #     scene.enabled = False
    #
    #     c = self.characters
    #
    #     mother_lock = self.lock_complex_ai(c.mother)
    #
    #     yield from self.start_cutscene()
    #     yield from self.center_camera()
    #
    #     yield {c.mother: Say("Я булочки испекла. Кушай, приходи в себя.")}
    #
    #     mother_initial_p = c.mother.p
    #     c.mother.ai.composite[Pather].going_to = c.player.p
    #
    #     yield from wait_finish(c.mother)
    #     c.player.inventory.add_item(Bun())
    #     c.mother.ai.composite[Pather].going_to = mother_initial_p
    #
    #     yield from wait_finish(c.mother)
    #     if self.dumbass_death:
    #         yield {c.mother: Say("Кстати, это было глупо.")}
    #
    #     yield from self.end_cutscene()
    #     self.unlock_complex_ai(c.mother, mother_lock)
    #
    #
    # @Scene.new(lambda self: any(
    #     hasattr(victim, "human_flag") and victim is not self.characters.player
    #     for victim in (~Q(self.characters.player).last_killed or ())
    # ))
    # def player_kills_a_person(self, scene):
    #     scene.enabled = False
    #     self.player_attacks_frog.enabled = False
    #     self.player_attacks_frog_again.enabled = False
    #
    #     c = self.characters
    #
    #     yield from self.start_cutscene()
    #     yield from self.center_camera()
    #
    #     yield {c.player: Say("Хм.")}
    #     yield {c.player: Say("Ты должен был что-то почувствовать.", True)}
    #
    #     yield from self.end_cutscene()
    #
    #
    # # TODO this should be done in on_death
    # @Scene.new(lambda self: self.characters.player.health.amount.current <= 0, enabled=False)
    # def player_dies_for_real(self, scene):
    #     scene.enabled = False
    #
    #     c = self.characters
    #     p = self.positions
    #
    #     yield from self.start_cutscene()
    #
    #     # TODO RailsBase procedure? maybe not because this should be done in on_death?
    #     self.afterlife_level = self.ms.add(Level(self.ms, Path("levels/afterlife"), False, self.genesis))
    #     self.afterlife_level.rails.parent_level = c.player.level
    #
    #     yield from self.plane_shift(self.afterlife_level, p.afterlife_shift)
