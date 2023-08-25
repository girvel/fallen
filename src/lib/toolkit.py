def to_camel_case(snake_str):
    return "".join(x.capitalize() for x in snake_str.lower().split("_"))

def sign(n):
    if n == 0:
        return 0
    if n < 0:
        return -1
    return 1
