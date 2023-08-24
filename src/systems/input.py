import logging

import keyboard
from ecs import create_system


@create_system
def read_input(controller: 'hotkeys, controls'):
    while True:
        hotkey = keyboard.read_key()
        if hotkey in controller.hotkeys:
            break
        logging.debug(f"Hotkey ignored: [{hotkey}]")

    logging.info(f"[{hotkey}]")
    controller.hotkeys[hotkey](controller.controls)
