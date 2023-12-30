import curses

from src.engine.output.colors import ColorPair, yellow
from src.engine.output.html_window import HtmlWindow
from src.lib.query import Q
from src.lib.toolkit import add_multiline_string, soft_capitalize


class DialogueLine(HtmlWindow):
    package_name = __name__
    template_name = "dialogue_line.html"
    has_border = True

    def get_size(self, subject, perception, max_size):
        return min(80, max_size[0] - 20), 5

    def _calculate_visibility(self, subject, perception):
        return self.io.memory.current_sound is not None

    def get_arguments(self, subject, perception):
        sound = self.io.memory.current_sound

        return {
            "speaker": soft_capitalize(str(
                ~Q(perception.vision["physical"].get(sound.p)).name or "???"
            )) if not sound.is_internal else None,
            "line": sound.content,
        }
