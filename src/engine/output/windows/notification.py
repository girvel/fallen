import math

from jinja2 import Environment, PackageLoader

from src.engine.output.html import html_renderer
from src.engine.output.window import Window


class Notification(Window):
    package_name = __name__
    template_name = "notification.html"

    def __init__(self, *args, **kwargs):
        self.jinja_environment = Environment(loader=PackageLoader(self.package_name), autoescape=True)
        super().__init__(*args, **kwargs)

    def responsive_size(self, subject, perception, max_size):
        w = min(50, max_size[0] - 1)
        h = min(max_size[1], 4 + math.ceil(len(self.io.memory.current_notification.content) / (w - 2)))

        return w, h

    def _calculate_visibility(self, subject, perception):
        return bool(self.io.memory.current_notification)

    def _render(self, subject, perception):
        self.curses_window.clear()

        html_renderer.render(
            self.curses_window,
            self.jinja_environment.get_template(self.template_name).render(
                notification=self.io.memory.current_notification
            )
        )

        self.curses_window.refresh()
