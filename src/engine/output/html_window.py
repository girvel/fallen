import curses
from abc import abstractmethod, ABC

from jinja2 import Environment, PackageLoader

from src.engine.output.html import CursesHtmlRenderer
from src.lib.vector import sub2


class HtmlWindow(ABC):
    def __init__(self, package_name, template_name):
        self._window = curses.newwin(3, 5, 0, 0)
        self._inner_window = self._window.derwin(1, 1)
        self.html_renderer = CursesHtmlRenderer()
        self.env = Environment(loader=PackageLoader(package_name), autoescape=True)
        self.template_name = template_name

    def resize(self):
        self.resize_outer()
        self._inner_window.resize(*sub2(self._window.getmaxyx(), (2, 4)))

    @abstractmethod
    def resize_outer(self):
        ...

    def render_template(self, **parameters):
        self._window.clear()
        self._window.border()

        self.html_renderer.render_template(
            self._window, 1, 2, self.env.get_template(self.template_name),
            **parameters,
        )

        self._window.refresh()
