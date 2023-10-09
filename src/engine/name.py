from dataclasses import dataclass


@dataclass
class Name:
    cases: dict

    def __str__(self):
        return self.cases["им"]

    def __format__(self, format_spec):
        return self.cases.get(format_spec, self.cases["им"])


@dataclass
class CompositeName:
    first: Name
    last: Name

    def __str__(self):
        return f"{self.first} {self.last}"

    def __format__(self, format_spec):
        return f"{self.first.__format__(format_spec)} {self.last.__format__(format_spec)}"