from importlib.util import spec_from_file_location, module_from_spec


def to_camel_case(snake_str):
    return "".join(x.capitalize() for x in snake_str.lower().split("_"))

def sign(n):
    if n == 0:
        return 0
    if n < 0:
        return -1
    return 1

def load_palette_from(path):
    result = {}

    for p in path.iterdir():
        if p.suffix != '.py': continue

        spec = spec_from_file_location(p.stem, p)
        module = module_from_spec(spec)
        spec.loader.exec_module(module)

        cls = getattr(module, to_camel_case(p.stem))
        result[cls.character] = cls

    return result
