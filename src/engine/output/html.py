import re
from enum import Enum
from html.parser import HTMLParser

from src.engine.output.colors import ColorPair, yellow, white, red
from src.engine.output.grid_rendering import put_string_on_grid
from src.lib.vector import create_grid, grid_size


class HorizontalAlignment(Enum):
    left = 0
    center = 1
    right = 2


class VerticalAlignment(Enum):
    top = 1
    bottom = -1


class CursesHtmlRenderer(HTMLParser):
    grid = None
    color_stack = [ColorPair()]
    horizontal_alignment = HorizontalAlignment.left
    vertical_alignment = VerticalAlignment.top

    def render(self, size, html, **kwargs):
        self.grid = create_grid(size, lambda: " ")
        self.cursor_p = (0, 0)
        self.feed(re.sub(r"\n\s*", "", html))
        return self.grid

    def handle_starttag(self, tag, attrs, **kwargs):
        attrs = dict(attrs)

        match tag:
            case "center":
                self.horizontal_alignment = HorizontalAlignment.center
            case "right":
                self.horizontal_alignment = HorizontalAlignment.right
                self.cursor_p = (grid_size(self.grid)[0] - 1, self.cursor_p[1])
            case "bottom":
                self.vertical_alignment = VerticalAlignment.bottom
                self.cursor_p = (0, grid_size(self.grid)[1] - 1)
            case "y":
                self.color_stack.append(ColorPair(yellow))
            case "rw":
                self.color_stack.append(ColorPair(white, red))
            case "li":
                self.cursor_p = put_string_on_grid(self.grid, self.cursor_p, "- ", ColorPair(yellow).to_curses())
            case "color":
                self.color_stack.append(ColorPair.from_code(int(attrs["code"])))

    def handle_endtag(self, tag):
        match tag:
            case "center" | "right":
                self.horizontal_alignment = HorizontalAlignment.left
            case "bottom":
                self.vertical_alignment = VerticalAlignment.top
                self.cursor_p = (0, 0)
            case "y" | "rw" | "color":
                self.color_stack.pop()
            case "div" | "p" | "li" | "br":
                _, y = self.cursor_p
                self.cursor_p = (
                    0 if self.horizontal_alignment != HorizontalAlignment.right else grid_size(self.grid)[0] - 1,
                    y + self.vertical_alignment.value
                )

    def handle_data(self, data):
        self.cursor_p = put_string_on_grid(
            self.grid, self.cursor_p, data, self.color_stack[-1].to_curses(),
            self.horizontal_alignment == HorizontalAlignment.right,
            self.vertical_alignment == VerticalAlignment.bottom,
        )


html_renderer = CursesHtmlRenderer()
