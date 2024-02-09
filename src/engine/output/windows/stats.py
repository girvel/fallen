import math

from src.assets.actions.hand_attack import HandAttack
from src.engine.language.name import Name
from src.engine.output.colors import ColorPair, green, red, white
from src.engine.output.html_window import HtmlWindow
from src.lib.limited import Limited
from src.lib.query import Q


class Stats(HtmlWindow):
    package_name = __name__
    template_name = "stats.html"
    has_border = True

    def get_size(self, subject, perception, max_size):
        return 35, 8

    def get_border_attributes(self, subject, perception):
        return ColorPair(red if self.io.memory.movement_mode is HandAttack else white).to_curses()

    def get_arguments(self, subject, perception):
        if (weapon := subject.inventory.hand) is not None:
            weapon_name = weapon.name
            weapon_damage = weapon.damage
        else:
            weapon_name = Name.auto("кулаки")
            weapon_damage = 1

        return {
            "character_name": str(~Q(subject).name or "???"),
            "hp_bar": self._build_hp_bar(~Q(subject).health),
            "hp_bar_color": ColorPair(green if ~Q(subject).last_damaged_by in (0, None) else red).to_code(),
            "weapon": {
                "name": weapon_name,
                "damage": weapon_damage,
                "is_out": self.io.memory.movement_mode is HandAttack,
            },
        }

    def _calculate_visibility(self, subject, perception):
        return not self.io.memory.in_cutscene

    def _build_hp_bar(self, health: Limited | None) -> tuple[str, str]:
        if health is None: return "", "-"

        hp_value = f"{health.current}/{health.maximum - 1}"

        max_length = 25
        healthy_length = int(health.ratio() * max_length)

        hp_bar = "|" * healthy_length + " " * (max_length - healthy_length)

        hp_bar = (
            hp_bar[:max_length // 2 - math.floor(len(hp_value) / 2)] +
            hp_value +
            hp_bar[max_length // 2 + math.ceil(len(hp_value) / 2):]
        )

        return hp_bar[:healthy_length], hp_bar[healthy_length:]
