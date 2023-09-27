from ecs import DynamicEntity


class Sound(DynamicEntity):
    name = 'Sound'
    layer = 'sounds'
    sound_flag = None

    def __init__(self, content, is_internal, meme, p=None):
        self.content = content
        self.is_internal = is_internal
        self.meme = meme

        if p is not None:
            self.p = p
