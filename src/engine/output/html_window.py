import curses

from jinja2 import Environment, PackageLoader

from src.engine.output.html import CursesHtmlRenderer


class HtmlWindow:
    def __init__(self, package_name, template_name):
        self._window = curses.newwin(1, 1, 0, 0)
        self.html_renderer = CursesHtmlRenderer()
        self.env = Environment(loader=PackageLoader(package_name), autoescape=True)
        self.template_name = template_name

    def render_template(self, **parameters):
        self._window.clear()
        self._window.border()

        self.html_renderer.render_template(
            self._window, 1, 2, self.env.get_template(self.template_name),
            **parameters,
        )

        self._window.refresh()
