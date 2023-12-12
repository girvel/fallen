from dataclasses import dataclass

import pymorphy2

from src.lib.query import Q

_analyzer = pymorphy2.MorphAnalyzer()
_cases = {
    "им": "nomn",
    "ро": "gent",
    "да": "datv",
    "ви": "accs",
    "тв": "ablt",
    "пр": "loct",
}


@dataclass(frozen=True, init=False)
class Name:
    cases: dict  # TODO frozen dict

    def __init__(self, source: str | dict):
        match source:
            case str(text): object.__setattr__(self, "cases", {"им": text})
            case dict(cases): object.__setattr__(self, "cases", cases)
            case arg: raise TypeError(f"Name({type(arg)}) is impossible")

    def __str__(self):
        return self.cases["им"]

    def __format__(self, format_spec):
        return self.cases.get(format_spec, self.cases["им"])

    def __hash__(self):
        return hash(tuple(self.cases.values()))

    def concat(self, postfix: str):
        return Name({
            case_name: case + postfix
            for case_name, case in self.cases.items()
        })

    @classmethod
    def auto(cls, source: str, variant: int = 0):
        if " " in source:
            source, postfix = source.split(' ', maxsplit=1)
        else:
            postfix = ""

        parses = [parse for parse in _analyzer.parse(source) if "nomn" in parse.tag]

        if len(parses) == 0:
            return Name(source)

        parse = parses[variant]
        optionally_capitalize = (lambda x: x.capitalize()) if source[0].isupper() else (lambda x: x)

        return Name({
            ru_case: optionally_capitalize(~Q(parse.inflect({en_case})).word or source)
            for ru_case, en_case in _cases.items()
        }).concat(postfix)

@dataclass(frozen=True)
class CompositeName:
    first: Name
    last: Name

    def __str__(self):
        return f"{self.first} {self.last}"

    def __format__(self, format_spec):
        return f"{self.first.__format__(format_spec)} {self.last.__format__(format_spec)}"
