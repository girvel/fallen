import logging

import numpy
import tcod.map

from src.components import GridContainer, Sentient
from src.engine.ai import Perception, GridProxy
from src.lib.vector import int2


def create_square_rhombus(position, radius, field_size):
    return numpy.fromfunction(
        lambda x, y: abs(x - position[0]) + abs(y - position[1]) <= radius,
        field_size
    )


def borders_from_radius(p: int2, r: int, size: int2) -> tuple[int2, int2]:
    return (
        (max(0, p[0] - r), max(0, p[1] - r)),
        (min(size[0], p[0] + r + 1), min(size[1], p[1] + r + 1)),
    )


def update_transparency_cache(level: GridContainer):
    for y, line in enumerate(level.grids["physical"][0]):
        for x, e in enumerate(line):
            level.transparency_cache[x, y] = int(e is None or not hasattr(e, "solid_flag"))


stop_signal = object()

def run_rails(level: GridContainer):
    if not hasattr(level, "rails"): return

    started_scenes = []
    for s in level.rails.scenes:
        if s.enabled and s.start_predicate():  # TODO optimization: remove disabled scenes from the list?
            started_scenes.append(s.run())
            logging.info(f"Starting the scene '{s.name}'")

    level.rails.current_scenes += started_scenes

    level.rails_effect = {}

    for scene in level.rails.current_scenes.copy():
        if (effect := next(scene, stop_signal)) is not stop_signal:
            level.rails_effect |= effect or {}
        else:
            level.rails.current_scenes.remove(scene)


def think(subject: Sentient):
    is_railed = subject in subject.level.rails_effect

    if is_railed:
        subject.act = subject.level.rails_effect[subject]
        if not hasattr(subject.ai, "cutscene_aware_flag"): return

    if not hasattr(subject, "god_vision_flag"):
        fov = tcod.map.compute_fov(subject.level.transparency_cache, subject.p, subject.senses.vision)
    else:
        fov = numpy.full(subject.level.transparency_cache.shape, True)

    act = subject.ai.make_decision(subject, Perception(
        {
            layer: GridProxy(
                grid, fov,
                *borders_from_radius(subject.p, subject.senses.vision, subject.level.size)
            )
            for layer, grid in subject.level.grids.items()
        },
        GridProxy(
            subject.level.grids["sounds"],
            create_square_rhombus(subject.p, subject.senses.hearing, subject.level.size),
            *borders_from_radius(subject.p, subject.senses.hearing, subject.level.size),
        ),
        GridProxy(
            subject.level.grids["physical"],
            create_square_rhombus(subject.p, subject.senses.smell, subject.level.size),
            *borders_from_radius(subject.p, subject.senses.smell, subject.level.size),
        ),
    ))

    if not is_railed:
        subject.act = act


sequence = [
    update_transparency_cache,
    run_rails,
    think,
]
