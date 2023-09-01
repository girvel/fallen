import curses
import logging
from pathlib import Path
from typing import Optional

import fire

from src import init_ecs

log = logging.getLogger(__name__)


def main(track_file: Optional[str] = None, debug_mode: bool = False):
    """
    Launch the Fallen RPG

    Args:
        track_file: file to redirect input from
        debug_mode: whether to enable debug console
    """
    logging.basicConfig(filename='.last.log', encoding='utf-8', level=logging.DEBUG)
    log.info("Started")

    logging.getLogger('numba').setLevel(logging.WARNING)

    curses.wrapper(init_ecs.init,
        track=track_file and Path(track_file).read_text().replace("\n", ""),
        debug_mode=debug_mode
    )


if __name__ == '__main__':
    fire.Fire(main)
