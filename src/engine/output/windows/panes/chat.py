from src.engine.output.windows.panes.pane import Pane


class Chat(Pane):
    template_name = "chat.html"
    name = "Сообщения"

    def get_arguments(self, subject, perception):
        return {
            "chat": self.io.memory.chat[::-1],
        }