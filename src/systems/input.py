import logging

from ecs import create_system


log = logging.getLogger(__name__)


@create_system
def read_input(controller: 'hotkeys, controls', screen: 'screen_flag'):
    while True:
        hotkey = screen.main.getkey()
        if hotkey in controller.hotkeys:
            break
        log.debug(f"Hotkey ignored: [{hotkey}]")

    log.info(f"[{hotkey}]")
    controller.hotkeys[hotkey]()
