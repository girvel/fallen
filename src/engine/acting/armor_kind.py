from dataclasses import dataclass

from src.engine.acting.damage_kind import DamageKind, piercing, crushing, slashing, fire
from src.engine.language.name import Name


@dataclass(frozen=True)
class ArmorKind:
    name: Name
    resistance: tuple[DamageKind, ...]
    vulnerability: tuple[DamageKind, ...]


none = ArmorKind(Name("-"), (), ())
steel = ArmorKind(Name.auto("сталь"), (slashing, crushing, piercing, ), ())
light_steel = ArmorKind(Name.auto("кольчуга"), (slashing, ), ())
leather = ArmorKind(Name.auto("кожа"), (slashing, ), ())

glass = ArmorKind(Name.auto("стекло"), (), (crushing, piercing, slashing, ))
wood = ArmorKind(Name.auto("дерево"), (piercing, ), (fire, ))
stone = ArmorKind(Name.auto("камень"), (piercing, slashing, ), ())
ice = ArmorKind(Name.auto("лёд"), (), (crushing, fire, ))

mennar = ArmorKind(Name({
    "им": "меннар",
    "ро": "меннара",
    "да": "меннару",
    "ви": "меннар",
    "тв": "меннаром",
    "пр": "меннаре",
}), (slashing, crushing, piercing, fire), ())
