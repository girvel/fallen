sequence = []

@sequence.append
def blink(subject: "blink_colors, blink_colors_i, is_blinking"):
    subject.is_blinking ^= True

    if not subject.is_blinking:
        subject.blink_colors_i += 1
        subject.color = subject.blink_colors[(subject.blink_colors_i) % len(subject.blink_colors)]
