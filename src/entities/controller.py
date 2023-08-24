import sys

from ecs import OwnedEntity

from src.lib.vector import up, down, left, right


def create(pc):
    controller = OwnedEntity(name='controller', controls=pc, hotkeys={})

    class hotkey:
        def __init__(self, hotkey):
            self.hotkey = hotkey

        def __call__(self, f):
            controller.hotkeys[self.hotkey] = f

    @hotkey("w")
    def move_up(pc):
        pc.p += up

    @hotkey("s")
    def move_down(pc):
        pc.p += down

    @hotkey("a")
    def move_down(pc):
        pc.p += left

    @hotkey("d")
    def move_down(pc):
        pc.p += right

    @hotkey("Q")
    def quit(pc):
        sys.exit()

    return controller
