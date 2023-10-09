from dataclasses import dataclass
from functools import singledispatchmethod


@dataclass
class Name:
    cases: dict

    @singledispatchmethod
    def __init__(self, arg):
        raise TypeError(f"Name({type(arg)}) is impossible")

    @__init__.register
    def _(self, text: str):
        self.cases = {"им": text}

    @__init__.register
    def _(self, cases: dict):
        self.cases = cases

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