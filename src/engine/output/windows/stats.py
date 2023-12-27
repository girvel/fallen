import math

from src.engine.output.colors import ColorPair, green, red
from src.engine.output.html_window import HtmlWindow
from src.lib.query import Q


class Stats(HtmlWindow):
    package_name = __name__
    template_name = "stats.html"
    has_border = True

    def get_arguments(self, subject, perception):
        if (health := ~Q(subject).health) is not None:
            hp_value = f"{health.amount.current}/{health.amount.maximum - 1}"

            max_length = 25
            healthy_length = int(health.amount.ratio() * max_length)

            hp_bar = "|" * healthy_length + " " * (max_length - healthy_length)

            hp_bar = (
                hp_bar[:max_length // 2 - math.floor(len(hp_value) / 2)] +
                hp_value +
                hp_bar[max_length // 2 + math.ceil(len(hp_value) / 2):]
            )

            hp_bar = (hp_bar[:healthy_length], hp_bar[healthy_length:])
        else:
            hp_bar = ("", "-")

        return {
            "hp_bar": hp_bar,
            "hp_bar_color": ColorPair(green if ~Q(subject).last_damaged_by in (0, None) else red).to_code()
        }

    def _responsive_size(self, subject, perception, max_size):
        return min(max_size[0] - 6, 35), 8
