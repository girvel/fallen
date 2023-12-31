"""HTML rendering engine.

Has some restrictions:
- Can not horizontally align complex data (only the contents of one tag)
"""

import re
from html.parser import HTMLParser

from src.engine.output.colors import ColorPair, yellow, color_by_name
from src.engine.output.grid_rendering import put_string_on_grid, HorizontalAlignment, VerticalAlignment
from src.lib.vector.vector import zero, int2


def render(html, w: int, h: int | None):
    renderer = _CursesHtmlRenderer(w, h)
    renderer.feed(re.sub(r"\n\s*", "", html))
    return renderer.array, (w, len(renderer.array))


class _CursesHtmlRenderer(HTMLParser):
    def __init__(self, w: int, h: int | None):
        super().__init__()

        self.w = w
        self.h = h  # needed only for <bottom>

        self.array: list[list[str]] = []
        self.color_stack: list[ColorPair] = [ColorPair()]
        self.horizontal_alignment: HorizontalAlignment = HorizontalAlignment.left
        self.vertical_alignment: VerticalAlignment = VerticalAlignment.top
        self.cursor_p: int2 = zero

    def handle_starttag(self, tag, attrs, **kwargs):
        attrs = dict(attrs)

        match tag:
            case "center":
                self.horizontal_alignment = HorizontalAlignment.center
            case "right":
                self.horizontal_alignment = HorizontalAlignment.right
            case "bottom":
                self.vertical_alignment = VerticalAlignment.bottom
                self.cursor_p = (0, self.h - 1)
            case "b":
                self.color_stack.append(ColorPair(yellow))
            case "li":
                self.cursor_p = put_string_on_grid(
                    self.array, self.w, self.cursor_p, "- ", ColorPair(yellow).to_curses(),
                    self.horizontal_alignment, self.vertical_alignment,
                )
            case "color":
                if "code" in attrs:
                    color = ColorPair.from_code(int(attrs["code"]))
                else:
                    color = ColorPair(
                        color_by_name[attrs.get("fg", "white")],
                        color_by_name[attrs.get("bg", "black")],
                    )

                self.color_stack.append(color)

    def handle_endtag(self, tag):
        match tag:
            case "center" | "right":
                self.horizontal_alignment = HorizontalAlignment.left
            case "bottom":
                self.vertical_alignment = VerticalAlignment.top
                self.cursor_p = (0, 0)
            case "b" | "color":
                self.color_stack.pop()
            case "div" | "li" | "br":
                _, y = self.cursor_p
                self.cursor_p = (0, y + self.vertical_alignment.value)

    def handle_data(self, data):
        self.cursor_p = put_string_on_grid(
            self.array, self.w, self.cursor_p, data, self.color_stack[-1].to_curses(),
            self.horizontal_alignment, self.vertical_alignment,
        )
