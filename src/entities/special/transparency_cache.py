import logging

import numpy
from ecs import OwnedEntity


class TransparencyCache(OwnedEntity):
    name = 'Transparency Cache'

    def __init__(self, size):
        self.transparency_array = numpy.full(size, 1)
