from src.engine.acting.actions.inspect import Inspect
from src.engine.acting.actions.move import Move
from src.engine.acting.damage import potential_damage
from src.engine.inspection import inspect
from src.engine.output.html_window import HtmlWindow
from src.lib.query import Q


class Stats(HtmlWindow):
    package_name = __name__
    template_name = "stats.html"

    mode = Move

    def get_arguments(self, subject, perception):
        return {
            "subject": subject,
            "potential_damage": int(potential_damage(subject)),
            "mode": "MOVE" if self.mode == Move else "<rw>ATTACK</rw>",
            "inspection": (inspected := ~Q(subject).act[Inspect].subject) and inspect(inspected),
        }
