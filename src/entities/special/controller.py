import curses
import sys

from ecs import OwnedEntity

from src.lib.vector import up, down, left, right, Vector
from src.systems.acting.attack import Attack
from src.systems.acting.move import Move

import logging

log = logging.getLogger(__name__)


class Controller(OwnedEntity):
    name = 'controller'
    hotkeys = {}
    mode = Move
    controller_flag = None

    def __init__(self):
        self.hotkeys = generate_default_hotkeys()

    def wait_for_input(self, screen, subject, vision):
        while True:
            hotkey = screen.main.getkey()
            if hotkey in self.hotkeys:
                break
            log.debug(f"Ignored: [{hotkey}]")

        log.debug(f"[{hotkey}]")
        return self.hotkeys[hotkey](subject, vision, self, screen)


def generate_default_hotkeys():
    result = {}

    class _hotkey:
        def __init__(self, *hotkeys):
            self.hotkeys = hotkeys

        def __call__(self, f):
            for hotkey in self.hotkeys:
                result[hotkey] = f

    def generate_movement_function(keys, direction):
        @_hotkey(*keys)
        def _(subject, vision, controller, screen):
            if vision.get(subject.p + direction) is None:
                act = Move
            else:
                act = controller.mode

            return act(direction)

    for keys, direction in {
        ("w", ): up,
        ("s", ): down,
        ("a", ): left,
        ("d", ): right,
    }.items():
        generate_movement_function(keys, direction)

    @_hotkey("Q")
    def quit_(subject, vision, controller, screen):
        sys.exit()

    @_hotkey("r")
    def change_mode(subject, vision, controller, screen):
        controller.mode = (controller.mode == Move) and Attack or Move

    @_hotkey("KEY_MOUSE")
    def inspect(subject, vision, controller, screen):
        _, mx, my, _, _ = curses.getmouse()
        subject.inspects = vision.get(screen.virtual_p + Vector(mx, my))  # TODO inspects as an act

    return result
