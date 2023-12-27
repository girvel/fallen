from src.engine.language.name import Name
from src.assets.abstract.material import Material


class Sound(Material):
    name = Name.auto("звук")
    layer = 'sounds'

    sound_flag = None
    boring_flag = None

    def __post_init__(self, parent, content, is_internal, idea):
        self.parent = parent  # TODO change convention: parent -> creator?
        self.content = content
        self.is_internal = is_internal
        self.idea = idea
