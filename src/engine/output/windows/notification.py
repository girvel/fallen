import math

from src.engine.output.html_window import HtmlWindow


class Notification(HtmlWindow):
    def __init__(self, io):
        self.io = io
        super().__init__(__name__, "notification.html")
        self.visible = False

    def _resize(self, notification):
        h, w = self.io.output.stdscr.getmaxyx()

        own_w = min(50, w - 1)
        own_h = min(h, 4 + math.ceil(len(notification.content) / (own_w - 2)))

        self._window.resize(own_h, own_w)
        self._window.mvwin((h - own_h) // 2, (w - own_w) // 2)

    def render(self, subject, perception):
        self.visible = (notification := self.io.memory.pop_notification()) is not None
        if not self.visible: return

        self._resize(notification)
        self.render_template(notification=notification,)
