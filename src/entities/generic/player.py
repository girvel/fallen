from ecs import OwnedEntity


class Player(OwnedEntity):
    character = '@'

    def __init__(self):
        super().__init__(name='player_character', health=100, power=15)
