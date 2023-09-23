from ecs import OwnedEntity


class Sound(OwnedEntity):
    name = 'Sound'
    layer = 'sounds'
    sound_flag = None

    def __init__(self, content, is_internal=False, p=None):
        self.content = content
        self.is_internal = is_internal

        if p is not None:
            self.p = p
