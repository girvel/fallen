class Period:
    def __init__(self, end):
        self.end = end
        self.value = 0

    def step(self, step=1):
        self.value += step
        if self.value >= self.end:
            self.value = self.end - self.value
            return True
        return False
