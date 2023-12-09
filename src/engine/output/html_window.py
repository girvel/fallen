import curses
from abc import abstractmethod, ABCMeta

from jinja2 import Environment, PackageLoader

from src.engine.output.grid_rendering import render_grid
from src.engine.output.html import html_renderer
from src.engine.output.window import Window
from src.lib.limited import Limited
from src.lib.vector.vector import add2, flip2
from src.lib.vector.grid import grid_size


class HtmlWindow(Window, metaclass=ABCMeta):
    @property
    @abstractmethod
    def package_name(self):
        ...

    @property
    @abstractmethod
    def template_name(self):
        ...

    @abstractmethod
    def get_arguments(self, subject, perception):
        ...

    has_border = False

    def __init__(self, parent, io):
        self.jinja_environment = Environment(loader=PackageLoader(self.package_name), autoescape=True)
        self.border_curses_window = curses.newwin(1, 1, 0, 0) if self.has_border else None
        self.scroll = Limited(1, 0)
        super().__init__(parent, io)
        self.__post_init__()

    def __post_init__(self):
        pass

    def _render(self, subject, perception):
        self.curses_window.clear()

        if self.border_curses_window:
            # TODO border window can get out of bounds
            # TODO => border should probably be done by hand
            self.border_curses_window.resize(*add2(self.curses_window.getmaxyx(), (2, 6)))
            self.border_curses_window.mvwin(*add2(self.curses_window.getbegyx(), (-1, -3)))

            self.border_curses_window.clear()
            self.border_curses_window.border()
            self.border_curses_window.refresh()

        grid = html_renderer.render(
            flip2(self.curses_window.getmaxyx()),
            self.jinja_environment.get_template(self.template_name).render(
                **self.get_arguments(subject, perception),
            )
        )

        self.scroll.maximum = max(0, grid_size(grid)[1] - self.curses_window.getmaxyx()[0]) + 1

        render_grid(grid, self.curses_window, self.scroll.current)  # TODO use render_grid in Game window

        self.curses_window.refresh()


