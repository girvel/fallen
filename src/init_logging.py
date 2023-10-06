import logging
import os
import sys
from pathlib import Path

root_directory = Path(__file__).parent.parent

repetition_signal = object()

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
        path = Path(record.pathname)
        record.pathname = str(path.is_absolute() and path.relative_to(root_directory) or path)
        return super().format(record)


class SafeFileHandler(logging.FileHandler):
    def __init__(self, *args, **kwargs):
        self.last_message_content = None
        self.repetitions_n = 1
        super().__init__(*args, **kwargs)

    def handleError(self, record: logging.LogRecord) -> None:
        ex_type, ex, traceback = sys.exc_info()
        try:
            logging.error("Exception while logging:")
            logging.exception(ex)
        except Exception as ex2:
            try:
                message = (
                    f"Exception while handling exception while logging: {ex2}\n\n"
                    f"Exception while logging: {ex}\n{traceback}"
                )
            except:
                message = "Conversion error: Exception -> str"

            try:
                (root_directory / ".backup.log").write_text(message)
            except Exception as ex3:
                sys.stderr.write(f"3rd degree logging exception: {ex3}\n\n" + message)

    def emit(self, record):
        if self.stream is None:
            if self.mode != 'w' or not self._closed:
                self.stream = self._open()

        try:
            message = self.format(record)
            stream = self.stream
            # issue 35046: merged two stream.writes into one.

            if (content := message[16:]) == self.last_message_content:
                self.repetitions_n += 1
            else:
                if self.repetitions_n > 1:
                    stream.write(f"{message[:16]}  ~ ({self.repetitions_n}){self.terminator}")

                self.last_message_content = content
                self.repetitions_n = 1

                stream.write(message + self.terminator)

            self.flush()

        except RecursionError:  # See issue 36272
            raise
        except Exception:
            self.handleError(record)


def init_logging():
    handler = SafeFileHandler('.last.log', encoding='utf-8')
    handler.setFormatter(PrettyFormatter(
        fmt="[%(levelname)s %(asctime)s]  %(pathname)s:%(lineno)d  %(message)s",
        datefmt="%H:%M:%S",
    ))

    logging.basicConfig(handlers=[handler], encoding='utf-8', level=logging.DEBUG)

    logging.getLogger('numba').setLevel(logging.WARNING)
    logging.info("Initialized logging")
