#!/usr/bin/env python3
"""Render App Store and Google Play promotional screenshots with Playwright."""

from __future__ import annotations

import argparse
import html
import re
import struct
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parents[1]
DEFAULT_SOURCE_DIR = REPO_ROOT / "doc"
DEFAULT_OUTPUT_DIR = REPO_ROOT / "store_screenshots" / "promotional"
DEFAULT_TMP_DIR = SCRIPT_DIR / "tmp"
TEMPLATE_PATH = SCRIPT_DIR / "promo_template.html"

SUPPORTED_IMAGE_SUFFIXES = {".png", ".jpg", ".jpeg", ".webp"}
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


@dataclass(frozen=True)
class ScreenshotScene:
    key: str
    description: str
    candidates: tuple[str, ...]
    alt: str


@dataclass(frozen=True)
class PromoTarget:
    name: str
    locale_code: str
    width: int
    height: int
    scene_key: str
    heading: str
    subheading: str
    kicker: str
    pill_one: str
    pill_two: str
    device_class: str
    layout_class: str
    device_width_ratio: float
    max_device_height_ratio: float
    device_top_ratio: float
    device_x_offset_ratio: float
    copy_top_ratio: float
    copy_left_ratio: float
    copy_width_ratio: float
    headline_ratio: float
    body_ratio: float
    variant: str
    transform: str
    plate_transform: str
    object_position: str = "center center"
    camera_opacity: float = 0.0


@dataclass(frozen=True)
class FormatPreset:
    name_prefix: str
    width: int
    height: int
    family: str


@dataclass(frozen=True)
class PromoSpec:
    slug: str
    scene_key: str
    heading: str
    subheading: str
    kicker: str
    pill_one: str
    pill_two: str
    device_kind: str
    variant: str
    transform: str
    plate_transform: str
    object_position: str = "center center"
    camera_opacity: float = 0.0


@dataclass(frozen=True)
class PromoCopy:
    heading: str
    subheading: str
    kicker: str
    pill_one: str
    pill_two: str


@dataclass(frozen=True)
class LocaleSpec:
    code: str
    label: str


SCENES: dict[str, ScreenshotScene] = {
    "tablet_start_map": ScreenshotScene(
        key="tablet_start_map",
        description="Landscape light map with the Start Exploring prompt and QR entry point.",
        candidates=("IMG_0300.PNG", "IMG_0300.png"),
        alt="Dni SGGW map screen with a start exploring prompt",
    ),
    "tablet_point_collected": ScreenshotScene(
        key="tablet_point_collected",
        description="Landscape light map with the collected point confirmation dialog.",
        candidates=("IMG_0302.PNG", "IMG_0302.png"),
        alt="Dni SGGW point collected confirmation dialog",
    ),
    "phone_treasure_map": ScreenshotScene(
        key="phone_treasure_map",
        description="Portrait dark-mode Polish treasure map with progress and QR controls.",
        candidates=("IMG_2987.png",),
        alt="Dni SGGW treasure map with progress controls",
    ),
    "phone_point_list": ScreenshotScene(
        key="phone_point_list",
        description="Portrait dark-mode point list bottom sheet; HEIC source needs PNG conversion before browser export.",
        candidates=("IMG_2988.png", "IMG_2988.HEIC"),
        alt="Dni SGGW treasure point list bottom sheet",
    ),
}


FORMAT_PRESETS: tuple[FormatPreset, ...] = (
    FormatPreset(name_prefix="app_store/iphone_6_7", width=1290, height=2796, family="iphone"),
    FormatPreset(name_prefix="app_store/iphone_6_5", width=1242, height=2688, family="iphone"),
    FormatPreset(name_prefix="app_store/iphone_5_5", width=1242, height=2208, family="iphone"),
    FormatPreset(name_prefix="app_store/ipad_12_9", width=2048, height=2732, family="ipad"),
    FormatPreset(name_prefix="google_play/standard", width=1080, height=1920, family="play"),
)


LOCALES: tuple[LocaleSpec, ...] = (
    LocaleSpec(code="en", label="English"),
    LocaleSpec(code="pl", label="Polski"),
)


PROMO_SPECS: tuple[PromoSpec, ...] = (
    PromoSpec(
        slug="campus_clues",
        scene_key="phone_treasure_map",
        heading="Find every campus clue",
        subheading="Open the treasure map, track progress, and move straight to the next point during Dni SGGW.",
        kicker="Dni SGGW",
        pill_one="Live map",
        pill_two="QR hunt",
        device_kind="phone",
        variant="deep",
        transform="rotate(-5deg)",
        plate_transform="rotate(-5deg)",
    ),
    PromoSpec(
        slug="scan_rewards",
        scene_key="tablet_point_collected",
        heading="Every scan feels rewarding",
        subheading="Checkpoint confirmations make the campus game clear, satisfying, and easy to continue.",
        kicker="Treasure Hunt",
        pill_one="Instant feedback",
        pill_two="Progress saved",
        device_kind="tablet",
        variant="mint",
        transform="rotate(3deg)",
        plate_transform="rotate(3deg)",
    ),
    PromoSpec(
        slug="quick_start",
        scene_key="tablet_start_map",
        heading="Start exploring in seconds",
        subheading="A clear first step invites visitors to scan nearby QR codes and unlock the rest of the app.",
        kicker="Campus Guide",
        pill_one="Map first",
        pill_two="Quick start",
        device_kind="tablet",
        variant="light",
        transform="rotate(-2deg)",
        plate_transform="rotate(-2deg)",
    ),
    PromoSpec(
        slug="hunt_progress",
        scene_key="phone_treasure_map",
        heading="Keep the hunt moving",
        subheading="Progress stays visible, so visitors always know what they have found and where to go next.",
        kicker="Progress",
        pill_one="Collected points",
        pill_two="Next stop",
        device_kind="phone",
        variant="mint",
        transform="rotate(4deg)",
        plate_transform="rotate(4deg)",
    ),
    PromoSpec(
        slug="campus_overview",
        scene_key="tablet_start_map",
        heading="See the route before you go",
        subheading="A readable campus view helps visitors orient themselves before the next scan or event stop.",
        kicker="Campus Map",
        pill_one="Landmarks",
        pill_two="Clear route",
        device_kind="tablet",
        variant="deep",
        transform="rotate(1deg)",
        plate_transform="rotate(1deg)",
        camera_opacity=0.45,
    ),
)


PROMO_TRANSLATIONS: dict[str, dict[str, PromoCopy]] = {
    "pl": {
        "campus_clues": PromoCopy(
            heading="Odkryj wszystkie wskazówki na kampusie",
            subheading="Otwórz mapę gry, śledź postępy i bez problemu przechodź do kolejnych punktów podczas Dni SGGW.",
            kicker="Dni SGGW",
            pill_one="Mapa na żywo",
            pill_two="Gra QR",
        ),
        "scan_rewards": PromoCopy(
            heading="Każde skanowanie daje satysfakcję",
            subheading="Potwierdzenia zdobytych punktów sprawiają, że gra terenowa jest czytelna, satysfakcjonująca i łatwa do kontynuowania.",
            kicker="Gra terenowa",
            pill_one="Natychmiastowy efekt",
            pill_two="Zapis postępu",
        ),
        "quick_start": PromoCopy(
            heading="Zacznij odkrywać w kilka sekund",
            subheading="Jasny pierwszy krok zachęca odwiedzających do skanowania pobliskich kodów QR i odblokowania kolejnych funkcji aplikacji.",
            kicker="Przewodnik po kampusie",
            pill_one="Najpierw mapa",
            pill_two="Szybki start",
        ),
        "hunt_progress": PromoCopy(
            heading="Utrzymaj tempo gry",
            subheading="Postępy są zawsze widoczne, więc odwiedzający wiedzą, co już znaleźli i dokąd iść dalej.",
            kicker="Postęp",
            pill_one="Zdobyte punkty",
            pill_two="Następny punkt",
        ),
        "campus_overview": PromoCopy(
            heading="Zobacz trasę, zanim ruszysz",
            subheading="Czytelny widok kampusu pomaga odwiedzającym zorientować się przed kolejnym skanem lub następnym punktem wydarzenia.",
            kicker="Mapa kampusu",
            pill_one="Punkty orientacyjne",
            pill_two="Czytelna trasa",
        ),
    }
}


def localized_copy(promo: PromoSpec, locale_code: str) -> PromoCopy:
    if locale_code == "en":
        return PromoCopy(
            heading=promo.heading,
            subheading=promo.subheading,
            kicker=promo.kicker,
            pill_one=promo.pill_one,
            pill_two=promo.pill_two,
        )

    locale_translations = PROMO_TRANSLATIONS.get(locale_code, {})
    if promo.slug not in locale_translations:
        raise KeyError(f"Missing translation for locale '{locale_code}' and promo '{promo.slug}'")
    return locale_translations[promo.slug]


def layout_values(format_preset: FormatPreset, promo: PromoSpec) -> dict[str, float | str]:
    is_tablet_device = promo.device_kind == "tablet"

    if format_preset.family == "ipad":
        if is_tablet_device:
            return {
                "device_class": "tablet",
                "layout_class": "tablet-focus",
                "device_width_ratio": 0.88,
                "max_device_height_ratio": 0.47,
                "device_top_ratio": 0.43,
                "device_x_offset_ratio": 0.00,
                "copy_top_ratio": 0.080,
                "copy_left_ratio": 0.075,
                "copy_width_ratio": 0.70,
                "headline_ratio": 0.066,
                "body_ratio": 0.024,
            }
        return {
            "device_class": "iphone",
            "layout_class": "portrait-focus",
            "device_width_ratio": 0.42,
            "max_device_height_ratio": 0.58,
            "device_top_ratio": 0.34,
            "device_x_offset_ratio": 0.23,
            "copy_top_ratio": 0.080,
            "copy_left_ratio": 0.075,
            "copy_width_ratio": 0.66,
            "headline_ratio": 0.066,
            "body_ratio": 0.024,
        }

    if is_tablet_device:
        return {
            "device_class": "tablet",
            "layout_class": "dialog-focus" if promo.scene_key == "tablet_point_collected" else "compact-focus",
            "device_width_ratio": 0.95,
            "max_device_height_ratio": 0.38,
            "device_top_ratio": 0.50,
            "device_x_offset_ratio": 0.00,
            "copy_top_ratio": 0.080,
            "copy_left_ratio": 0.075,
            "copy_width_ratio": 0.79,
            "headline_ratio": 0.078,
            "body_ratio": 0.030,
        }

    return {
        "device_class": "android" if format_preset.family == "play" else "iphone",
        "layout_class": "google-focus" if format_preset.family == "play" else "portrait-focus",
        "device_width_ratio": 0.56 if format_preset.family == "play" else 0.66,
        "max_device_height_ratio": 0.60 if format_preset.family == "play" else 0.66,
        "device_top_ratio": 0.36 if format_preset.family == "play" else 0.31,
        "device_x_offset_ratio": 0.15 if format_preset.family == "play" else 0.13,
        "copy_top_ratio": 0.070 if format_preset.family == "play" else 0.075,
        "copy_left_ratio": 0.075,
        "copy_width_ratio": 0.76 if format_preset.family == "play" else 0.74,
        "headline_ratio": 0.080 if format_preset.family == "play" else 0.086,
        "body_ratio": 0.031 if format_preset.family == "play" else 0.030,
    }


def make_target(format_preset: FormatPreset, promo: PromoSpec, index: int, locale_code: str) -> PromoTarget:
    layout = layout_values(format_preset, promo)
    copy = localized_copy(promo, locale_code)
    return PromoTarget(
        name=f"{locale_code}/{format_preset.name_prefix}/{index:02d}_{promo.slug}",
        locale_code=locale_code,
        width=format_preset.width,
        height=format_preset.height,
        scene_key=promo.scene_key,
        heading=copy.heading,
        subheading=copy.subheading,
        kicker=copy.kicker,
        pill_one=copy.pill_one,
        pill_two=copy.pill_two,
        device_class=str(layout["device_class"]),
        layout_class=str(layout["layout_class"]),
        device_width_ratio=float(layout["device_width_ratio"]),
        max_device_height_ratio=float(layout["max_device_height_ratio"]),
        device_top_ratio=float(layout["device_top_ratio"]),
        device_x_offset_ratio=float(layout["device_x_offset_ratio"]),
        copy_top_ratio=float(layout["copy_top_ratio"]),
        copy_left_ratio=float(layout["copy_left_ratio"]),
        copy_width_ratio=float(layout["copy_width_ratio"]),
        headline_ratio=float(layout["headline_ratio"]),
        body_ratio=float(layout["body_ratio"]),
        variant=promo.variant,
        transform=promo.transform,
        plate_transform=promo.plate_transform,
        object_position=promo.object_position,
        camera_opacity=promo.camera_opacity,
    )


TARGETS: tuple[PromoTarget, ...] = tuple(
    make_target(format_preset, promo, index, locale.code)
    for locale in LOCALES
    for format_preset in FORMAT_PRESETS
    for index, promo in enumerate(PROMO_SPECS, start=1)
)


THEME_VARIANTS = {
    "deep": {
        "BACKGROUND_FROM": "#0b1710",
        "BACKGROUND_MID": "#173c2d",
        "BACKGROUND_TO": "#c8f0b4",
        "ACCENT": "#c8f0b4",
        "BADGE_TEXT": "#eaf5df",
        "HEADLINE_COLOR": "#f7f9ee",
        "BODY_COLOR": "rgba(247, 249, 238, 0.86)",
        "PILL_TEXT": "#f7f9ee",
    },
    "mint": {
        "BACKGROUND_FROM": "#f7f9ee",
        "BACKGROUND_MID": "#c8f0b4",
        "BACKGROUND_TO": "#173c2d",
        "ACCENT": "#315f24",
        "BADGE_TEXT": "#173c2d",
        "HEADLINE_COLOR": "#0f1a12",
        "BODY_COLOR": "rgba(15, 26, 18, 0.78)",
        "PILL_TEXT": "#0f1a12",
    },
    "light": {
        "BACKGROUND_FROM": "#eff6e8",
        "BACKGROUND_MID": "#c8f0b4",
        "BACKGROUND_TO": "#2f80ed",
        "ACCENT": "#315f24",
        "BADGE_TEXT": "#173c2d",
        "HEADLINE_COLOR": "#0f1a12",
        "BODY_COLOR": "rgba(15, 26, 18, 0.78)",
        "PILL_TEXT": "#0f1a12",
    },
}


def clamp(value: float, lower: int, upper: int) -> int:
    return max(lower, min(upper, round(value)))


def png_dimensions(path: Path) -> tuple[int, int]:
    with path.open("rb") as image_file:
        header = image_file.read(24)
    if not header.startswith(PNG_SIGNATURE):
        raise ValueError(f"{path} is not a PNG file")
    return struct.unpack(">II", header[16:24])


def image_dimensions(path: Path) -> tuple[int, int] | None:
    if path.suffix.lower() == ".png":
        return png_dimensions(path)
    return None


def discover_source_groups(source_dir: Path) -> dict[str, list[Path]]:
    groups: dict[str, list[Path]] = {}
    for image_path in sorted(source_dir.glob("IMG_*")):
        groups.setdefault(image_path.stem.lower(), []).append(image_path)
    return groups


def choose_scene_asset(scene: ScreenshotScene, source_dir: Path) -> Path:
    existing_candidates = [source_dir / candidate for candidate in scene.candidates if (source_dir / candidate).exists()]
    for candidate_path in existing_candidates:
        if candidate_path.suffix.lower() in SUPPORTED_IMAGE_SUFFIXES:
            return candidate_path
    if existing_candidates:
        unsupported_names = ", ".join(path.name for path in existing_candidates)
        raise RuntimeError(
            f"Scene '{scene.key}' only has browser-unsupported source files: {unsupported_names}. "
            "Convert the selected HEIC file to PNG and rerun the exporter."
        )
    raise FileNotFoundError(f"None of the candidates for scene '{scene.key}' exist in {source_dir}")


def selected_scene_assets(targets: Iterable[PromoTarget], source_dir: Path) -> dict[str, Path]:
    selected: dict[str, Path] = {}
    for target in targets:
        if target.scene_key not in selected:
            selected[target.scene_key] = choose_scene_asset(SCENES[target.scene_key], source_dir)
    return selected


def print_inventory(source_dir: Path) -> None:
    print("Raw screenshot groups:")
    for group_key, paths in discover_source_groups(source_dir).items():
        labels = []
        for image_path in paths:
            dimensions = image_dimensions(image_path)
            dimension_label = f"{dimensions[0]}x{dimensions[1]}" if dimensions else "unsupported browser source"
            labels.append(f"{image_path.name} ({dimension_label})")
        print(f"- {group_key}: {', '.join(labels)}")

    print("\nSemantic scenes:")
    for scene in SCENES.values():
        try:
            selected_path = choose_scene_asset(scene, source_dir)
            dimensions = image_dimensions(selected_path)
            dimension_label = f"{dimensions[0]}x{dimensions[1]}" if dimensions else "unknown"
            print(f"- {scene.key}: {selected_path.name} ({dimension_label}) - {scene.description}")
        except Exception as exc:
            print(f"- {scene.key}: unavailable - {exc}")


def html_escape(value: object) -> str:
    return html.escape(str(value), quote=True)


def compute_render_values(target: PromoTarget, screenshot_path: Path) -> dict[str, object]:
    screenshot_dimensions = image_dimensions(screenshot_path)
    if not screenshot_dimensions:
        raise ValueError(f"Cannot read dimensions for {screenshot_path}")

    screenshot_width, screenshot_height = screenshot_dimensions
    screenshot_aspect = screenshot_width / screenshot_height
    shorter_canvas_side = min(target.width, target.height)

    device_width = round(target.width * target.device_width_ratio)
    device_height = round(device_width / screenshot_aspect)
    max_device_height = round(target.height * target.max_device_height_ratio)
    if device_height > max_device_height:
        device_height = max_device_height
        device_width = round(device_height * screenshot_aspect)

    device_left = round((target.width - device_width) / 2 + target.width * target.device_x_offset_ratio)
    device_top = round(target.height * target.device_top_ratio)
    device_left = max(0, min(target.width - device_width, device_left))
    device_top = max(0, min(target.height - device_height, device_top))

    device_short_side = min(device_width, device_height)
    if "tablet" in target.device_class:
        radius_ratio = 0.058
        bezel_ratio = 0.018
    elif "android" in target.device_class:
        radius_ratio = 0.092
        bezel_ratio = 0.024
    else:
        radius_ratio = 0.12
        bezel_ratio = 0.024

    bezel = clamp(device_short_side * bezel_ratio, 10, 34)
    device_radius = clamp(device_short_side * radius_ratio, 34, 132)
    screen_radius = max(18, device_radius - round(bezel * 0.72))

    plate_left = round(device_left + device_width * 0.04)
    plate_top = round(device_top + device_height * 0.07)
    route_width = round(target.width * 0.74)
    route_height = round(target.height * 0.34)

    values: dict[str, object] = {
        "TITLE": f"Promo screenshot - {target.locale_code} - {target.name}",
        "HTML_LANG": target.locale_code,
        "CANVAS_WIDTH": target.width,
        "CANVAS_HEIGHT": target.height,
        "LAYOUT_CLASS": target.layout_class,
        "KICKER": target.kicker,
        "HEADING": target.heading,
        "SUBHEADING": target.subheading,
        "PILL_ONE": target.pill_one,
        "PILL_TWO": target.pill_two,
        "SCREENSHOT_SRC": screenshot_path.resolve().as_uri(),
        "SCREENSHOT_ALT": SCENES[target.scene_key].alt,
        "DEVICE_CLASS": target.device_class,
        "DEVICE_WIDTH": device_width,
        "DEVICE_HEIGHT": device_height,
        "DEVICE_LEFT": device_left,
        "DEVICE_TOP": device_top,
        "DEVICE_TRANSFORM": target.transform,
        "OBJECT_POSITION": target.object_position,
        "BEZEL": bezel,
        "DEVICE_RADIUS": device_radius,
        "SCREEN_RADIUS": screen_radius,
        "SHADOW_Y": clamp(device_short_side * 0.08, 34, 92),
        "SHADOW_BLUR": clamp(device_short_side * 0.16, 72, 180),
        "FRAME_RING": max(1, round(device_short_side * 0.004)),
        "FRAME_OUTLINE": max(1, round(device_short_side * 0.006)),
        "CAMERA_TOP": max(8, round(bezel * 0.62)),
        "CAMERA_WIDTH": clamp(device_width * 0.20, 42, 170),
        "CAMERA_HEIGHT": clamp(device_short_side * 0.018, 8, 24),
        "TABLET_CAMERA_SIZE": clamp(device_short_side * 0.018, 10, 24),
        "CAMERA_OPACITY": target.camera_opacity,
        "SIDE_BUTTON_OFFSET": max(4, round(bezel * 0.34)),
        "SIDE_BUTTON_WIDTH": max(4, round(bezel * 0.26)),
        "SIDE_BUTTON_HEIGHT": clamp(device_height * 0.08, 36, 120),
        "COPY_TOP": round(target.height * target.copy_top_ratio),
        "COPY_LEFT": round(target.width * target.copy_left_ratio),
        "COPY_WIDTH": round(target.width * target.copy_width_ratio),
        "HEADLINE_SIZE": clamp(target.width * target.headline_ratio, 68, 150),
        "BODY_SIZE": clamp(target.width * target.body_ratio, 30, 54),
        "KICKER_SIZE": clamp(target.width * 0.022, 22, 42),
        "BADGE_DOT": clamp(target.width * 0.018, 18, 34),
        "BADGE_RING": clamp(target.width * 0.007, 7, 16),
        "BADGE_GAP": clamp(target.width * 0.012, 12, 24),
        "BADGE_MARGIN": clamp(target.height * 0.014, 20, 38),
        "SUBHEADING_MARGIN": clamp(target.height * 0.014, 20, 42),
        "SUBHEADING_WIDTH": round(target.width * (target.copy_width_ratio - 0.05)),
        "PILL_GAP": clamp(target.width * 0.012, 12, 26),
        "PILL_MARGIN": clamp(target.height * 0.024, 32, 72),
        "PILL_HEIGHT": clamp(target.height * 0.030, 42, 72),
        "PILL_PADDING_X": clamp(target.width * 0.020, 22, 42),
        "PILL_SIZE": clamp(target.width * 0.018, 22, 34),
        "PATTERN_SIZE": clamp(shorter_canvas_side * 0.18, 120, 260),
        "PLATE_LEFT": plate_left,
        "PLATE_TOP": plate_top,
        "PLATE_WIDTH": round(device_width * 0.94),
        "PLATE_HEIGHT": round(device_height * 0.88),
        "PLATE_RADIUS": round(device_radius * 1.05),
        "PLATE_TRANSFORM": target.plate_transform,
        "PLATE_BLUR": clamp(device_short_side * 0.05, 30, 68),
        "ROUTE_LEFT": round(target.width * -0.08),
        "ROUTE_TOP": round(target.height * 0.46),
        "ROUTE_WIDTH": route_width,
        "ROUTE_HEIGHT": route_height,
        "ROUTE_STROKE": clamp(shorter_canvas_side * 0.010, 10, 24),
        "ROUTE_ROTATION": -18 if target.device_x_offset_ratio >= 0 else 12,
    }
    values.update(THEME_VARIANTS[target.variant])
    return values


def render_template(target: PromoTarget, screenshot_path: Path, template_text: str) -> str:
    values = compute_render_values(target, screenshot_path)
    rendered = template_text
    for key, value in values.items():
        if key in {"SCREENSHOT_SRC", "DEVICE_TRANSFORM", "PLATE_TRANSFORM", "OBJECT_POSITION"}:
            replacement = str(value)
        else:
            replacement = html_escape(value)
        rendered = rendered.replace("{{" + key + "}}", replacement)

    remaining_placeholders = sorted(set(re.findall(r"{{[A-Z0-9_]+}}", rendered)))
    if remaining_placeholders:
        raise RuntimeError(f"Unresolved template placeholders: {', '.join(remaining_placeholders)}")
    return rendered


def write_target_html(
    target: PromoTarget,
    screenshot_path: Path,
    template_text: str,
    tmp_dir: Path,
) -> Path:
    html_output = render_template(target, screenshot_path, template_text)
    html_path = tmp_dir / f"{target.name.replace('/', '_')}.html"
    html_path.parent.mkdir(parents=True, exist_ok=True)
    html_path.write_text(html_output, encoding="utf-8")
    return html_path


def get_targets(selected_names: list[str] | None, selected_locales: list[str] | None) -> list[PromoTarget]:
    matching_targets = list(TARGETS)

    if selected_locales:
        matching_targets = [target for target in matching_targets if target.locale_code in selected_locales]

    if not selected_names:
        return matching_targets

    targets_by_name = {target.name: target for target in matching_targets}
    unknown_names = [name for name in selected_names if name not in targets_by_name]
    if unknown_names:
        available = ", ".join(targets_by_name)
        raise SystemExit(f"Unknown target(s): {', '.join(unknown_names)}. Available targets: {available}")
    return [targets_by_name[name] for name in selected_names]


def render_pngs(targets: list[PromoTarget], html_paths: dict[str, Path], output_dir: Path) -> None:
    try:
        from playwright.sync_api import Error as PlaywrightError
        from playwright.sync_api import sync_playwright
    except ModuleNotFoundError as exc:
        raise SystemExit(
            "Python Playwright is not installed. Run:\n"
            "  python3 -m pip install -r tool/store_screenshots/requirements.txt\n"
            "  python3 -m playwright install chromium"
        ) from exc

    try:
        with sync_playwright() as playwright:
            browser = playwright.chromium.launch()
            for target in targets:
                output_path = output_dir / f"{target.name}.png"
                output_path.parent.mkdir(parents=True, exist_ok=True)
                page = browser.new_page(viewport={"width": target.width, "height": target.height}, device_scale_factor=1)
                page.goto(html_paths[target.name].resolve().as_uri(), wait_until="networkidle")
                page.screenshot(path=str(output_path), type="png", full_page=False)
                page.close()

                rendered_width, rendered_height = png_dimensions(output_path)
                if (rendered_width, rendered_height) != (target.width, target.height):
                    raise RuntimeError(
                        f"{output_path} rendered as {rendered_width}x{rendered_height}, "
                        f"expected {target.width}x{target.height}"
                    )
                print(f"wrote {output_path.relative_to(REPO_ROOT)} ({rendered_width}x{rendered_height})")
            browser.close()
    except PlaywrightError as exc:
        raise SystemExit(
            "Playwright could not start Chromium. Run:\n"
            "  python3 -m playwright install chromium\n"
            f"Original error: {exc}"
        ) from exc


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Export promotional screenshots for store listings.")
    parser.add_argument("--source-dir", type=Path, default=DEFAULT_SOURCE_DIR, help="Folder containing raw screenshots.")
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT_DIR, help="Folder for generated PNGs.")
    parser.add_argument("--tmp-dir", type=Path, default=DEFAULT_TMP_DIR, help="Folder for generated HTML previews.")
    parser.add_argument(
        "--target",
        action="append",
        choices=[target.name for target in TARGETS],
        help="Render only one target. Can be provided more than once.",
    )
    parser.add_argument(
        "--locale",
        action="append",
        choices=[locale.code for locale in LOCALES],
        help="Render only one locale. Can be provided more than once.",
    )
    parser.add_argument("--dry-run", action="store_true", help="Write HTML previews but do not render PNGs.")
    parser.add_argument("--inventory", action="store_true", help="Print screenshot inventory before rendering.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    source_dir = args.source_dir.resolve()
    output_dir = args.output_dir.resolve()
    tmp_dir = args.tmp_dir.resolve()

    if args.inventory:
        print_inventory(source_dir)
        print()

    selected_targets = get_targets(args.target, args.locale)
    scene_assets = selected_scene_assets(selected_targets, source_dir)
    template_text = TEMPLATE_PATH.read_text(encoding="utf-8")

    html_paths: dict[str, Path] = {}
    for target in selected_targets:
        screenshot_path = scene_assets[target.scene_key]
        html_path = write_target_html(target, screenshot_path, template_text, tmp_dir)
        html_paths[target.name] = html_path
        print(f"prepared {html_path.relative_to(REPO_ROOT)} from {screenshot_path.relative_to(REPO_ROOT)}")

    if args.dry_run:
        print("dry run complete; PNG rendering skipped")
        return

    render_pngs(selected_targets, html_paths, output_dir)


if __name__ == "__main__":
    main()