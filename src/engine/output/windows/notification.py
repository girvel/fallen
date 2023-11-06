import math

from src.engine.output.html_window import HtmlWindow


class Notification(HtmlWindow):
    package_name = __name__
    template_name = "notification.html"
    has_border = True

    def _responsive_size(self, subject, perception, max_size):
        w = min(46, max_size[0] - 1)
        h = min(max_size[1], 4 + math.ceil(len(self.io.memory.current_notification.content) / w))

        return w, h

    def _calculate_visibility(self, subject, perception):
        return bool(self.io.memory.current_notification)

    def get_arguments(self, subject, perception):
        return {
            "notification": self.io.memory.current_notification,
        }
