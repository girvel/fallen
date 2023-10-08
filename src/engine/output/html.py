from html.parser import HTMLParser

from src.engine.output.colors import ColorPair, yellow, white, red
from src.lib.toolkit import add_multiline_string


class CursesHtmlRenderer(HTMLParser):
    window = None
    y = None
    x = None
    padding_x = None
    color_stack = [ColorPair()]
    centering = False

    def render_template(self, window, template, **kwargs):
        self.window = window

        self.y = 0
        self.x = 0

        self.feed(template.render(**kwargs).replace("\n", ""))

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
                    self.padding_y, self.padding_x,
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
                self.x = self.padding_x

    def handle_data(self, data):
        h, w = self.window.getmaxyx()

        if self.centering:
            self.x += (w - self.padding_x * 2 - len(data)) // 2  # TODO multiline

        data = data.lstrip(" ")
        if len(data) == 0: return

        self.y, self.x = add_multiline_string(
            self.window,
            self.y, self.x,
            self.padding_y, self.padding_x,
            h, w,
            data, self.color_stack[-1],
        )
