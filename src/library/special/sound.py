from ecs import DynamicEntity

from src.engine.language.name import Name


class Sound(DynamicEntity):
    name = Name("Звук")
    layer = 'sounds'
    sound_flag = None

    def __init__(self, parent, content, is_internal, idea, **attributes):
        self.parent = parent  # TODO change convention: parent -> creator?
        self.content = content
        self.is_internal = is_internal
        self.idea = idea

        super().__init__(**attributes)
