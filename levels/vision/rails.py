import random
from typing import Optional, Annotated

from ecs import Entity, exists

from levels.main_01_introduction.rails import VisionVersion
from levels.vision.assets.physical.enemy import Enemy
from src.assets.actions.build import Build
from src.assets.actions.cast_fire_storm import CastFireStorm
from src.assets.actions.cast_stone_stomp import CastStoneStomp
from src.assets.actions.say import Say
from src.assets.ai_modules.follower import Follower
from src.assets.ai_modules.pather import Pather
from src.engine.rails.rails_base import RailsBase
from src.engine.rails.scene import Scene, not_required, Priority
from src.assets.ais.dummy_ai import wait_finish
from src.assets.physical.backslash_wall import BackslashWall
from src.assets.physical.horizontal_wall import HorizontalWall
from src.assets.physical.kaledeii import Kaledeii
from src.assets.physical.lord_bishop import LordBishop
from src.assets.physical.player import Player
from src.assets.physical.slash_wall import SlashWall
from src.assets.physical.soldier import Soldier
from src.assets.physical.vertical_wall import VerticalWall
from src.assets.special.level import Level
from src.lib.vector import vector
from src.lib.concurrency import wait_for, wait_while
from src.lib.vector.vector import add2, right, mul2


class Rails(RailsBase):
    parent_level: Level | None

    def __post_init__(self):
        self.positions = {
            'entrance': (87, 17),
            'kaledeii_entrance': (16, 17),
            'fortifications': [(74, 17), (75, 17), (76, 17), (76, 18), (76, 16), ],
            'before_the_throne': (147, 17),
            'observing_the_throne': (132, 19),
            'observing_the_entrance': (96, 18),
            'enemy_appearance': (0, 17),
            'enemy_attack': (68, 17)
        }

    def after_creation(self):
        self.characters = {
            'player': self.get_player,
            'soldiers': list(self.level.find(Soldier)),
            'kaledeii': next(self.level.find(Kaledeii)),
            'bishop': next(self.level.find(LordBishop)),
            'enemy': None
        }


    @Scene.new(priority=Priority.mainline)
    class start_vision:
        player: Player
        kaledeii: Kaledeii
        soldiers: list[Soldier]

        def run(self, rails: "Rails"):
            self.player.ai.memory.is_vision_disabled = False

            yield {self.player: Say("Холодный каменный коридор с высокими потолками.", True)}
            yield {self.player: Say(
                "Панорамное окно, отделяющее помещение от ледяного озера, потрескалось и протекает.", True
            )}
            yield {self.player: Say("Кучка вооружённых людей тревожно озирается по сторонам.", True)}
            yield {self.player: Say("Слышны звон холодного оружия и рёв огня.", True)}

            self.kaledeii.ai.composite[Pather].going_to = rails.positions["kaledeii_entrance"]
            yield from self.player.ai.wait_seconds(1)

            yield from wait_finish(self.kaledeii)

            yield {self.kaledeii: Say("За мной.")}
            self.kaledeii.ai.composite[Pather].going_to = rails.positions["entrance"]

            yield {self.player: Say("Высокий воин в полном доспехе.", True)}
            yield {self.player: Say("Пластины брони покрыты густой копотью, облик источает решимость.", True)}

            for s in self.soldiers:
                s.ai.composite[Follower].subject = self.kaledeii

            self.player.ai.dummy.composite[Follower].subject = self.kaledeii

            yield from wait_for(40)
            yield {self.player: Say("Вход в зал высечен в гладком сером камне толщиной с повозку с лошадью.", True)}
            yield {self.player: Say("Сложно представить более неприступную крепость.", True)}

            yield from wait_finish(self.kaledeii)
            yield from wait_for(5)
            yield {self.player: Say("Каменный зал, обогреваемый ревущими пламенем печами.", True)}
            yield {self.player: Say("Колоссальные размеры не позволяют чётко рассмотреть, что находится в его конце.", True)}

            yield from wait_finish(*self.soldiers, threshold=2)

            for s in self.soldiers:
                s.ai.composite[Follower].subject = None

            builder1, builder2, *rest = self.soldiers

            yield {self.kaledeii: Say(f"{builder1.name.last} и {builder2.name.last}, блокируйте проход.")}

            @rails.run_task(builder1, rails.positions["fortifications"][:3])
            @rails.run_task(builder2, rails.positions["fortifications"][3:])
            def build_fortifications(executor, positions):
                for position in positions:
                    executor.ai.composite[Pather].going_to = add2(right, position)
                    yield from wait_finish(executor)
                    yield {executor: Build(
                        position,
                        random.choice([HorizontalWall, VerticalWall, SlashWall, BackslashWall]),
                    )}

                # TODO then scatter to their positions

            yield {self.kaledeii: Say("Остальные -- оборонительные позиции, оружие наготове.")}

            self.kaledeii.ai.composite[Pather].going_to = rails.positions["before_the_throne"]
            yield from self.player.ai.wait_seconds(3)

            yield {self.player: Say("Массивные стены зала сотрясаются от мощного удара вдали.", True)}

            self.player.ai.dummy.clear()

            if rails.parent_level.rails.vision_version == VisionVersion.Continuous:
                self.player.ai.dummy.composite[Pather].going_to = rails.positions["observing_the_throne"]
                rails.talk_with_lord_bishop_1.enabled = True
            else:
                rails.parent_level.rails.player_wakes_up_1.enabled = True
                yield from rails.plane_shift(rails.parent_level, rails.parent_level.rails.positions["player_bed"])


    @Scene.new(priority=Priority.mainline, enabled=False)
    class talk_with_lord_bishop_1:
        player: Player
        kaledeii: Kaledeii
        bishop: LordBishop

        def run(self, rails: "Rails"):
            yield from rails.center_camera()
            yield from wait_finish(self.kaledeii)

            yield {self.player: Say("Другой край зала.", True)}
            yield {self.player: Say("Фигура злого старика нависает с края возвышенности трона.", True)}
            yield {self.player: Say("Небесная синева его робы едва видна под золотом церимониальной атрибутики.", True)}

            yield {self.kaledeii: Say("Ваше превосходительство, следуйте за мной.")}
            yield {self.bishop: Say("Глупости! Кем он себя возомнил!")}
            yield {self.bishop: Say("Я останусь на своём положенном месте и не сдвинусь ни на шаг.")}
            yield {self.bishop: Say("Мы будем спасены.")}

            yield from self.player.ai.wait_seconds(1)

            yield {self.player: Say("Стены сотрясаются вновь.", True)}

            if rails.parent_level.rails.vision_version == VisionVersion.Continuous:
                self.player.p = rails.positions["observing_the_throne"]
                rails.talk_with_lord_bishop_2.enabled = True
            else:
                rails.parent_level.rails.player_wakes_up_2.enabled = True
                yield from rails.plane_shift(rails.parent_level, rails.parent_level.rails.positions["player_bed"])


    @Scene.new(priority=Priority.mainline, enabled=False)
    class talk_with_lord_bishop_2:
        kaledeii: Kaledeii
        bishop: LordBishop
        player: Player
        enemy: Annotated[Enemy, not_required]

        def run(self, rails: "Rails"):
            @rails.run_task()
            def enemy_comes():
                self.enemy = Enemy(p=rails.positions["enemy_appearance"], level=rails.level)
                yield from rails.create_entity(self.enemy)
                self.enemy.ai.composite[Pather].going_to = rails.positions["enemy_attack"]

            yield {self.kaledeii: Say("Вы не понимаете тяжесть нашей ситуации, лорд-епископ.")}
            yield {self.kaledeii: Say(
                "Стены Ковенанта пали, половина гарнизона мертва, я -- последний стоящий на ногах рыцарь, и я не "
                "справлюсь с ним в одиночку."
            )}

            yield from wait_for(7)
            yield {self.bishop: Say("Так и быть, я вам помогу.")}

            yield from self.player.ai.wait_seconds(2)
            yield {self.player: Say("Резкая тишина.", True)}

            self.player.ai.dummy.composite[Pather].going_to = rails.positions["observing_the_entrance"]

            yield from wait_for(5)
            self.kaledeii.ai.composite[Pather].going_to = add2(rails.positions["observing_the_entrance"], mul2(vector.up, 2))

            yield from wait_while(lambda: self.enemy.p != rails.positions["enemy_attack"])
            yield from rails.center_camera()

            self.player.ai.dummy.clear()
            yield {self.kaledeii: Say("Он здесь.")}
            yield from self.player.ai.wait_seconds(5)

            yield {self.enemy: CastStoneStomp(vector.right)}
            yield from self.player.ai.wait_seconds(3)
            yield {self.enemy: CastStoneStomp(vector.right)}
            yield from self.player.ai.wait_seconds(3)
            yield {self.enemy: CastFireStorm()}
            yield from wait_for(CastFireStorm.duration + 1)

            yield from wait_while(lambda: self.player.health.current > 0)

            yield from rails.plane_shift(
                rails.parent_level,
                rails.parent_level.rails.positions["player_bed"]
                if exists(rails.parent_level.rails.get_character("mother")) else
                rails.parent_level.rails.positions["vision_start"],
            )

            if exists(rails.parent_level.rails.get_character("mother")):
                self.player.health.reset_to_max()
            else:
                self.player.health.current = self.player.health.maximum // 2
                # TODO use real regeneration

            yield from rails.end_cutscene()
            self.player.ai.memory.complete_quest(rails.parent_level.rails.quests["find_someone_to_fight"])

            rails.parent_level.rails.mother_gives_player_bun.enabled = True
            rails.level.destroy(rails.hades)
            rails.parent_level.rails.vision_level = None
