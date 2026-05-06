# App Icon Generation

Source of truth: `assets/icon/source/app_icon.svg`

## Source analysis

- Rendered analysis size: 4096x4096
- Opaque bounds: left 1613, top 904, width 991, height 1767
- Horizontal alignment group: `pinpoint` → left 1613, top 1457, width 875, height 1214
- Horizontal anchor within full artwork: 44.1% of the artwork width
- Occupancy ratio: width 24.2%, height 43.1%
- Background used for flattened icons: `#C8F0B4`

## Generated outputs

- Master icon: `assets/icon/app_icon_master.png`
- Android adaptive foreground: `assets/icon/android_dynamic_foreground.png`
- Android adaptive monochrome: `assets/icon/android_dynamic_monochrome.png`
- Browser favicon SVG: `web/favicon.svg`
- Safari pinned-tab mask: `web/safari-pinned-tab.svg`

## Validation

- Native flat icon visible max dimension: 573 px (56.0% of canvas)
- Android foreground source max dimension: 531 px (51.9% of canvas, target <= 51.9%)
- Android foreground after 0% launcher inset: 531 px (51.9% of canvas, target 50.9%-51.9%)
- Android themed monochrome source max dimension: 531 px (51.9% of canvas, target <= 51.9%)
- Android themed monochrome after 0% launcher inset: 531 px (51.9% of canvas, target 50.9%-51.9%)
- Master icon canvas: 1024x1024

## Regenerate

```bash
dart run tool/generate_app_icons.dart
dart run flutter_launcher_icons -f flutter_launcher_icons.native.yaml
dart run tool/validate_android_icons.dart
```

Preview-only assets are intentionally excluded. The generator emits only production icon sources used by the native app launcher pipeline.
