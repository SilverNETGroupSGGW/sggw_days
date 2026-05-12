# Promotional Store Screenshots

This folder contains a Python Playwright pipeline for turning raw app screenshots from `doc/` into polished promotional images for App Store and Google Play listings. The default export creates five image variants for every required store format in two locales: English and Polish.

## Phase 1: Style Analysis

### Color Palette

- Primary deep green: `#173c2d` and `#315f24` for navigation, buttons, progress, and brand emphasis.
- Secondary mint: `#c8f0b4` for selected states, prompt panels, and soft promotional backgrounds.
- Surface/off-white: `#f7f9ee` and `#eff6e8` for Material 3 surfaces and readable light-mode UI.
- Dark surface: `#0b1710` and `#101510` for the dark-mode map and bottom navigation.
- Accent blue: `#2f80ed` appears in map/location details and works well as a small contrast accent.

### Design Language

The screenshots read as Material 3: rounded controls, filled icon buttons, bottom navigation, large touch targets, and soft tonal surfaces. The promotional template keeps that language but makes the output less like plain screenshots by placing each screen in a clean device frame, adding depth with shadows, and using angled background bands derived from the green/mint palette.

### Typography Vibe

- Best system pairing for exports: `Inter` or `SF Pro Display` for headlines, with `Roboto`/system sans for body copy.
- Android-native fallback: `Google Sans` style headings with `Roboto` body.
- iOS-native fallback: `SF Pro Display` headings with `SF Pro Text` body.

The template uses a safe system stack, so it renders without external fonts:

```css
font-family: Inter, "SF Pro Display", "Segoe UI", Roboto, Arial, sans-serif;
```

## Screenshot Mapping

The exporter groups same-stem files as related captures and chooses browser-supported PNG/JPEG/WebP assets. The HEIC-only list screenshot is detected but skipped unless a PNG conversion is added.

| Scene key | Selected source | Content | Best marketing use |
| --- | --- | --- | --- |
| `tablet_start_map` | `doc/IMG_0300.PNG` | Light landscape map with "Start Exploring" prompt | Onboarding, map-first discovery |
| `tablet_point_collected` | `doc/IMG_0302.PNG` | Light landscape map with collected-point dialog | QR success, reward moment |
| `phone_treasure_map` | `doc/IMG_2987.png` | Dark portrait Polish treasure map with controls | In-pocket campus hunt |
| `phone_point_list` | `doc/IMG_2988.HEIC` | Dark point list bottom sheet | Convert to `IMG_2988.png` before use |

## Required Outputs

The script exports five PNGs for each format at these exact sizes in both `en/` and `pl/` trees. Visible artwork copy avoids store names; folder names are only for organizing the required output formats.

| Format | Files | Size |
| --- | --- | --- |
| Apple 6.7-inch iPhone | `store_screenshots/promotional/en/app_store/iphone_6_7/01_campus_clues.png` ... `05_campus_overview.png` and matching `pl/...` files | 1290 x 2796 |
| Apple 6.5-inch iPhone | `store_screenshots/promotional/en/app_store/iphone_6_5/01_campus_clues.png` ... `05_campus_overview.png` and matching `pl/...` files | 1242 x 2688 |
| Apple 5.5-inch iPhone | `store_screenshots/promotional/en/app_store/iphone_5_5/01_campus_clues.png` ... `05_campus_overview.png` and matching `pl/...` files | 1242 x 2208 |
| Apple 12.9-inch iPad | `store_screenshots/promotional/en/app_store/ipad_12_9/01_campus_clues.png` ... `05_campus_overview.png` and matching `pl/...` files | 2048 x 2732 |
| Google Play standard | `store_screenshots/promotional/en/google_play/standard/01_campus_clues.png` ... `05_campus_overview.png` and matching `pl/...` files | 1080 x 1920 |

## Usage

Install Playwright once:

```bash
python3 -m pip install -r tool/store_screenshots/requirements.txt
python3 -m playwright install chromium
```

Preview the screenshot inventory and generated HTML files:

```bash
python3 tool/store_screenshots/export_promos.py --inventory --dry-run
```

Render all PNGs:

```bash
python3 tool/store_screenshots/export_promos.py --inventory
```

Render only one locale:

```bash
python3 tool/store_screenshots/export_promos.py --inventory --locale en
```

Render one target:

```bash
python3 tool/store_screenshots/export_promos.py --target en/app_store/iphone_6_7/01_campus_clues
```

## Template Customization

`promo_template.html` is intentionally placeholder-driven. The exporter fills values such as `{{HEADING}}`, `{{SUBHEADING}}`, `{{SCREENSHOT_SRC}}`, `{{CANVAS_WIDTH}}`, and `{{CANVAS_HEIGHT}}` from the target config in `export_promos.py`.

To change copy, edit `PROMO_SPECS` and `PROMO_TRANSLATIONS` in `export_promos.py`. To change the visual system, edit `promo_template.html` or the `THEME_VARIANTS` palette in the exporter.
