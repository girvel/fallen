from dataclasses import dataclass


@dataclass(frozen=True, init=False)
class Name:
    cases: dict

    def __init__(self, source: str | dict):
        match source:
            case str(text): object.__setattr__(self, "cases", {"им": text})
            case dict(cases): object.__setattr__(self, "cases", cases)
            case arg: raise TypeError(f"Name({type(arg)}) is impossible")

    def __str__(self):
        return self.cases["им"]

    def __format__(self, format_spec):
        return self.cases.get(format_spec, self.cases["им"])


@dataclass(frozen=True)
class CompositeName:
    first: Name
    last: Name

    def __str__(self):
        return f"{self.first} {self.last}"

    def __format__(self, format_spec):
        return f"{self.first.__format__(format_spec)} {self.last.__format__(format_spec)}"