def to_camel_case(snake_str):
    return "".join(x.capitalize() for x in snake_str.lower().split("_"))