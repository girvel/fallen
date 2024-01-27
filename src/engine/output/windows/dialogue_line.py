from src.engine.output.html_window import HtmlWindow
from src.lib.query import Q
from src.lib.toolkit import soft_capitalize


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

        if sound.is_internal:
            speaker_name = None
        else:
            speaker = perception.vision["physical"].get(sound.p)
            speaker_name = soft_capitalize(str(
                self.io.memory.find_subjective_name(speaker)
                or ~Q(speaker).name
                or "???"
            ))

        return {
            "speaker_name": speaker_name,
            "line": sound.content,
        }
