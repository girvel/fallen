from ecs import DynamicEntity

from src.engine.name import Name


class Sound(DynamicEntity):
    name = Name("Sound")
    layer = 'sounds'
    sound_flag = None

    def __init__(self, content, is_internal, meme, **attributes):
        self.content = content
        self.is_internal = is_internal
        self.meme = meme

        super().__init__(**attributes)
