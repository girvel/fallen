from ecs import DynamicEntity

from src.engine.naming.name import Name


class Sound(DynamicEntity):
    name = Name("Звук")
    layer = 'sounds'
    sound_flag = None

    def __init__(self, parent, content, is_internal, meme, **attributes):
        self.parent = parent
        self.content = content
        self.is_internal = is_internal
        self.meme = meme

        super().__init__(**attributes)
