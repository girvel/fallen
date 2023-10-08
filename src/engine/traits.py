from src.lib.limited import AssertLimited


class Traits:
    def __init__(self):
        self.naivity = AssertLimited[0:3](0)
        self.pain = AssertLimited[0:3](0)
        self.chaos = AssertLimited[0:2](0)
