#!/usr/bin/env python3
"""Chroma-key food sprites into engine-ready PNGs."""

from __future__ import annotations

import argparse
from collections import deque
from pathlib import Path

from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "SplitPicnic" / "Resources" / "Assets.xcassets"
def write_imageset(name: str, image: Image.Image) -> None:
    folder = ASSETS / f"{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    dest = folder / f"{name}.png"
    image.save(dest, "PNG", optimize=True)
    (folder / "Contents.json").write_text(
        """{
  "images" : [
    {
      "filename" : "%s.png",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"""
        % name
    )
    print(f"wrote {dest} {image.size}")


def is_green_screen(r: int, g: int, b: int) -> bool:
    return g > r + 18 and g > b + 18 and g >= 28


def is_magenta_screen(r: int, g: int, b: int) -> bool:
    return r > g + 18 and b > g + 18 and r >= 40 and b >= 40


def flood_key(im: Image.Image, mode: str = "green") -> Image.Image:
    im = im.convert("RGBA")
    pix = im.load()
    w, h = im.size
    test = is_green_screen if mode == "green" else is_magenta_screen
    seen = [[False] * w for _ in range(h)]
    q: deque[tuple[int, int]] = deque()

    def push(x: int, y: int) -> None:
        if 0 <= x < w and 0 <= y < h and not seen[y][x]:
            r, g, b, a = pix[x, y]
            if a and test(r, g, b):
                seen[y][x] = True
                q.append((x, y))

    seeds = [
        (0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1),
        (w // 2, 0), (w // 2, h - 1), (0, h // 2), (w - 1, h // 2),
    ]
    for x, y in seeds:
        push(x, y)
    while q:
        x, y = q.popleft()
        pix[x, y] = (0, 0, 0, 0)
        push(x - 1, y)
        push(x + 1, y)
        push(x, y - 1)
        push(x, y + 1)

    for y in range(h):
        for x in range(w):
            r, g, b, a = pix[x, y]
            if a and test(r, g, b):
                pix[x, y] = (0, 0, 0, 0)
    return im


def trim(image: Image.Image, pad: int = 8) -> Image.Image:
    bbox = image.split()[-1].getbbox()
    if not bbox:
        return image
    l, t, r, b = bbox
    l = max(0, l - pad)
    t = max(0, t - pad)
    r = min(image.width, r + pad)
    b = min(image.height, b + pad)
    return image.crop((l, t, r, b))


def circular_crop(image: Image.Image) -> Image.Image:
    image = image.convert("RGBA")
    w, h = image.size
    s = min(w, h)
    left = (w - s) // 2
    top = (h - s) // 2
    image = image.crop((left, top, left + s, top + s))
    mask = Image.new("L", (s, s), 0)
    from PIL import ImageDraw

    ImageDraw.Draw(mask).ellipse((1, 1, s - 2, s - 2), fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(1.2))
    out = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    out.paste(image, (0, 0), image)
    alpha = out.split()[-1]
    alpha = Image.composite(alpha, Image.new("L", (s, s), 0), mask)
    out.putalpha(alpha)
    return out


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source_dir", type=Path, help="Directory containing the original numbered JPG artwork")
    source_dir = parser.parse_args().source_dir.expanduser().resolve()
    if not source_dir.is_dir():
        parser.error(f"Source directory does not exist: {source_dir}")

    foods = {
        "PizzaBase": ("13.jpg", True, "green"),
        "PieBase": ("12.jpg", True, "green"),
        "ToppingPepperoni": ("15.jpg", False, "green"),
        "ToppingOlive": ("16.jpg", False, "green"),
        "ToppingBlueberry": ("14.jpg", False, "green"),
        "ToppingStrawberry": ("17.jpg", False, "green"),
        "ToppingMushroom": ("19.jpg", False, "green"),
        "ToppingCherry": ("20.jpg", False, "green"),
        "ToppingPepper": ("22.jpg", False, "magenta"),
        "ToppingBasil": ("23.jpg", False, "magenta"),
    }
    for name, (file, circle, mode) in foods.items():
        keyed = flood_key(Image.open(source_dir / file), mode=mode)
        keyed = trim(keyed, pad=6)
        if circle:
            keyed = circular_crop(keyed)
            keyed = keyed.resize((1024, 1024), Image.Resampling.LANCZOS)
        else:
            keyed.thumbnail((512, 512), Image.Resampling.LANCZOS)
        write_imageset(name, keyed)


if __name__ == "__main__":
    main()
