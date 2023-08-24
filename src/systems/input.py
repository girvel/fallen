import logging

from ecs import create_system


@create_system
def read_input(controller: 'hotkeys, controls', screen: 'screen_flag'):
    while True:
        hotkey = screen.main.getkey()
        if hotkey in controller.hotkeys:
            break
        logging.debug(f"Hotkey ignored: [{hotkey}]")

    logging.info(f"[{hotkey}]")
    controller.hotkeys[hotkey](controller.controls)
