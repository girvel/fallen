import curses
import sys

from ecs import OwnedEntity

from src.lib.vector import up, down, left, right, Vector
from src.systems.acting.attack import Attack
from src.systems.acting.move import Move


class Controller(OwnedEntity):
    name = 'controller'
    hotkeys = {}
    mode = Move
    controller_flag = None

    def __init__(self, controls):
        super().__init__(controls=controls)

        class _hotkey:
            def __init__(hk, *hotkeys):
                hk.hotkeys = hotkeys

            def __call__(hk, f):
                for hotkey in hk.hotkeys:
                    self.hotkeys[hotkey] = f

        def generate_movement_function(keys, direction):
            @_hotkey(*keys)
            def _(vision, screen):
                if vision.get(self.controls.p + direction) is None:
                    act = Move
                else:
                    act = self.mode

                return act(direction)

        for keys, direction in {
            ("w", ): up,
            ("s", ): down,
            ("a", ): left,
            ("d", ): right,
        }.items():
            generate_movement_function(keys, direction)

        @_hotkey("Q")
        def quit_(vision, screen):
            sys.exit()

        @_hotkey("r")
        def change_mode(vision, screen):
            self.mode = (self.mode == Move) and Attack or Move

        @_hotkey("KEY_MOUSE")
        def inspect(vision, screen):
            _, mx, my, _, _ = curses.getmouse()
            self.controls.inspects = vision.get(screen.virtual_p + Vector(mx, my))  # TODO inspects as an act

