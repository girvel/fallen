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
        name_raw = ~Q(self.io.memory.inspect_target).name or "???"

        if (subjective_name := self.io.memory.find_subjective_name(self.io.memory.inspect_target)) is not None:
            name = f"{soft_capitalize(str(subjective_name))} ({name_raw})"
        else:
            name = soft_capitalize(str(name_raw))

        return {
            "name": name,
        }
