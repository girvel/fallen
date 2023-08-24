import sys

from ecs import OwnedEntity

from src.lib.vector import up, down, left, right


controller = OwnedEntity(name='controller', controls=None, hotkeys={})

class hotkey:
    def __init__(self, hotkey):
        self.hotkey = hotkey

    def __call__(self, f):
        controller.hotkeys[self.hotkey] = f

@hotkey("w")
def move_up(pc):
    pc.v = up

@hotkey("s")
def move_down(pc):
    pc.v = down

@hotkey("a")
def move_down(pc):
    pc.v = left

@hotkey("d")
def move_down(pc):
    pc.v = right

@hotkey("Q")
def quit_(pc):
    sys.exit()
