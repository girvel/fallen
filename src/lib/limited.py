from statistics import median


class Limited:
    def __init__(self, maximum, minimum=0, current=None):
        self.maximum = maximum
        self.minimum = minimum
        self.current = current if current is not None else maximum - 1

    def move(self, offset):
        self.current = median((self.maximum - 1, self.current + offset, self.minimum))

    def is_min(self):
        return self.current == self.minimum

    def is_max(self):
        return self.current == self.maximum - 1

    def reset_to_max(self):
        self.current = self.maximum - 1
