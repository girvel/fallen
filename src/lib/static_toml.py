from typing import Any

import toml


def _post_process(content):
    if isinstance(content, dict):
        return {k: _post_process(v) for k, v in content.items()}

    if isinstance(content, list):
        return tuple(_post_process(v) for v in content)

    return content


def loads(source: str) -> dict[str, Any]:
    return _post_process(toml.loads(source))
