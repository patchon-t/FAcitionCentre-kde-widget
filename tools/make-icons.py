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

# Batteries are drawn natively (contents/ui/BatteryGlyph.qml), not as square icons.
icons["plug"] = svg('<path d="M2 10h3.5"/><rect x="5.5" y="6" width="7" height="8" rx="1.8"/><path d="M12.5 8.2h4M12.5 11.8h4"/>')
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

# --- Windows 11 24H2 additions ---
icons["arrow-left"] = svg('<path d="M16 10H4.5M9.5 4.5L4 10l5.5 5.5"/>')
icons["energy-saver"] = svg('<rect x="2.5" y="6" width="13" height="8" rx="1.8"/><rect x="16.2" y="8.3" width="1.4" height="3.4" rx="0.5" fill="#000" stroke="none"/>'
                            '<path d="M6 12.2c0-2.6 2.2-4.2 5.5-4.4-.2 3.2-1.9 4.9-4.4 4.6M6 12.2l2.2-1.9"/>')
icons["accessibility"] = svg('<circle cx="10" cy="3.6" r="1.4"/><path d="M3.5 6.8c2.2.8 4.3 1.2 6.5 1.2s4.3-.4 6.5-1.2"/>'
                             '<path d="M10 8v4M10 12l-3 5.2M10 12l3 5.2"/>')
icons["hotspot"] = svg('<circle cx="10" cy="10" r="1.3" fill="#000" stroke="none"/>' + arc(10, 10, 4, -50, 50) + arc(10, 10, 4, 130, 230)
                       + arc(10, 10, 7.2, -50, 50) + arc(10, 10, 7.2, 130, 230))
icons["bell"] = svg('<path d="M5.5 13.5V9a4.5 4.5 0 0 1 9 0v4.5l1.3 1.5H4.2z"/><path d="M8.3 17a1.8 1.8 0 0 0 3.4 0"/>')
icons["bell-off"] = svg('<path d="M5.5 13.5V9c0-.9.3-1.8.7-2.5M7.9 5.1A4.5 4.5 0 0 1 14.5 9v4.5l1.3 1.5H4.2"/><path d="M8.3 17a1.8 1.8 0 0 0 3.4 0"/><path d="M3 3l14 14"/>')
icons["magnifier"] = svg('<circle cx="8.5" cy="8.5" r="5.5"/><path d="M12.6 12.6L17 17M6.2 8.5h4.6M8.5 6.2v4.6"/>')
icons["narrator"] = svg('<rect x="2.5" y="4" width="10" height="9" rx="1.5"/><path d="M5 7.5h5M5 10h3"/>' + arc(12.5, 10, 3.5, -40, 40) + arc(12.5, 10, 6, -40, 40))
icons["color-filter"] = svg('<path d="M10 2.8c3.5 3.4 5.5 6.2 5.5 8.7a5.5 5.5 0 0 1-11 0c0-2.5 2-5.3 5.5-8.7z"/><path d="M10 5.5v11.2" /><path d="M10 9.5h3.5M10 12.5h4.2"/>')
icons["sound-output"] = svg('<path d="M2.5 5h7.5M13.5 5h4M2.5 10h2M8 10h1.2"/><circle cx="11.8" cy="5" r="1.7"/><circle cx="6.2" cy="10" r="1.7"/>'
                            '<path d="M10.5 12.8h1.8l2.4-2v7.4l-2.4-2h-1.8z"/>' + arc(14.7, 14.5, 2.6, -45, 45))
icons["info"] = svg('<circle cx="10" cy="10" r="7"/><path d="M10 9v4.5"/><circle cx="10" cy="6.6" r="0.5" fill="#000"/>')
icons["refresh"] = svg(arc(10, 10, 6, 30, 330) + '<path d="M15.6 3.6v3.6H12"/>')
icons["display-pc"] = svg('<rect x="2.5" y="4" width="10" height="7.5" rx="1.2"/><path d="M7.5 11.5v2.5M5.5 14.5h4"/><rect x="13.5" y="6.5" width="4.5" height="4" rx="0.8" stroke-dasharray="1.2 1.4"/>')
icons["display-duplicate"] = svg('<rect x="2" y="5" width="7.5" height="6" rx="1"/><rect x="10.5" y="5" width="7.5" height="6" rx="1"/><path d="M4 7.5h3.5M12.5 7.5h3.5"/><path d="M5.75 11v2.5M14.25 11v2.5"/>')
icons["display-extend"] = svg('<rect x="2" y="5" width="7.5" height="6" rx="1"/><rect x="10.5" y="5" width="7.5" height="6" rx="1"/><path d="M5 8h10M13 6.5l2 1.5-2 1.5"/><path d="M5.75 11v2.5M14.25 11v2.5"/>')
icons["display-second"] = svg('<rect x="2" y="6.5" width="4.5" height="4" rx="0.8" stroke-dasharray="1.2 1.4"/><rect x="7.5" y="4" width="10" height="7.5" rx="1.2"/><path d="M12.5 11.5v2.5M10.5 14.5h4"/>')

os.makedirs(OUT, exist_ok=True)
for name, data in icons.items():
    with open(os.path.join(OUT, name + ".svg"), "w") as f:
        f.write(data)
print(len(icons), "icons written")
