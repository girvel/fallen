import curses
import logging
from pathlib import Path
from typing import Optional

import fire

from src import init_ecs

log = logging.getLogger(__name__)

class PrettyFormatter(logging.Formatter):
    short_levels = {
        "DEBUG": "DEBUG",
        "INFO": "INFO ",
        "WARNING": "WARN ",
        "ERROR": "ERROR",
        "CRITICAL": "FATAL",
    }

    def format(self, record: logging.LogRecord) -> str:
        record.levelname = self.short_levels[record.levelname]
        record.pathname = str(Path(record.pathname).relative_to(Path(__file__).parent))
        return super().format(record)
        # return (
        #     f"[{self.short_levels[record.levelname]} {record.asctime}] {record.filename}:{record.lineno} "
        #     f"{record.message}"
        # )


def main(track_file: Optional[str] = None, debug_mode: bool = False):
    """
    Launch the Fallen RPG

    Args:
        track_file: file to redirect input from
        debug_mode: whether to enable debug console
    """
    file_handler = logging.FileHandler('.last.log')
    file_handler.setFormatter(PrettyFormatter(
        fmt="[%(levelname)s %(asctime)s]  %(pathname)s:%(lineno)d  %(message)s",
        datefmt="%H:%M:%S",
    ))

    logging.basicConfig(handlers=[file_handler], encoding='utf-8', level=logging.DEBUG)

    log.info("Started")

    logging.getLogger('numba').setLevel(logging.WARNING)

    curses.wrapper(init_ecs.init,
        track=track_file and Path(track_file).read_text().replace("\n", ""),
        debug_mode=debug_mode
    )


if __name__ == '__main__':
    fire.Fire(main)
