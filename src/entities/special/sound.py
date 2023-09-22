from ecs import OwnedEntity


class Sound(OwnedEntity):
    name = 'Sound'
    layer = 'sounds'
    sound_flag = None

    def __init__(self, content, target=None):
        self.content = content
        self.target = target
