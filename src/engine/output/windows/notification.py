import curses
import math

from jinja2 import PackageLoader, Environment

from src.engine.output.html import CursesHtmlRenderer


class Notification:
    def __init__(self):
        self._window = curses.newwin(1, 1, 0, 0)

        self.html_renderer = CursesHtmlRenderer()
        env = Environment(loader=PackageLoader(__name__), autoescape=True)
        self.template = env.get_template("notification.html")
        self.visible = False

    def resize(self, h, w):
        self.last_parent_h = h
        self.last_parent_w = w

    def responsive_resize(self, notification):
        h = self.last_parent_h
        w = self.last_parent_w

        own_w = min(50, w - 1)
        own_h = min(h, 4 + math.ceil(len(notification.content) / (own_w - 2)))

        self._window.resize(own_h, own_w)
        self._window.mvwin((h - own_h) // 2, (w - own_w) // 2)

    def render(self, subject, perception, level, memory):
        self.visible = (notification := memory.pop_notification()) is not None
        if not self.visible: return

        self.responsive_resize(notification)

        self._window.clear()
        self._window.border()

        self.html_renderer.render_template(self._window, 1, 2, self.template,
            notification=notification,
        )

        self._window.refresh()
