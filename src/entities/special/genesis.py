from ecs import DynamicEntity


class Genesis(DynamicEntity):
    name = 'genesis'

    def __init__(self):
        self.entities_to_create = set()
