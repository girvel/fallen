from dataclasses import dataclass
from enum import Enum

from ecs import create_system, OwnedEntity

from src.lib.vector import Vector, up, down, left, right, one

import logging

log = logging.getLogger(__name__)


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

def calculate_vision(level_grid, start, r):
    vision = {start, start + up, start + down, start + left, start + right}
    vision_border = {start + up, start + down, start + left, start + right}

    ray_directions = [
        [ up, left, right, ],
        [ up, down, right, ],
        [ down, left, right, ],
        [ up, down, left, ],
    ]

    for _ in range(r - 1):
        next_vision_border = set()
        for p in vision_border:
            entity = p.get_in(level_grid)
            if entity and "solid_flag" in entity: continue

            direction = p - start
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

    return {p: p.get_in(level_grid) for p in vision}

@create_system
def think(subject: 'ai', level: 'level_grid'):
    subject.act = subject.ai.make_decision(
        subject,
        "senses" in subject
            and Perception(calculate_vision(level.level_grid, subject.p, subject.senses.vision), None, None)
            or Perception(None, None, None),
    )

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
