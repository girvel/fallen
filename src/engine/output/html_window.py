from abc import abstractmethod, ABCMeta

from jinja2 import Environment, PackageLoader

from src.engine.output.html import html_renderer
from src.engine.output.window import Window


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

    def __init__(self, *args, **kwargs):
        self.jinja_environment = Environment(loader=PackageLoader(self.package_name), autoescape=True)
        super().__init__(*args, **kwargs)

    def _render(self, subject, perception):
        self.curses_window.clear()

        html_renderer.render(
            self.curses_window,
            self.jinja_environment.get_template(self.template_name).render(
                **self.get_arguments(subject, perception),
            )
        )

        self.curses_window.refresh()
