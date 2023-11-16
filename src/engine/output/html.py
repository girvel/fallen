import re
from html.parser import HTMLParser

from src.engine.output.colors import ColorPair, yellow, white, red
from src.engine.output.grid_rendering import put_string_on_grid
from src.lib.toolkit import add_multiline_string
from src.lib.vector import create_grid


# class HorizontalAlignment(Enum):
#     left = 0
#     center = 1
#     right = 2
#
#
# class VerticalAlignment(Enum):
#     top = 0
#     center = 1
#     bottom = 2


class CursesHtmlRenderer(HTMLParser):
    size = None
    y = None
    x = None
    # color_stack = [ColorPair()]
    # horizontal_alignment = HorizontalAlignment.left
    # vertical_alignment = VerticalAlignment.top

    def render(self, size, html, **kwargs):
        self.grid = create_grid(size, lambda: " ")
        self.cursor_p = (0, 0)
        self.feed(re.sub(r"\n\s*", "", html))
        return self.grid

    # def handle_starttag(self, tag, attrs, **kwargs):
    #     attrs = dict(attrs)
    #
    #     match tag:
    #         case "center":
    #             self.horizontal_alignment = HorizontalAlignment.center
    #         case "right":
    #             self.horizontal_alignment = HorizontalAlignment.right
    #         case "bottom":
    #             self.vertical_alignment = VerticalAlignment.bottom
    #             self.y = self.window.getmaxyx()[0] - 1
    #         case "y":
    #             self.color_stack.append(ColorPair(yellow))
    #         case "rw":
    #             self.color_stack.append(ColorPair(white, red))
    #         case "li":
    #             h, w = self.window.getmaxyx()
    #             self.y, self.x = add_multiline_string(
    #                 self.window,
    #                 self.y, self.x,
    #                 0, 0,
    #                 h, w,
    #                 "- ", ColorPair(yellow),
    #             )
    #         case "color":
    #             self.color_stack.append(ColorPair.from_code(int(attrs["code"])))
    #
    # def handle_endtag(self, tag):
    #     match tag:
    #         case "center" | "right":
    #             self.horizontal_alignment = HorizontalAlignment.left
    #         case "bottom":
    #             self.vertical_alignment = VerticalAlignment.top
    #             self.y = 0
    #         case "y" | "rw" | "color":
    #             self.color_stack.pop()
    #         case "div" | "p" | "li" | "br":
    #             self.y += 1
    #             self.x = 0

    def handle_data(self, data):
        self.cursor_p = put_string_on_grid(self.grid, self.cursor_p, data, ColorPair(white).to_curses())

        # h, w = self.window.getmaxyx()
        #
        # match self.horizontal_alignment:
        #     case HorizontalAlignment.center:
        #         self.x = (w - len(data)) // 2  # TODO multiline
        #     case HorizontalAlignment.right:
        #         self.x = w - len(data) - 1
        #
        # data = data.lstrip(" ")
        # if len(data) == 0: return
        #
        # self.y, self.x = add_multiline_string(
        #     self.window,
        #     self.y, self.x,
        #     0, 0,
        #     h, w,
        #     data, self.color_stack[-1],
        # )


html_renderer = CursesHtmlRenderer()
