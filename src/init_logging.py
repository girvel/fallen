import logging
import sys
from pathlib import Path

root_directory = Path(__file__).parent.parent

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
        # return (
        #     f"[{self.short_levels[record.levelname]} {record.asctime}] {record.filename}:{record.lineno} "
        #     f"{record.message}"
        # )


class SafeFileHandler(logging.FileHandler):
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


def init_logging():
    handler = SafeFileHandler('.last.log', encoding='utf-8')
    handler.setFormatter(PrettyFormatter(
        fmt="[%(levelname)s %(asctime)s]  %(pathname)s:%(lineno)d  %(message)s",
        datefmt="%H:%M:%S",
    ))

    logging.basicConfig(handlers=[handler], encoding='utf-8', level=logging.DEBUG)

    logging.getLogger('numba').setLevel(logging.WARNING)
    logging.info("Initialized logging")
