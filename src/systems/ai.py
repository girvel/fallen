from dataclasses import dataclass
from enum import Enum

import numpy
from ecs import create_system, OwnedEntity

from src.lib.vector import up, down, left, right, safe_get, minimize


class Kind(Enum):
    Animate = 0

@dataclass
class Senses:
    vision: int
    hearing: int
    smell: int

@dataclass
class Perception:
    vision: dict[numpy.ndarray, OwnedEntity]
    hearing: dict[numpy.ndarray, int]
    smell: dict[numpy.ndarray, OwnedEntity]

@create_system
def think(subject: 'ai', level: 'level_grid'):
    if "senses" in subject:
        # TODO optimize
        vision = {tuple(p) for p in [
            subject.p, subject.p + up, subject.p + down, subject.p + left, subject.p + right
        ]}

        for _ in range(subject.senses.vision - 1):
            for p in vision.copy():
                entity = safe_get(level.level_grid, numpy.array(p))
                if not entity or "solid_flag" not in entity:
                    vision |= {
                        tuple(p + d) for d in [ up, down, left, right, ] if not numpy.array_equal(d, minimize(subject.p - p))
                    }  # TODO bottleneck

        perception = Perception(
            {p: safe_get(level.level_grid, numpy.array(p)) for p in vision},
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
