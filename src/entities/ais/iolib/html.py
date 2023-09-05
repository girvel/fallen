from html.parser import HTMLParser

from src.entities.ais.iolib.colors import Colors


class CursesHtmlRenderer(HTMLParser):
    window = None
    y = None
    x = None
    padding_x = None
    color_stack = [Colors.Default]
    centering = False

    def render_template(self, window, start_y, start_x, template, **kwargs):
        self.window = window
        self.start_y = start_y
        self.y = start_y
        self.x = start_x
        self.padding_x = start_x

        self.feed(template.render(**kwargs).replace("\n", ""))

    def handle_starttag(self, tag, attrs, **kwargs):
        match tag:
            case "center":
                self.centering = True
            case "y":
                self.color_stack.append(Colors.Yellow)
            case "rw":
                self.color_stack.append(Colors.WhiteOnRed)

    def handle_endtag(self, tag):
        match tag:
            case "center":
                self.centering = False
            case "y"|"rw":
                self.color_stack.pop()
            case "div" | "p":
                self.y += 1
                self.x = self.padding_x

    def handle_data(self, data):
        _, w = self.window.getmaxyx()

        if self.centering:
            self.x += (w - self.padding_x - len(data)) // 2

        data = data.lstrip(" ")
        if len(data) == 0: return

        self.window.addstr(self.y, self.x, data, self.color_stack[-1].format())
        self.x += len(data)
