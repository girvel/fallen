from dataclasses import dataclass

from src.engine.language.name import Name


@dataclass(frozen=True)
class DamageKind:
    name: Name


crushing = DamageKind(Name.auto("дробящий"))
piercing = DamageKind(Name.auto("колющий"))
slashing = DamageKind(Name.auto("режущий"))

fire = DamageKind(Name.auto("огонь"))
