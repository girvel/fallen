from src.engine.acting.actions.inspect import Inspect
from src.engine.acting.actions.move import Move
from src.engine.acting.damage import potential_damage
from src.engine.inspection import inspect
from src.engine.output.windows.panes.pane import Pane
from src.lib.query import Q


class Stats(Pane):
    template_name = "stats.html"
    name = "Характеристики"

    def get_arguments(self, subject, perception):
        return {
            "subject": subject,
            "potential_damage": int(potential_damage(subject)),
            "mode": "MOVE" if self.io.output.panel.mode == Move else "<rw>ATTACK</rw>",
            "inspection": (inspected := ~Q(subject).act[Inspect].subject) and inspect(inspected),
        }
