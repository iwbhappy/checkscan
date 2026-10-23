"""Rasterize the CheckScan vector geometry into Apple's required icon sizes.

Development-only helper (Python + Pillow). Artwork coordinates match
assets/icon.svg and android/app/src/main/res/drawable/ic_checkscan.xml.
Icons are opaque RGB; iOS applies its own rounded icon mask.
"""

import json
from pathlib import Path

from PIL import Image, ImageDraw


def main():
    asset_dir = Path(__file__).resolve().parents[1] / "Runner/Assets.xcassets/AppIcon.appiconset"
    scale = 3
    canvas = Image.new("RGB", (1024 * scale, 1024 * scale), "#00796b")
    draw = ImageDraw.Draw(canvas)

    def points(values):
        return [(int(x * scale), int(y * scale)) for x, y in values]

    draw.polygon(points([(300, 180), (724, 180), (724, 820), (653, 773),
                         (582, 820), (512, 773), (441, 820), (370, 773),
                         (300, 820)]), fill="#ffffff")

    def rounded_line(values, width):
        path = points(values)
        draw.line(path, fill="#00796b", width=width * scale, joint="curve")
        radius = width * scale / 2
        for x, y in path:
            draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill="#00796b")

    rounded_line([(385, 305), (639, 305)], 42)
    rounded_line([(385, 393), (552, 393)], 42)
    rounded_line([(395, 585), (476, 666), (644, 496)], 55)

    manifest = json.loads((asset_dir / "Contents.json").read_text(encoding="utf-8"))
    written = set()
    for entry in manifest["images"]:
        name = entry["filename"]
        if name in written:
            continue
        size = round(float(entry["size"].split("x")[0]) * float(entry["scale"].rstrip("x")))
        canvas.resize((size, size), Image.Resampling.LANCZOS).save(asset_dir / name)
        written.add(name)
    print(f"Rendered {len(written)} opaque CheckScan icons")


if __name__ == "__main__":
    main()
