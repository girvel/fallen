from src.engine.output.windows.panes.pane import Pane


class Quests(Pane):
    template_name = "quests.html"
    name = "Задания"

    def get_arguments(self, subject, perception):
        return {
            "quests": self.io.memory.get_quests()
        }
