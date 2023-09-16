from ecs import OwnedEntity


class Genesis(OwnedEntity):
    name = 'genesis'

    def __init__(self):
        self.entities_to_create = []
