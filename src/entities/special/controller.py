import sys

from ecs import OwnedEntity

from src.lib.vector import up, down, left, right
from src.systems.acting.attack import Attack
from src.systems.acting.move import Move


class Controller(OwnedEntity):
    name = 'controller'
    hotkeys = {}
    mode = Move

    def __init__(self, controls):
        super().__init__(controls=controls)

        class _hotkey:
            def __init__(hk, hotkeys):
                hk.hotkeys = hotkeys

            def __call__(hk, f):
                for hotkey in hk.hotkeys:
                    self.hotkeys[hotkey] = f

        def generate_movement_function(keys, direction):
            @_hotkey(*keys)
            def _(level_grid):
                if (self.controls.p + direction).get_in(level_grid) is None:
                    act = Move
                else:
                    act = self.mode

                self.controls.act = act(direction)

        for keys, direction in {
            ("w", ): up,
            ("s", ): down,
            ("a", ): left,
            ("d", ): right,
        }.items():
            generate_movement_function(keys, direction)

        @_hotkey("Q")
        def quit_(level_grid):
            sys.exit()

        @_hotkey("r")
        def change_mode(level_grid):
            self.mode = (self.mode == Move) and Attack or Move

