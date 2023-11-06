from dataclasses import dataclass


@dataclass(frozen=True)
class Mode:
    name: str
    accepts_empty_input: bool = False

GENERAL = Mode("Общее")
GAME = Mode("Игра")
DIALOGUE_LINE = Mode("Диалог")
CUTSCENE = Mode("Сцена", True)
OPTIONS = Mode("Выбор варианта")
NOTIFICATION = Mode("Уведомление")

ALL_MODES = [GENERAL, GAME, DIALOGUE_LINE, CUTSCENE, OPTIONS, NOTIFICATION]
