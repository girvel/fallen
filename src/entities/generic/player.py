import curses

from ecs import OwnedEntity

from src.entities.special.controller import Controller
from src.entities.special.screen import Colors
from src.lib.vector import zero, Vector
from src.systems.acting.attack import DamageKind, ArmorKind, Weapon, Health
from src.systems.ai import Kind, Senses

import logging

log = logging.getLogger(__name__)


def _get_color_pair(entity):
    if entity is None:
        return Colors.Default

    if getattr(entity, "receives_damage", None):
        return Colors.Red

    return getattr(entity, "color", Colors.Default)

def get_color_pair(entity):
    return curses.color_pair(_get_color_pair(entity).value)


class Player(OwnedEntity):
    name = 'Sir Aethan'
    character = '@'

    inspects = None
    screen = None

    def __init__(self):
        self.weapon = Weapon(15, DamageKind.Slashing)
        self.health = Health(100, ArmorKind.Steel)
        self.classifiers = {Kind.Animate}
        self.controller = Controller(self)  # TODO remove this hack

    senses = Senses(25, 40, 1)

    def make_decision(self, vision, hearing, smell):
        self.screen.game.clear()
        h, w = self.screen.game.getmaxyx()
        screen_size = Vector(w - 1, h)

        for p, entity in vision.items():
            p_on_screen = p - self.screen.virtual_p
            if not (zero <= p_on_screen < screen_size): continue

            self.screen.game.addch(
                p_on_screen.y, p_on_screen.x,
                entity and entity.character or ".",
                get_color_pair(entity) | (
                    entity and entity == self.inspects and curses.A_REVERSE or 0
                )
            )

        self.screen.game.refresh()

        while True:
            hotkey = self.screen.main.getkey()
            if hotkey in self.controller.hotkeys:
                break
            log.debug(f"Ignored: [{hotkey}]")

        log.debug(f"[{hotkey}]")
        return self.controller.hotkeys[hotkey](vision, self.screen)
