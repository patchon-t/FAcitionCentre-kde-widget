#!/usr/bin/env python3
"""Generates the Fluent-style line icons in contents/icons/ (20x20, black; recoloured at runtime)."""
import math, os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "contents", "icons")
SW = 1.5  # stroke width at 20 px

def svg(body):
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20">'
            f'<g fill="none" stroke="#000" stroke-width="{SW}" stroke-linecap="round" stroke-linejoin="round">'
            + body + '</g></svg>\n')

def arc(cx, cy, r, a0, a1, extra=""):
    """Arc from angle a0 to a1 (degrees, 0 = right, counter-clockwise, y up)."""
    p = lambda a: (cx + r * math.cos(math.radians(a)), cy - r * math.sin(math.radians(a)))
    x0, y0 = p(a0); x1, y1 = p(a1)
    large = 1 if (a1 - a0) % 360 > 180 else 0
    return f'<path d="M{x0:.2f} {y0:.2f}A{r} {r} 0 {large} 0 {x1:.2f} {y1:.2f}" {extra}/>'

DIM = 'stroke-opacity="0.3"'
icons = {}

# Wi-Fi: dot + three arcs; level n lights the first n-1 arcs.
def wifi(level, slash=False):
    b = '<circle cx="10" cy="15.6" r="1.15" fill="#000" stroke="none"/>'
    for i, r in enumerate((4.4, 8.0, 11.6)):
        b += arc(10, 15.6, r, 42, 138, "" if (i < level - 1 or slash) else DIM)
    if slash:
        b += '<path d="M3.2 3.2l13.6 13.6"/>'
    return svg(b)
for n in range(1, 5):
    icons[f"wifi-{n}"] = wifi(n)
icons["wifi-off"] = wifi(4, slash=True)

icons["globe-off"] = svg('<circle cx="10" cy="10" r="7"/><ellipse cx="10" cy="10" rx="3" ry="7"/>'
                         '<path d="M3 10h14"/><path d="M2.8 2.8l14.4 14.4"/>')
icons["ethernet"] = svg('<rect x="2.5" y="3.5" width="15" height="10" rx="1.5"/><path d="M10 13.5v3M6.5 16.5h7"/>')
icons["airplane"] = svg('<path transform="rotate(90 10 10)" d="M10 2.2c.8 0 1.35.95 1.35 2.1v3.6l5.65 3.25v1.65l-5.65-1.75v3.35l1.85 1.4v1.45L10 16.4l-3.2.85v-1.45l1.85-1.4V11.05L3 12.8v-1.65l5.65-3.25V4.3c0-1.15.55-2.1 1.35-2.1z"/>')
icons["bluetooth"] = svg('<path d="M5.8 6.6l8.2 6.8-4 3.4V3.2l4 3.4-8.2 6.8"/>')
icons["moon"] = svg('<path d="M16 12.4A6.7 6.7 0 0 1 7.6 4a6.7 6.7 0 1 0 8.4 8.4z"/>')
icons["night-light"] = svg('<path d="M14.6 13.6A5.6 5.6 0 0 1 7.4 6.4a5.6 5.6 0 1 0 7.2 7.2z"/>'
                           '<path d="M14.5 2.8v3.4M12.8 4.5h3.4"/><path d="M17.3 8.3v1.6M16.5 9.1h1.6"/>')
icons["project"] = svg('<path d="M8.5 11.5H3.7a1.2 1.2 0 0 1-1.2-1.2V4.7a1.2 1.2 0 0 1 1.2-1.2h8.6a1.2 1.2 0 0 1 1.2 1.2v3.8"/>'
                       '<rect x="8.5" y="8.5" width="9" height="7" rx="1.2"/>')
icons["sun"] = svg('<circle cx="10" cy="10" r="3.2"/>' + "".join(
    f'<path d="M{10+5.4*math.cos(a):.2f} {10+5.4*math.sin(a):.2f}L{10+7.3*math.cos(a):.2f} {10+7.3*math.sin(a):.2f}"/>'
    for a in [i * math.pi / 4 for i in range(8)]))

SPEAKER = '<path d="M3 7.6h2.7L9.6 4.4v11.2L5.7 12.4H3z"/>'
for n in range(0, 4):
    b = SPEAKER
    for i, r in enumerate((3.0, 5.5, 8.0)[:n]):
        b += arc(9.6, 10, r, -42, 42)
    icons[f"speaker-{n}"] = svg(b)
icons["speaker-mute"] = svg(SPEAKER + '<path d="M13 8l4 4M17 8l-4 4"/>')

icons["chevron-right"] = svg('<path d="M7.5 4.5l5.5 5.5-5.5 5.5"/>')
icons["chevron-left"] = svg('<path d="M12.5 4.5L7 10l5.5 5.5"/>')
icons["pencil"] = svg('<path d="M13.2 3.6l3.2 3.2L7.2 16H4v-3.2z"/><path d="M11.4 5.4l3.2 3.2"/>')

def gear():
    pts = []
    teeth = 8
    for i in range(teeth * 4):
        a = i * 2 * math.pi / (teeth * 4) + math.pi / (teeth * 4)
        r = 7.6 if (i % 4) in (0, 1) else 5.7
        pts.append((10 + r * math.cos(a), 10 + r * math.sin(a)))
    d = "M" + "L".join(f"{x:.2f} {y:.2f}" for x, y in pts) + "z"
    return svg(f'<path d="{d}"/><circle cx="10" cy="10" r="2.4"/>')
icons["gear"] = gear()

# Batteries: 0..10 tenths, plus charging variant (plug on the left, like Windows).
def battery(t, charging):
    x0 = 6.2 if charging else 2.2
    w = 17.2 - x0 - 1.6
    b = f'<rect x="{x0}" y="6" width="{w:.2f}" height="8" rx="1.8"/>'
    b += f'<rect x="{x0 + w + 0.6:.2f}" y="8.3" width="1.4" height="3.4" rx="0.5" fill="#000" stroke="none"/>'
    fw = (w - 3.0) * t / 10
    if fw > 0.05:
        b += f'<rect x="{x0 + 1.5:.2f}" y="7.5" width="{fw:.2f}" height="5" rx="0.7" fill="#000" stroke="none"/>'
    if charging:
        b += '<path d="M2.6 8.4h2.2v3.2H2.6zM0.9 9.2h1.7M0.9 10.8h1.7"/>'
    return svg(b)
for t in range(11):
    icons[f"battery-{t}"] = battery(t, False)
    icons[f"battery-{t}-charging"] = battery(t, True)

icons["lock"] = svg('<rect x="4.5" y="8.5" width="11" height="8" rx="1.5"/><path d="M7 8.5V6.5a3 3 0 0 1 6 0v2"/>')
icons["check"] = svg('<path d="M4.5 10.5l3.6 3.6L15.6 6"/>')
icons["plus"] = svg('<path d="M10 4v12M4 10h12"/>')
icons["unpin"] = svg('<path d="M7.8 3.5h4.4l-.6 4 2.6 3H5.8l2.6-3z"/><path d="M10 10.5v6"/><path d="M3.5 3.5l13 13"/>')
icons["eye"] = svg('<path d="M2 10s3-5.5 8-5.5S18 10 18 10s-3 5.5-8 5.5S2 10 2 10z"/><circle cx="10" cy="10" r="2.5"/>')
icons["spinner"] = svg(arc(10, 10, 7, 90, 360))
icons["previous"] = svg('<path d="M5 4.5v11"/><path d="M15.5 4.8L8 10l7.5 5.2z" fill="#000"/>')
icons["next"] = svg('<path d="M15 4.5v11"/><path d="M4.5 4.8L12 10l-7.5 5.2z" fill="#000"/>')
icons["play"] = svg('<path d="M6.5 4l9 6-9 6z" fill="#000"/>')
icons["pause"] = svg('<rect x="5" y="4" width="3.2" height="12" rx="1" fill="#000"/><rect x="11.8" y="4" width="3.2" height="12" rx="1" fill="#000"/>')
icons["headphones"] = svg('<path d="M3.5 13.5V11a6.5 6.5 0 0 1 13 0v2.5"/><rect x="3.5" y="11.5" width="3" height="5" rx="1"/><rect x="13.5" y="11.5" width="3" height="5" rx="1"/>')
icons["mouse"] = svg('<rect x="5.5" y="2.5" width="9" height="15" rx="4.5"/><path d="M10 2.5v5"/>')
icons["keyboard"] = svg('<rect x="2" y="5" width="16" height="10" rx="1.5"/><path d="M5 8h.01M8 8h.01M11 8h.01M14 8h.01M5 11h.01M14 11h.01M7.5 12h5"/>')
icons["phone"] = svg('<rect x="5.5" y="2" width="9" height="16" rx="1.8"/><path d="M8.8 15h2.4"/>')
icons["speaker-device"] = svg('<rect x="4.5" y="2.5" width="11" height="15" rx="1.8"/><circle cx="10" cy="12" r="2.6"/><circle cx="10" cy="6.2" r="0.6" fill="#000"/>')
icons["device"] = svg('<rect x="2.5" y="4" width="15" height="12" rx="2"/><path d="M8 7.5l4 3-2 1.6V7l2 1.6-4 3"/>')

os.makedirs(OUT, exist_ok=True)
for name, data in icons.items():
    with open(os.path.join(OUT, name + ".svg"), "w") as f:
        f.write(data)
print(len(icons), "icons written")
