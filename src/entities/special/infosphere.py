from collections import defaultdict

from ecs import OwnedEntity


class Infosphere(OwnedEntity):
    name = 'Infosphere'
    information_grid = defaultdict(lambda: [])
