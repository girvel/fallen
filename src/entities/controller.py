import sys

from ecs import OwnedEntity

from src.lib.vector import up, down, left, right


class Controller(OwnedEntity):
    def __init__(self, controls):
        super().__init__(name='controller', controls=controls, hotkeys={})

        class _hotkey:
            def __init__(hk, hotkey):
                hk.hotkey = hotkey

            def __call__(hk, f):
                self.hotkeys[hk.hotkey] = f

        @_hotkey("w")
        def move_up(pc):
            pc.v = up

        @_hotkey("s")
        def move_down(pc):
            pc.v = down

        @_hotkey("a")
        def move_down(pc):
            pc.v = left

        @_hotkey("d")
        def move_down(pc):
            pc.v = right

        @_hotkey("Q")
        def quit_(pc):
            sys.exit()

