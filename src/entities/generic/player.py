from ecs import OwnedEntity

from src.systems.acting.attack import DamageKind, ArmorKind, Weapon, Health
from src.systems.ai import Kind, Senses


class Player(OwnedEntity):
    name = 'Sir Aethan'
    character = '@'
    solid_flag = None

    inspects = None
    screen = None
    controller = None

    def __init__(self):
        self.weapon = Weapon(15, DamageKind.Slashing)
        self.health = Health(100, ArmorKind.Steel)
        self.classifiers = {Kind.Animate}

    def initialize(self, controller, screen):
        self.controller = controller
        self.screen = screen  # TODO controller+screen as I/O entity

    senses = Senses(25, 40, 1)

    def make_decision(self, perception):
        self.screen.resize_windows()
        self.screen.move_camera(self)
        self.screen.display_perception(self, perception)
        self.screen.display_gui(self.controller, self)
        return self.controller.wait_for_input(self.screen, self, perception.vision)
