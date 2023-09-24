"""CLI and launch script for Fallen"""

import curses
import logging
from pathlib import Path
from time import time
from typing import Optional

import fire

from src import init_ecs
from src.init_logging import init_logging


def main(track_file: Optional[str] = None, debug_mode: bool = False):
    """
    Launch the Fallen RPG

    Args:
        track_file: file to redirect input from
        debug_mode: whether to enable debug console
    """
    init_logging()
    logging.info("Started")

    track = track_file and Path(track_file).read_text().replace("\n", "")
    logging.info(bool(track))
    if track:
        t = time()

    curses.wrapper(init_ecs.init,
        track=track,
        debug_mode=debug_mode
    )

    if track:
        t = time() - t
        logging.info(f"FPS: {len(track) / t:.2f}")


if __name__ == '__main__':
    fire.Fire(main)
