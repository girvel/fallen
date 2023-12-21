import tcod.map

from src.components import Sentient, RailsComponent, Attentive
from src.engine.ai import Perception, GridProxy
from src.lib.query import Q
from src.lib.toolkit import chance

sequence = []


@sequence.append
def run_rails(rails: RailsComponent):
    rails.level.rails_effect = rails.get_effect()


@sequence.append
def think(subject: Sentient):
    is_railed = subject in subject.level.rails_effect

    if is_railed:
        subject.act = subject.level.rails_effect[subject]
        if not hasattr(subject.ai, "cutscene_aware_flag"): return

    if subject.ai is None: return

    if not hasattr(subject, "senses"):
        vision_r = 0
        hearing_r = 0
        smell_r = 0
    elif chance(subject.senses.attention_k) or ~Q(subject).attention_boost:
        vision_r = subject.senses.vision
        hearing_r = subject.senses.hearing
        smell_r = subject.senses.smell
    else:
        vision_r = subject.senses.vision // 3
        hearing_r = subject.senses.hearing // 3
        smell_r = subject.senses.smell // 3

    if not hasattr(subject, "god_vision_flag"):
        fov = tcod.map.compute_fov(subject.level.transparency_cache, subject.p, vision_r)
    else:
        fov = None

    # TODO! last_act
    act = subject.ai.make_decision(subject, Perception(
        {
            layer: GridProxy(grid, subject.p, vision_r, fov)
            for layer, grid in subject.level.grids.items()
        },
        GridProxy(subject.level.grids["sounds"], subject.p, hearing_r),
        GridProxy(subject.level.grids["physical"], subject.p, smell_r),
    ))

    if not is_railed:
        subject.act = act


@sequence.append
def clean_up_attention_flags(subject: Attentive):
    subject.attention_boost -= 1
    if subject.attention_boost <= 0:
        del subject.attention_boost
