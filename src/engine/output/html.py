from html.parser import HTMLParser

from src.engine.output.colors import ColorPair, yellow, white, red
from src.lib.toolkit import add_multiline_string


# TODO redo in native curses calls
class CursesHtmlRenderer(HTMLParser):
    window = None
    y = None
    x = None
    color_stack = [ColorPair()]
    centering = False

    def render(self, window, html, **kwargs):
        self.window = window

        self.y = 0
        self.x = 0

        self.feed(html.replace("\n", ""))

    def handle_starttag(self, tag, attrs, **kwargs):
        match tag:
            case "center":
                self.centering = True
            case "y":
                self.color_stack.append(ColorPair(yellow))
            case "rw":
                self.color_stack.append(ColorPair(white, red))
            case "li":
                h, w = self.window.getmaxyx()
                self.y, self.x = add_multiline_string(
                    self.window,
                    self.y, self.x,
                    0, 0,
                    h, w,
                    "- ", ColorPair(yellow),
                )

    def handle_endtag(self, tag):
        match tag:
            case "center":
                self.centering = False
            case "y" | "rw":
                self.color_stack.pop()
            case "div" | "p" | "li":
                self.y += 1
                self.x = 0

    def handle_data(self, data):
        h, w = self.window.getmaxyx()

        if self.centering:
            self.x += (w - len(data)) // 2  # TODO multiline

        data = data.lstrip(" ")
        if len(data) == 0: return

        self.y, self.x = add_multiline_string(
            self.window,
            self.y, self.x,
            0, 0,
            h, w,
            data, self.color_stack[-1],
        )


html_renderer = CursesHtmlRenderer()
