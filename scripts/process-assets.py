#!/usr/bin/env python3
"""Convert Imagine outputs into engine-ready PNGs with chroma-key and sizing."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "SplitPicnic" / "Resources" / "Assets.xcassets"
def save_imageset(name: str, image: Image.Image) -> None:
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


def chroma_key(path: Path, g_min: int = 90, ratio: float = 1.35) -> Image.Image:
    im = Image.open(path).convert("RGBA")
    pixels = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if g >= g_min and g > r * ratio and g > b * ratio:
                pixels[x, y] = (r, g, b, 0)
                continue
            excess = max(g - max(r, b), 0) / 255.0
            fade = max(min((excess - 0.25) * 2.2, 1.0), 0.0)
            if fade > 0:
                pixels[x, y] = (r, g, b, int(a * (1.0 - fade)))
    return im


def trim(image: Image.Image, pad: int = 16) -> Image.Image:
    alpha = image.split()[-1]
    bbox = alpha.getbbox()
    if not bbox:
        return image
    l, t, r, b = bbox
    l = max(0, l - pad)
    t = max(0, t - pad)
    r = min(image.width, r + pad)
    b = min(image.height, b + pad)
    return image.crop((l, t, r, b))


def fit_square(image: Image.Image, size: int) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    image = image.copy()
    image.thumbnail((size, size), Image.Resampling.LANCZOS)
    x = (size - image.width) // 2
    y = (size - image.height) // 2
    canvas.paste(image, (x, y), image)
    return canvas


def copy_jpg_png(src: Path, name: str, size: tuple[int, int] | None = None) -> None:
    im = Image.open(src).convert("RGB")
    if size:
        im = im.resize(size, Image.Resampling.LANCZOS)
    folder = ASSETS / f"{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    # Keep JPEG for large scenic backgrounds
    dest = folder / f"{name}.jpg"
    im.save(dest, "JPEG", quality=88, optimize=True)
    (folder / "Contents.json").write_text(
        """{
  "images" : [
    {
      "filename" : "%s.jpg",
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
    print(f"wrote {dest} {im.size}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source_dir", type=Path, help="Directory containing the original numbered JPG artwork")
    source_dir = parser.parse_args().source_dir.expanduser().resolve()
    if not source_dir.is_dir():
        parser.error(f"Source directory does not exist: {source_dir}")

    characters = {
        "DogHappy": "4.jpg",
        "CatHappy": "5.jpg",
        "DogSad": "7.jpg",
        "CatSad": "8.jpg",
    }
    for name, file in characters.items():
        keyed = trim(chroma_key(source_dir / file), pad=12)
        save_imageset(name, keyed)

    icon = Image.open(source_dir / "2.jpg").convert("RGB").resize((1024, 1024), Image.Resampling.LANCZOS)
    icon_dir = ASSETS / "AppIcon.appiconset"
    icon_dir.mkdir(parents=True, exist_ok=True)
    icon.save(icon_dir / "AppIcon.png", "PNG", optimize=True)
    print(f"wrote AppIcon 1024x1024")

    mark = Image.open(source_dir / "1.jpg").convert("RGB").resize((512, 512), Image.Resampling.LANCZOS)
    save_imageset("BrandMark", mark.convert("RGBA"))

    copy_jpg_png(source_dir / "3.jpg", "PicnicBackground", (1170, 2080))
    copy_jpg_png(source_dir / "6.jpg", "WorldsMap", (1170, 2080))
    copy_jpg_png(source_dir / "10.jpg", "BerryBackground", (1170, 2080))
    copy_jpg_png(source_dir / "9.jpg", "ForestBackground", (1170, 2080))
    copy_jpg_png(source_dir / "11.jpg", "BakeryBackground", (1170, 2080))


if __name__ == "__main__":
    main()
