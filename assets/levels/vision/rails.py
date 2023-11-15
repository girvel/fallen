import random
from typing import Optional

from ecs import Entity

from assets.levels.main.rails import DogQuestEnding
from assets.levels.vision.library.physical.enemy import Enemy
from src.library.actions.build import Build
from src.library.actions.cast_fire_storm import CastFireStorm
from src.library.actions.cast_stone_stomp import CastStoneStomp
from src.library.actions.say import Say
from src.library.ai_modules.follower import Follower
from src.library.ai_modules.pather import Pather
from src.engine.rails_base import RailsBase, Scene
from src.library.ais.dummy_ai import wait_finish
from src.library.physical.backslash_wall import BackslashWall
from src.library.physical.horizontal_wall import HorizontalWall
from src.library.physical.kaledeii import Kaledeii
from src.library.physical.lord_bishop import LordBishop
from src.library.physical.slash_wall import SlashWall
from src.library.physical.soldier import Soldier
from src.library.physical.vertical_wall import VerticalWall
from src.library.special.level import Level
from src.lib import vector
from src.lib.concurrency import wait_for, wait_while
from src.lib.vector import add2, right, mul2


class Rails(RailsBase):
    parent_level: Optional[Level]

    def __post_init__(self):
        self.characters = Entity(
            soldiers=list(self.level.find(Soldier)),
            kaledeii=next(self.level.find(Kaledeii)),
            bishop=next(self.level.find(LordBishop)),
        )

        self.positions = Entity(
            entrance=(87, 17),
            kaledeii_entrance=(16, 17),
            fortification_positions=[
                (74, 17), (75, 17), (76, 17), (76, 18), (76, 16),
            ],
            before_the_throne=(147, 17),
            observing_the_throne=(132, 19),
            observing_the_entrance=(96, 18),
            enemy_appearance=(0, 17),
            enemy_attack=(68, 17),
        )

        self.quests = Entity()


    @Scene.new()
    def start_vision(self, scene):
        self.characters.player = self.get_player()

        c = self.characters
        p = self.positions

        scene.enabled = False
        memory = c.player.ai.memory

        memory.is_vision_disabled = False

        yield {c.player: Say("Холодный каменный коридор с высокими потолками.", True)}
        yield {c.player: Say(
            "Панорамное окно, отделяющее помещение от ледяного озера, потрескалось и протекает.", True
        )}
        yield {c.player: Say("Кучка вооружённых людей тревожно озирается по сторонам.", True)}

        c.kaledeii.ai.composite[Pather].going_to = p.kaledeii_entrance
        yield from c.player.ai.wait_seconds(1)

        yield from wait_finish(c.kaledeii)

        yield {c.kaledeii: Say("За мной.")}
        c.kaledeii.ai.composite[Pather].going_to = p.entrance

        yield {c.player: Say("Высокий воин в полном доспехе.", True)}
        yield {c.player: Say("Пластины брони покрыты густой копотью, облик источает решимость.", True)}

        for s in c.soldiers:
            s.ai.composite[Follower].subject = c.kaledeii

        c.player.ai.dummy.composite[Follower].subject = c.kaledeii

        yield from wait_for(40)
        yield {c.player: Say("Вход в зал высечен в гладком сером камне толщиной с повозку с лошадью.", True)}
        yield {c.player: Say("Сложно представить более неприступную крепость.", True)}

        yield from wait_finish(c.kaledeii)
        yield {c.player: Say("Каменный зал, обогреваемый ревущими пламенем печами.", True)}
        yield {c.player: Say("Колоссальные размеры не позволяют чётко рассмотреть, что находится в его конце.", True)}

        yield from wait_finish(*c.soldiers, threshold=2)

        for s in c.soldiers:
            s.ai.composite[Follower].subject = None

        builder1, builder2, *rest = c.soldiers

        yield {c.kaledeii: Say(f"{builder1.name.last} и {builder2.name.last}, блокируйте проход.")}

        @self.run_task(builder1, p.fortification_positions[:3])
        @self.run_task(builder2, p.fortification_positions[3:])
        def build_fortifications(executor, positions):
            for position in positions:
                executor.ai.composite[Pather].going_to = add2(right, position)
                yield from wait_finish(builder1)
                yield {executor: Build(
                    position,
                    random.choice([HorizontalWall, VerticalWall, SlashWall, BackslashWall]),
                )}

            # TODO then scatter to their positions

        yield {c.kaledeii: Say("Остальные -- оборонительные позиции, оружие наготове.")}

        c.kaledeii.ai.composite[Pather].going_to = p.before_the_throne
        yield from c.player.ai.wait_seconds(3)

        yield {c.player: Say("Массивные стены зала сотрясаются от мощного удара вдали.", True)}

        c.player.ai.dummy.clear()
        if self.parent_level.rails.dog_quest_ending == DogQuestEnding.Win:
            c.player.ai.dummy.composite[Pather].going_to = p.observing_the_throne
            self.talk_with_lord_bishop_1.enabled = True
        else:
            self.parent_level.rails.player_wakes_up_1.enabled = True
            yield from self.plane_shift(self.parent_level, self.parent_level.rails.positions.player_bed)


    @Scene.new(enabled=False)
    def talk_with_lord_bishop_1(self, scene):
        c = self.characters
        p = self.positions
        memory = c.player.ai.memory

        scene.enabled = False

        yield from self.center_camera()
        yield from wait_finish(c.kaledeii)

        yield {c.player: Say("Другой край зала.", True)}
        yield {c.player: Say("Фигура злого старика нависает с края возвышенности трона.", True)}
        yield {c.player: Say("Небесная синева его робы едва видна под золотом церимониальной атрибутики.", True)}

        yield {c.kaledeii: Say("Ваше Превосходительство, следуйте за мной.")}
        yield {c.bishop: Say("Глупости! Кем он себя возомнил!")}
        yield {c.bishop: Say("Я останусь на своём положенном месте и не сдвинусь ни на шаг.")}
        yield {c.bishop: Say("Мы будем спасены.")}

        yield from c.player.ai.wait_seconds(1)

        yield {c.player: Say("Стены сотрясаются вновь.", True)}

        if self.parent_level.rails.dog_quest_ending == DogQuestEnding.Win:
            c.player.p = p.observing_the_throne
            self.talk_with_lord_bishop_2.enabled = True
        else:
            self.parent_level.rails.player_wakes_up_2.enabled = True
            yield from self.plane_shift(self.parent_level, self.parent_level.rails.positions.player_bed)


    @Scene.new(enabled=False)
    def talk_with_lord_bishop_2(self, scene):
        c = self.characters
        p = self.positions
        memory = c.player.ai.memory

        scene.enabled = False

        enemy = Enemy(p=p.enemy_appearance, level=self.level)
        self.genesis.entities_to_create.add(enemy)
        enemy.ai.composite[Pather].going_to = p.enemy_attack

        yield {c.kaledeii: Say("Вы не понимаете тяжесть нашей ситуации, лорд-епископ.")}
        enemy.after_load(self.level)  # TODO encapsulate creation
        yield {c.kaledeii: Say(
            "Стены Ковенанта пали, половина гарнизона мертва, я -- последний стоящий на ногах рыцарь, и я не справлюсь "
            "с ним в одиночку."
        )}

        yield from wait_for(7)
        yield {c.bishop: Say("Так и быть, я вам помогу.")}

        yield from c.player.ai.wait_seconds(2)
        yield {c.player: Say("Резкая тишина.", True)}

        c.player.ai.dummy.composite[Pather].going_to = p.observing_the_entrance

        yield from wait_for(5)
        c.kaledeii.ai.composite[Pather].going_to = add2(p.observing_the_entrance, mul2(vector.up, 2))

        yield from wait_while(lambda: enemy.p != p.enemy_attack)
        yield from self.center_camera()

        c.player.ai.dummy.clear()
        yield {c.kaledeii: Say("Он здесь.")}
        yield from c.player.ai.wait_seconds(5)

        yield {enemy: CastStoneStomp(vector.right)}
        yield from c.player.ai.wait_seconds(3)
        yield {enemy: CastStoneStomp(vector.right)}
        yield from c.player.ai.wait_seconds(3)
        yield {enemy: CastFireStorm()}
        yield from wait_for(CastFireStorm.duration + 1)

        yield from wait_while(lambda: c.player.health.amount.current > 0)

        yield from self.plane_shift(self.parent_level, self.parent_level.rails.positions.player_bed)
        c.player.health.amount.reset_to_max()
        yield from self.end_cutscene()
        memory.complete_quest(self.parent_level.rails.quests.find_someone_to_fight)
        self.parent_level.rails.mother_gives_player_bun.enabled = True
