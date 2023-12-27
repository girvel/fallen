from enum import Enum
from pathlib import Path
from typing import Annotated

from ecs import exists

from levels.main_01_introduction.assets.physical.brother import Brother
from levels.main_01_introduction.assets.physical.girl import Girl
from levels.main_01_introduction.assets.physical.mother import Mother
from src.engine.acting import damage_kind
from src.engine.acting.aggressive import Aggressive
from src.engine.acting.damage import Weapon
from src.engine.rails.rails_api import Lock
from src.engine.rails.rails_base import RailsBase
from src.engine.rails.scene import Scene, keep_ai, maybe_exists, Priority
from src.lib.concurrency import wait_for, wait_while
from src.lib.query import Q
from src.lib.vector import vector
from src.lib.vector.vector import d2, add2, int2
from src.assets.actions.leave import Leave
from src.assets.actions.no_action import NoAction
from src.assets.actions.say import Say
from src.assets.actions.teleport import Teleport
from src.assets.ai_modules.follower import Follower
from src.assets.ai_modules.pather import Pather
from src.assets.ai_modules.spacial_memory import PathMemory
from src.assets.ais.dummy_ai import wait_finish
from src.assets.ais.io import Quest, Notification
from src.assets.items.bun import Bun
from src.assets.items.lily import Lily
from src.assets.physical.frog import Frog
from src.assets.physical.player import Player
from src.assets.physical.rabid_dog import RabidDog
from src.assets.special.level import Level


class VisionVersion(Enum):
    Undefined = 0
    Continuous = 1
    Interrupted = 2


class Rails(RailsBase):
    vision_version: VisionVersion = VisionVersion.Undefined
    vision_level: Level | None = None
    dumbass_death: bool = False

    positions: dict[str, int2]
    quests: dict[str, Quest]
    ai_locks: dict[str, Lock]
    death_locks: dict[str, Lock]


    def __post_init__(self):
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
        }

        self.quests = {
            'find_someone_to_fight': Quest("Найти с чем подраться"),
        }

        self.ai_locks = {
            'mother_leaving': Lock("mother_leaving"),
            'mother_taking_care': Lock("mother_leaving"),
        }

        self.death_locks = {
            "player_vision": Lock("player_vision"),
        }

    def after_creation(self):
        self.characters = {
            'player': self.get_player(),
            'mother': next(self.level.find(Mother)),
            'brother': next(self.level.find(Brother)),
            'rabid_dog': next(self.level.find(RabidDog)),
            'girl': None,
            'frogs': list(self.level.find(Frog)),
        }


    @Scene.new(priority=Priority.mainline)
    class introduction:
        mother: Mother
        brother: Brother
        player: Annotated[Player, keep_ai]

        def run(self, rails: "Rails"):
            rails.lock_complex_ai(self.mother, rails.ai_locks['mother_leaving'])
            rails.lock_dying(self.player, rails.death_locks["player_vision"])

            # TODO move this to on_destruction? (after level refactor)
            self.player.afterlife_level = Level.create(Path("levels/afterlife"), rails.hades, rails.genesis)
            self.player.afterlife_level.rails.parent_level = self.player.level  # TODO encapsulate this?

            yield from wait_while(lambda: ~Q(self.player).ai is None)

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
            self.player.ai.memory.add_quest(rails.quests["find_someone_to_fight"])

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


    @Scene.new(priority=Priority.mainline)
    class brother_stops_player:
        brother: Brother
        mother: Annotated[Mother, maybe_exists]
        player: Player

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


    @Scene.new()
    class brother_leaves:
        brother: Brother
        mother: Annotated[Mother, maybe_exists]

        def start_predicate(self, rails: "Rails"):
            return d2(self.brother.p, rails.positions["brother_leaving_endpoint"]) <= 3

        def run(self, rails: "Rails"):
            yield from wait_for(25)
            yield {self.brother: Leave()}
            rails.unlock_complex_ai(self.mother, rails.ai_locks["mother_leaving"])


    @Scene.new(priority=Priority.mainline)
    class player_has_vision:
        player: Player
        rabid_dog: Annotated[RabidDog, maybe_exists]
        mother: Annotated[Mother, maybe_exists]

        def _is_player_killing_the_dog(self):
            return self.rabid_dog in (~Q(self.player).last_killed or ())

        def start_predicate(self, rails: "Rails"):
            return (
                self.player.health.amount.current <= 0
                or self._is_player_killing_the_dog()
            )

        def run(self, rails: "Rails"):
            rails.unlock_dying(self.player, rails.death_locks["player_vision"])
            rails.positions["vision_start"] = self.player.p

            if self._is_player_killing_the_dog() or not exists(self.mother):
                rails.vision_version = VisionVersion.Continuous

                rails.girl_gives_flower.enabled = True
            else:
                rails.vision_version = VisionVersion.Interrupted

                if self.rabid_dog not in (~Q(self.player).last_damaged_by or []):
                    rails.dumbass_death = True

            yield from rails.start_cutscene()

            if self.player.health.amount.current > 0:
                yield from self.player.ai.wait_seconds(2)
                yield {self.player: Say("Что-то не так.")}
                yield {self.player: Say("Железный вкус на языке, зрение разошлось на две половины.", True)}
                yield {self.player: Say("Ты пытаешься вдохнуть, но не можешь.", True)}

            yield from self.player.ai.wait_seconds(2)
            self.player.ai.memory.is_vision_disabled = True
            yield from self.player.ai.wait_seconds(2)

            self.player.health.amount.reset_to_max()

            rails.vision_level = Level.create(Path("levels/vision"), rails.hades, rails.genesis)
            rails.vision_level.rails.parent_level = self.player.level
            yield

            self.player.ai.dummy.composite[PathMemory].knows(rails.vision_level)

            yield from rails.plane_shift(rails.vision_level, rails.positions["vision_shift"])

            if rails.vision_version == VisionVersion.Interrupted:
                rails.lock_complex_ai(self.mother, rails.ai_locks["mother_taking_care"])
                yield {self.mother: Teleport(rails.positions["mother_reappearance"])}


    @Scene.new(priority=Priority.mainline, enabled=False)
    class player_wakes_up_1:
        player: Player
        mother: Mother

        def run(self, rails: "Rails"):
            yield from rails.center_camera()

            yield {self.player: Say("Что происходит?")}
            self.mother.ai.composite[Pather].going_to = rails.positions["beside_the_bed"]
            yield from wait_finish(self.mother)

            rails.vision_level.rails.talk_with_lord_bishop_1.enabled = True
            yield from rails.plane_shift(rails.vision_level, rails.vision_level.rails.positions["observing_the_throne"])


    @Scene.new(priority=Priority.mainline, enabled=False)
    class player_wakes_up_2:
        mother: Mother
        player: Player

        def run(self, rails: "Rails"):
            yield from rails.center_camera()

            yield {self.player: Say("<Сдавленный вскрик>")}
            yield {self.player: Say("Зрение сходится; ты в своей комнате.", True)}

            yield {self.mother: Say("Всё хорошо.")}
            yield {self.mother: Say("Ты дома.")}
            yield {self.mother: Say("Ты в безопасности.")}

            yield {self.player: Say("Что происходит?")}

            yield {self.mother: Say("Ты бредишь.")}

            rails.vision_level.rails.talk_with_lord_bishop_2.enabled = True

            yield from rails.plane_shift(rails.vision_level, rails.vision_level.rails.positions["observing_the_throne"])

            rails.unlock_complex_ai(self.mother, rails.ai_locks["mother_taking_care"])


    @Scene.new(priority=Priority.sideline, enabled=False)
    class girl_gives_flower:
        player: Player

        def start_predicate(self, rails: "Rails"):
            return d2(self.player.p, rails.positions["kinds_yard_entrance"]) <= 2

        def run(self, rails: "Rails"):
            yield from rails.start_cutscene()
            yield from rails.center_camera()

            girl = Girl(p=rails.positions["girl_appearance"], level=rails.level)
            yield from rails.create_entity(girl)
            girl.ai.composite[Pather].going_to = add2(self.player.p, vector.left)

            yield from wait_while(lambda: d2(girl.p, self.player.p) > 10)
            yield {self.player: Say("Девочка твоего возраста.", True)}
            yield {self.player: Say("Взъерошенные рыжие волосы, грязь на лице, грубое льняное платье.", True)}

            yield from wait_finish(girl)

            yield from self.player.ai.wait_seconds(1)
            yield {girl: Say(f"Я {girl.name.first}.")}

            yield from self.player.ai.wait_seconds(1.5)
            yield {self.player: Say(f"{girl.name.first}, пряча взгляд, суёт тебе что-то в руку и убегает.", True)}
            self.player.inventory.add_item(Lily())

            girl.ai.composite[Pather].going_to = rails.positions["girl_runs_away"]
            yield from wait_finish(girl)
            yield {girl: Leave()}

            yield from rails.end_cutscene()


    @Scene.new(priority=Priority.sideline)
    class player_attacks_frog:
        player: Player

        def start_predicate(self, rails: "Rails"):
            return any(
                isinstance(victim, Frog)
                for victim in (~Q(self.player.act)[Aggressive].get_victims(self.player) or ())
            )

        def run(self, rails: "Rails"):
            self.player.traits.brutality += 1

            yield from rails.start_cutscene()
            yield from rails.center_camera()

            yield from self.player.ai.wait_seconds(1)

            if rails.vision_version == VisionVersion.Undefined:
                yield {self.player: Say("Нет, этого недостаточно.")}
            else:
                yield {self.player: Say("Хм.")}

            yield from rails.end_cutscene()

            rails.player_attacks_frog_again.enabled = True


    @Scene.new(priority=Priority.sideline, enabled=False)
    class player_attacks_frog_again:
        player: Player

        def start_predicate(self, rails: "Rails"):
            return any(
                victim.character == Frog.character
                for victim in (~Q(self.player.act)[Aggressive].get_victims(self.player) or ())
            )

        def run(self, rails: "Rails"):
            self.player.traits.brutality += 1

            yield from rails.start_cutscene()
            yield from rails.center_camera()

            yield {self.player: Say("А в этом что-то есть.")}

            yield from rails.end_cutscene()


    @Scene.new(priority=Priority.sideline, enabled=False)
    class mother_gives_player_bun:
        player: Player
        mother: Mother

        def start_predicate(self, rails: "Rails"):
            return d2(self.mother.p, self.player.p) < 10

        def run(self, rails: "Rails"):
            yield from rails.start_cutscene()
            yield from rails.center_camera()

            yield {self.mother: Say("Я булочки испекла. Кушай, приходи в себя.")}

            mother_initial_p = self.mother.p
            self.mother.ai.composite[Pather].going_to = self.player.p

            yield from wait_finish(self.mother)
            self.player.inventory.add_item(Bun())
            self.mother.ai.composite[Pather].going_to = mother_initial_p

            yield from wait_finish(self.mother)
            if rails.dumbass_death:
                yield {self.mother: Say("С твоей стороны это было глупо.")}
                yield {self.mother: Say("Будь поаккуратнее, ладно?")}

            yield from rails.end_cutscene()


    @Scene.new(priority=Priority.sideline)
    class player_kills_a_person:
        player: Player

        def start_predicate(self, rails: "Rails"):
            return any(
                hasattr(victim, "human_flag") and victim is not self.player
                for victim in (~Q(self.player).last_killed or ())
            )

        def run(self, rails: "Rails"):
            rails.player_attacks_frog.enabled = False
            rails.player_attacks_frog_again.enabled = False

            yield from rails.start_cutscene()
            yield from rails.center_camera()

            yield {self.player: Say("Хм.")}
            yield {self.player: Say("Ты должен был что-то почувствовать.", True)}

            yield from rails.end_cutscene()
