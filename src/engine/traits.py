from dataclasses import dataclass, field

from src.lib.limited import AssertLimited


@dataclass
class Traits:
    naivity: AssertLimited = field(default_factory=lambda: AssertLimited(2, 0, 0))
    pain: AssertLimited = field(default_factory=lambda: AssertLimited(2, 0, 0))
    chaos: AssertLimited = field(default_factory=lambda: AssertLimited(1, 0, 0))
