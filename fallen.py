import curses
import logging
from pathlib import Path

import fire

from src import init_ecs

log = logging.getLogger(__name__)


def main(track_file: str=None):
    """
    Launch the Fallen RPG

    Args:
        track_file: file to redirect input from
    """
    logging.basicConfig(filename='.last.log', encoding='utf-8', level=logging.DEBUG)
    log.info("Started")

    logging.getLogger('numba').setLevel(logging.WARNING)

    curses.wrapper(init_ecs.init, track=track_file and Path(track_file).read_text().replace("\n", ""))


if __name__ == '__main__':
    fire.Fire(main)
