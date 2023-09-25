import logging

import numpy
from ecs import DynamicEntity


class TransparencyCache(DynamicEntity):
    name = 'Transparency Cache'

    def __init__(self, size):
        self.transparency_array = numpy.full(size, 1)
