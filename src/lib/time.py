from dataclasses import dataclass


@dataclass(frozen=True, init=False, repr=False)
class Time:
    total_seconds: int = 0

    def __init__(self, hours=0, minutes=0, seconds=0):
        object.__setattr__(self, "total_seconds", hours * 3600 + minutes * 60 + seconds)

    def get_hours(self) -> int:
        return self.total_seconds // 3600

    def get_minutes(self) -> int:
        return self.total_seconds % 3600 // 60

    def get_seconds(self) -> int:
        return self.total_seconds % 60

    def __add__(self, other: "Time"):
        return Time(seconds=(self.total_seconds + other.total_seconds) % 86400)

    def __sub__(self, other):
        return Time(seconds=(self.total_seconds - other.total_seconds) % 86400)

    def __hash__(self):
        return hash(self.total_seconds)

    def __repr__(self):
        return (
            f"{type(self).__name__}(hours={self.get_hours()}, minutes={self.get_minutes()}, "
            f"seconds={self.get_seconds()})"
        )
