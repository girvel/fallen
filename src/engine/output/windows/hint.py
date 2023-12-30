from src.engine.output.html_window import HtmlWindow
from src.lib.query import Q
from src.lib.toolkit import soft_capitalize


class Hint(HtmlWindow):
    package_name = __name__
    template_name = "hint.html"

    def get_size(self, subject, perception, max_size):
        return len(self.get_arguments(subject, perception)["name"]) + 2, 1

    def _calculate_visibility(self, subject, perception):
        return self.io.memory.inspect_target is not None

    def get_arguments(self, subject, perception):
        return {
            "name": soft_capitalize(str(~Q(self.io.memory.inspect_target).name or "???"))
        }