from enum import Enum
from html.parser import HTMLParser

from src.engine.output.colors import ColorPair, yellow, white, red
from src.lib.toolkit import add_multiline_string


class HorizontalAlignment(Enum):
    left = 0
    center = 1
    right = 2

class VerticalAlignment(Enum):
    top = 0
    center = 1
    bottom = 2


# TODO redo in native curses calls
class CursesHtmlRenderer(HTMLParser):
    window = None
    y = None
    x = None
    color_stack = [ColorPair()]
    horizontal_alignment = HorizontalAlignment.left
    vertical_alignment = VerticalAlignment.top

    def render(self, window, html, **kwargs):
        self.window = window

        self.y = 0
        self.x = 0

        self.feed(html.replace("\n", ""))

    def handle_starttag(self, tag, attrs, **kwargs):
        match tag:
            case "center":
                self.horizontal_alignment = HorizontalAlignment.center
            case "bottom":
                self.vertical_alignment = VerticalAlignment.bottom
                self.y = self.window.getmaxyx()[0] - 1
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
                self.horizontal_alignment = HorizontalAlignment.left
            case "bottom":
                self.vertical_alignment = VerticalAlignment.top
                self.y = 0
            case "y" | "rw":
                self.color_stack.pop()
            case "div" | "p" | "li":
                self.y += 1
                self.x = 0

    def handle_data(self, data):
        h, w = self.window.getmaxyx()

        if self.horizontal_alignment == HorizontalAlignment.center:
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
