import random
from typing import Optional

from ecs import Entity

from assets.levels.vision.entities.physical.enemy import Enemy
from src.engine.acting.actions.build import Build
from src.engine.acting.actions.cast_fire_storm import CastFireStorm
from src.engine.acting.actions.cast_stone_stomp import CastStoneStomp
from src.engine.acting.actions.say import Say
from src.engine.ai.follower import Follower
from src.engine.ai.pather import Pather
from src.engine.rails_base import RailsBase, Scene
from src.entities.ais.dummy_ai import wait_finish
from src.entities.physical.backslash_wall import BackslashWall
from src.entities.physical.horizontal_wall import HorizontalWall
from src.entities.physical.kaledeii import Kaledeii
from src.entities.physical.lord_bishop import LordBishop
from src.entities.physical.player import Player
from src.entities.physical.slash_wall import SlashWall
from src.entities.physical.soldier import Soldier
from src.entities.physical.vertical_wall import VerticalWall
from src.entities.special.level import Level
from src.lib import vector
from src.lib.concurrency import wait_for, wait_seconds, wait_while
from src.lib.vector import add2, right, d2, mul2


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
        c = self.characters
        p = self.positions

        scene.enabled = False

        self.player = next(self.level.find(Player))  # TODO make this automatic
        c.player = self.player
        memory = c.player.ai.memory

        memory.is_vision_disabled = False

        yield {c.player: Say("Холодный коридор с высокими потолками и трещинами в панорамном окне в озеро.", True)}
        yield {c.player: Say("Кучка вооружённых людей тревожно озирается по сторонам.", True)}

        c.kaledeii.ai.composite[Pather].going_to = p.kaledeii_entrance
        yield from wait_seconds(1)

        yield from wait_finish(c.kaledeii)

        yield {c.kaledeii: Say("За мной.")}
        c.kaledeii.ai.composite[Pather].going_to = p.entrance

        yield {c.player: Say("Высокий воин в полном доспехе.", True)}
        yield {c.player: Say("Доспехи покрыты густой копотью, облик источает решимость.", True)}

        for s in c.soldiers:
            s.ai.composite[Follower].subject = c.kaledeii

        c.player.ai.dummy.composite[Follower].subject = c.kaledeii
        yield from wait_finish(c.kaledeii)

        yield {c.player: Say("Неприступный каменный зал, обогреваемый ревущими пламенем печами.", True)}
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
        yield from wait_seconds(5)

        yield {c.player: Say("Массивные стены зала сотрясаются от мощного удара вдали.", True)}

        c.player.ai.dummy.clear()
        if self.parent_level.rails.is_dog_dead:
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
        yield {c.player: Say("Небесная синева его робы едва видна под золотом религиозной атрибутики.", True)}

        yield {c.kaledeii: Say("Ваше Превосходительство, следуйте за мной.")}
        yield {c.bishop: Say("Глупости! Кем он себя возомнил!")}
        yield {c.bishop: Say("Я останусь на своём положенном месте и не сдвинусь ни на шаг.")}
        yield {c.bishop: Say("Мы будем спасены.")}

        yield from wait_seconds(1)

        yield {c.player: Say("Стены сотрясаются вновь.", True)}

        if self.parent_level.rails.is_dog_dead:
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

        yield from wait_seconds(2)
        yield {c.player: Say("Резкая тишина.", True)}

        c.player.ai.dummy.composite[Pather].going_to = p.observing_the_entrance

        yield from wait_for(5)
        c.kaledeii.ai.composite[Pather].going_to = add2(p.observing_the_entrance, mul2(vector.up, 2))

        yield from wait_while(lambda: enemy.p != p.enemy_attack)
        yield from self.center_camera()
        yield {c.player: Say("Солдаты намертво заложили вход.", True)}
        yield {c.player: Say("Стены зала высечены из гладкого серого камня толщиной с повозку с лошадью.", True)}
        yield {c.player: Say("Сложно представить более неприступную крепость.", True)}

        c.player.ai.dummy.clear()
        yield {c.kaledeii: Say("Он здесь.")}

        yield {enemy: CastStoneStomp(vector.right)}
        yield from wait_seconds(1)
        yield {enemy: CastStoneStomp(vector.right)}
        yield from wait_seconds(2)
        yield {enemy: CastFireStorm()}
        yield from wait_for(CastFireStorm.duration + 1)

        yield from wait_while(lambda: c.player.health.amount.current > 0)

        self.run_task()(lambda: self.plane_shift(self.parent_level, self.parent_level.rails.positions.player_bed))
        c.player.health.amount.reset_to_max()
        yield from self.end_cutscene()
        memory.complete_quest(self.parent_level.rails.quests.find_someone_to_fight)
