from random import randrange


class RandomPeriod:
    def __init__(self, min, max):
        self.min = min
        self.max = max
        self.end = randrange(min, max)
        self.value = 0

    def step(self, step=1):
        if self.step_without_reset(step):
            return self.reset()
        return 0

    def step_without_reset(self, step=1):
        self.value += step
        return self.value >= self.end

    def reset(self):
        old_length = self.end
        self.value = max(0, self.end - self.value)
        self.end = randrange(self.min, self.max)
        return old_length
