import sys

from ecs import OwnedEntity

from src.lib.vector import up, down, left, right
from src.systems.acting import Act


class Controller(OwnedEntity):
    def __init__(self, controls):
        super().__init__(name='controller', controls=controls, hotkeys={}, mode=Act.Move)

        class _hotkey:
            def __init__(hk, hotkeys):
                hk.hotkeys = hotkeys

            def __call__(hk, f):
                for hotkey in hk.hotkeys:
                    self.hotkeys[hotkey] = f

        def generate_movement_function(keys, direction):
            @_hotkey(*keys)
            def _():
                match self.mode:
                    case Act.Move:
                        self.controls.act = Act.Move(direction)
                    case Act.Attack:
                        self.controls.act = Act.Attack(direction)

        for keys, direction in {
            ("w", ): up,
            ("s", ): down,
            ("a", ): left,
            ("d", ): right,
        }.items():
            generate_movement_function(keys, direction)

        @_hotkey("Q")
        def quit_():
            sys.exit()

        @_hotkey("r")
        def change_mode():
            self.mode = (self.mode == Act.Move) and Act.Attack or Act.Move

