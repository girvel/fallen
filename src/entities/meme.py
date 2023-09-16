from ecs import OwnedEntity


class Meme(OwnedEntity):
    name = 'Meme'

    def __init__(self, author, value):
        self.author = author
        self.value = value
