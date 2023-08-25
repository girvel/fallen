from ecs import OwnedEntity


class Player(OwnedEntity):
    name = 'player_character'
    character = '@'
    health = 100
    power = 15
