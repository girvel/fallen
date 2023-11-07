from dataclasses import dataclass

from src.engine.output.colors import ColorPair
from src.engine.output.windows.panes.pane import Pane
from src.lib.query import Q


@dataclass
class ChatMessage:
    color_code: int
    speaker: str
    content: str


class Chat(Pane):
    template_name = "chat.html"
    name = "Сообщения"

    def get_arguments(self, subject, perception):
        return {
            "chat": [
                ChatMessage(
                    (~Q(m.parent).color or ColorPair()).to_code(),
                    m.parent.name,
                    m.content,
                )
                for m in self.io.memory.chat[::-1]
            ],
        }