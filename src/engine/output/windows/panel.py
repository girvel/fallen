from src.assets.actions.move import Move
from src.engine.output.html_window import HtmlWindow
from src.engine.output.windows.panes.chat import Chat
from src.engine.output.windows.panes.controls import Controls
from src.engine.output.windows.panes.inventory import Inventory
from src.engine.output.windows.panes.quests import Quests
from src.engine.output.windows.panes.stats import Stats
from src.lib.limited import Limited
from src.lib.vector.vector import flip2


class Panel(HtmlWindow):
    package_name = __name__
    template_name = "panel.html"
    has_border = True

    def __post_init__(self):
        self.panes = [
            Controls(self.curses_window, self.io),
            Inventory(self.curses_window, self.io),
            Quests(self.curses_window, self.io),
            Chat(self.curses_window, self.io),
        ]
        self.pane_i = Limited(len(self.panes), 0, 2)

    def get_arguments(self, subject, perception):
        return {
            "previous_pane_name": self.panes[self.pane_i.current - 1].name if not self.pane_i.is_min() else None,
            "next_pane_name": self.panes[self.pane_i.current + 1].name if not self.pane_i.is_max() else None,
            "pane_name": self.panes[self.pane_i.current].name,
        }

    def _render(self, subject, perception):
        super()._render(subject, perception)
        self.panes[self.pane_i.current].render(
            subject, perception,
            flip2(self.curses_window.getmaxyx()),
            (0, 2),
        )

    def _calculate_visibility(self, subject, perception):
        return not self.io.memory.in_cutscene

    def get_size(self, subject, perception, max_size):
        return min(max_size[0] - 6, 35), max_size[1] - 12
