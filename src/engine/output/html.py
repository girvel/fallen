"""HTML rendering engine.

Has some restrictions:
- Can not horizontally align complex data (only the contents of one tag)
"""

import re
from html.parser import HTMLParser

from src.engine.output.colors import ColorPair, yellow, white, red, green
from src.engine.output.grid_rendering import put_string_on_grid, HorizontalAlignment, VerticalAlignment


class CursesHtmlRenderer(HTMLParser):
    array = None
    size = None
    color_stack = [ColorPair()]
    horizontal_alignment = HorizontalAlignment.left
    vertical_alignment = VerticalAlignment.top

    def render(self, size, html, **kwargs):
        self.array = [[" "] * size[0]]
        self.size = size
        self.cursor_p = (0, 0)
        self.feed(re.sub(r"\n\s*", "", html))
        return self.array, (size[0], len(self.array))

    def handle_starttag(self, tag, attrs, **kwargs):
        attrs = dict(attrs)

        match tag:
            case "center":
                self.horizontal_alignment = HorizontalAlignment.center
            case "right":
                self.horizontal_alignment = HorizontalAlignment.right
            case "bottom":
                self.vertical_alignment = VerticalAlignment.bottom
                self.cursor_p = (0, self.size[1] - 1)
            case "y":
                self.color_stack.append(ColorPair(yellow))
            case "g":
                self.color_stack.append(ColorPair(green))
            case "rw":
                self.color_stack.append(ColorPair(white, red))
            case "li":
                self.cursor_p = put_string_on_grid(
                    self.array, self.size, self.cursor_p, "- ", ColorPair(yellow).to_curses(),
                    self.horizontal_alignment, self.vertical_alignment,
                )
            case "color":
                self.color_stack.append(ColorPair.from_code(int(attrs["code"])))

    def handle_endtag(self, tag):
        match tag:
            case "center" | "right":
                self.horizontal_alignment = HorizontalAlignment.left
            case "bottom":
                self.vertical_alignment = VerticalAlignment.top
                self.cursor_p = (0, 0)
            case "y" | "rw" | "color" | "g":
                self.color_stack.pop()
            case "div" | "p" | "li" | "br":
                _, y = self.cursor_p
                self.cursor_p = (0, y + self.vertical_alignment.value)

    def handle_data(self, data):
        self.cursor_p = put_string_on_grid(
            self.array, self.size, self.cursor_p, data, self.color_stack[-1].to_curses(),
            self.horizontal_alignment, self.vertical_alignment,
        )


html_renderer = CursesHtmlRenderer()
