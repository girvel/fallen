from abc import ABCMeta

from src.engine.output.html_window import HtmlWindow
from src.lib.vector.vector import sub2


class Pane(HtmlWindow, metaclass=ABCMeta):
    package_name = __name__

    def _responsive_size(self, subject, perception, max_size):
        return sub2(max_size, (0, 5))
