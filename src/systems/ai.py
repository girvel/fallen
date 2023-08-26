import random
from dataclasses import dataclass
from enum import Enum
from math import copysign

from ecs import create_system, OwnedEntity

from src.lib.toolkit import sign
from src.lib.vector import Vector, one, up, down, left, right
from src.systems.acting.attack import Attack
from src.systems.acting.move import Move


class Kind(Enum):
    Animate = 0

@dataclass
class Senses:
    vision: int
    hearing: int
    smell: int

@dataclass
class Perception:
    vision: dict[Vector, OwnedEntity]
    hearing: dict[Vector, int]
    smell: dict[Vector, OwnedEntity]

@create_system
def think(subject: 'ai', level: 'level_grid'):
    if "senses" in subject:
        # TODO optimize
        vision = {subject.p, subject.p + up, subject.p + down, subject.p + left, subject.p + right}
        vision_border = {subject.p + up, subject.p + down, subject.p + left, subject.p + right}

        ray_directions = [
            [ up, left, right, ],
            [ up, down, right, ],
            [ down, left, right, ],
            [ up, down, left, ],
        ]

        for _ in range(subject.senses.vision - 1):
            next_vision_border = set()
            for p in vision_border:
                entity = p.get_in(level.level_grid)
                if entity and "solid_flag" in entity: continue

                direction = p - subject.p
                if direction.y <= -abs(direction.x):
                    direction = ray_directions[0]
                elif direction.x >= abs(direction.y):
                    direction = ray_directions[1]
                elif direction.y >= abs(direction.x):
                    direction = ray_directions[2]
                else:
                    direction = ray_directions[3]

                for d in direction:
                    next_vision_border.add(p + d)
                    vision.add(p + d)

            vision_border = next_vision_border

        perception = Perception(
            {p: p.get_in(level.level_grid) for p in vision},
            None,
            None,
        )
    else:
        perception = Perception(None, None, None)

    subject.act = subject.ai.make_decision(subject, perception)

    # start = subject.p - subject.vision * one
    # end = subject.p + subject.vision * one
    #
    # possible_targets = []
    #
    # for y in range(start.y, end.y + 1):
    #     for x in range(start.x, end.x + 1):
    #         e = level.level_grid[y][x]
    #
    #         if e:
    #             possible_targets.append(e)
    #
    # target = subject.choose_target(possible_targets)
    # if not target: return
    #
    # v = target.p - subject.p
    # if v.is_minimal():
    #     subject.act = Attack(v)
    # else:
    #     if v.x * v.y == 0:
    #         subject.act = Move(v.integer_normalize())
    #     else:
    #         v1 = Vector(sign(v.x), 0)
    #         v2 = Vector(0, sign(v.y))
    #
    #         if (subject.p + v1).get_in(level.level_grid) is not None:
    #             subject.act = Move(v2)
    #         elif (subject.p + v2).get_in(level.level_grid) is not None:
    #             subject.act = Move(v1)
    #         else:
    #             subject.act = Move(random.choice([v1, v2]))
