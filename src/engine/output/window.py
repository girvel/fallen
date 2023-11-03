import curses


class Window:
    def __init__(self, io):
        self.curses_window = curses.newwin(1, 1, 0, 0)
        self.io = io

    def responsive_size(self, subject, perception, max_size):
        return max_size

    def update_visibility(self, subject, perception):
        self.visible = self._calculate_visibility(subject, perception)
        return self.visible

    def _calculate_visibility(self, subject, perception):
        return True
