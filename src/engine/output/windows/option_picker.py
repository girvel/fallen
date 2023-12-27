import math

from src.engine.output.html_window import HtmlWindow


class OptionPicker(HtmlWindow):
    package_name = __name__
    template_name = "option_picker.html"
    has_border = True

    def _responsive_size(self, subject, perception, max_size):
        w = min(36, max_size[0] - 1)
        h = min(max_size[1], sum(math.ceil(len(o) / (w - 2)) for o in self.io.memory.options))

        return w, h

    def _calculate_visibility(self, subject, perception):
        return self.io.memory.options is not None

    def get_arguments(self, subject, perception):
        return {
            "options": self.io.memory.options,
            "selected_option_i": self.io.memory.selected_option_i
        }
