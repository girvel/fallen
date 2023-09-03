from statistics import median


class Limited:
    def __init__(self, maximum, minimum=0, current=None):
        self.maximum = maximum
        self.minimum = minimum
        self.current = current or maximum

    def move(self, offset):
        self.current = median((self.maximum, self.current + offset, self.minimum))
