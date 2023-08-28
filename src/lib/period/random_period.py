from random import randrange


class RandomPeriod:
    def __init__(self, min, max):
        self.min = min
        self.max = max
        self.end = randrange(min, max)
        self.value = 0

    def step(self, step=1):
        self.value += step
        if self.value >= self.end:
            old_length = self.end
            self.value = self.end - self.value
            self.end = randrange(self.min, self.max)
            return old_length
        return 0
