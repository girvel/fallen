from statistics import median
from typing import Optional


class Limited:
    def __init__(self, maximum: int, minimum: int = 0, current: Optional[int] = None):
        self.maximum: int = maximum
        self.minimum: int = minimum
        self.current: int = current if current is not None else maximum - 1

    def move(self, offset: int):
        self.current = median((self.maximum - 1, self.current + offset, self.minimum))

    def is_min(self) -> bool:
        return self.current == self.minimum

    def is_max(self) -> bool:
        return self.current == self.maximum - 1

    def reset_to_max(self):
        self.current = self.maximum - 1

    def ratio(self) -> float:
        return (self.current - self.minimum) / (self.maximum - self.minimum - 1)
