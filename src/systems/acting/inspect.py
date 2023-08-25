from collections import namedtuple


class Inspect(namedtuple("InspectBase", "subject")):
    def execute(self, actor, level, hades):
        pass
