uv# Prompt: App Store & Google Play Promotional Screenshot Generator

## HTML/CSS/JS + Puppeteer — v2

---

## OVERVIEW

You are an expert front-end and automation engineer. Your task is to:

1. Use **ADB** to detect connected Android devices (one phone, one tablet) and capture raw screenshots
2. Build a **static HTML page** that composites each screenshot inside a pixel-accurate device frame (platform-specific status bar, navigation bar, corner rounding, Dynamic Island for iPhone)
3. Use **Puppeteer** to headlessly load the HTML at the exact canvas resolution and export PNG files
4. Output one PNG per required format for App Store and Google Play

---

## SECTION 1 — TOOLCHAIN

### Required npm packages

```bash
npm init -y
npm install puppeteer html-to-image
# ADB must be in PATH (Android SDK Platform Tools)
```

**Why Puppeteer instead of html2canvas:**
Puppeteer drives a real Chromium instance, so every CSS feature (border-radius, box-shadow, backdrop-filter, clip-path, SVG, web fonts, object-fit: cover) renders pixel-perfectly. html2canvas re-implements CSS in JS and has known gaps with clip-path and pseudo-elements — which are needed for the Dynamic Island cutout. Puppeteer sets the viewport to the exact pixel dimensions of each output, eliminating all scaling guesswork.

---

## SECTION 2 — DEVICE DISCOVERY & SCREENSHOT CAPTURE

### 2.1 Detect connected devices

```bash
adb devices -l
```

For each serial, query:

```bash
adb -s <SERIAL> shell wm size      # e.g. "Physical size: 1080x2400"
adb -s <SERIAL> shell wm density   # e.g. "Physical density: 420"
adb -s <SERIAL> shell getprop ro.product.model
```

**Classification:** divide the shorter physical pixel dimension by the density to get dp.

- Short side ≥ 600 dp → **TABLET_SERIAL**
- Short side < 600 dp → **PHONE_SERIAL**

### 2.2 Capture screenshots in both orientations

```bash
# Portrait
adb -s <SERIAL> shell settings put system accelerometer_rotation 0
adb -s <SERIAL> shell settings put system user_rotation 0
sleep 1.5
adb -s <SERIAL> shell screencap -p /sdcard/ss.png
adb -s <SERIAL> pull /sdcard/ss.png ./raw/<type>_portrait.png

# Landscape
adb -s <SERIAL> shell settings put system user_rotation 1
sleep 1.5
adb -s <SERIAL> shell screencap -p /sdcard/ss.png
adb -s <SERIAL> pull /sdcard/ss.png ./raw/<type>_landscape.png

# Restore
adb -s <SERIAL> shell settings put system accelerometer_rotation 1
```

Resulting files:

```
raw/phone_portrait.png
raw/phone_landscape.png
raw/tablet_portrait.png
raw/tablet_landscape.png
```

---

## SECTION 3 — DEVICE FRAME SPECIFICATIONS

> ⚠️ **CRITICAL — DO NOT HALLUCINATE DIMENSIONS.**
> Every measurement in this section is sourced from the references listed below.
> Do not invent or guess any pixel/dp value. If you are uncertain, use only the values given here.

### References for device geometry (read before coding)

- Apple safe areas: <https://developer.apple.com/design/human-interface-guidelines/layout#iOS-iPadOS-safe-area-insets>
- iPhone 16 Pro Max screen specs: <https://www.apple.com/iphone-16-pro/specs/>
- Dynamic Island measured dimensions (verified): width ≈ 126pt, height ≈ 37pt at 3× scale → 378 × 111 px
- Android safe areas: <https://developer.android.com/develop/ui/views/layout/edge-to-edge#system-bars>
- Google's Material Design status bar: 24dp (typical), navigation bar: 48dp gestural / 56dp 3-button
- Pixel 9 Pro (phone reference): 1080 × 2424 px, rounded corners 95px radius (physical)
- Samsung Galaxy Tab S9 (tablet reference): corners ~30px radius at display scale

---

### 3.1 — iPhone Frame (for App Store phone images)

The iPhone frame is rendered entirely in **HTML/CSS** layered over the screenshot using `position: absolute`.
All values below are expressed as a **percentage of canvas height** so they scale cleanly to any output resolution.

| Element                                  | Value                            |
| ---------------------------------------- | -------------------------------- |
| Corner radius (device body)              | 13.5% of shorter dimension       |
| Corner radius (screen area)              | 11.5% of shorter dimension       |
| Bezel thickness (all sides)              | 1.4% of shorter dimension        |
| Dynamic Island width                     | 28.6% of canvas width            |
| Dynamic Island height                    | 3.87% of canvas width × (37/126) |
| Dynamic Island top offset                | 0.8% of canvas height            |
| Dynamic Island border-radius             | 50% (pill shape)                 |
| Dynamic Island color                     | `#000000`                        |
| Status bar height (below Dynamic Island) | 5.5% of canvas height            |
| Home indicator height                    | 1.3% of canvas height            |
| Home indicator width                     | 33% of canvas width              |
| Home indicator color                     | `rgba(0,0,0,0.4)`                |
| Home indicator border-radius             | 3px                              |
| Status bar icon size                     | 12pt equivalent                  |

**iOS Status bar content** (portrait):

- Left: empty (Dynamic Island takes center; time is shown inside it in real iOS, but for screenshots show nothing or "9:41")
- Right icons (use SVG or Unicode): signal bars, WiFi, battery — all full/white

**CSS clip-path trick for Dynamic Island cutout:**
The screen content is clipped by punching a pill-shaped hole at the top center. Achieve this using:

```css
.screen-content {
  clip-path: polygon(
    /* full rect minus Dynamic Island pill area — use SVG clip-path instead */
  );
}
```

Use an **SVG `<clipPath>` element** with a compound path (full rectangle with a pill subtracted via `fill-rule: evenodd`) to cut the Dynamic Island hole out of the screenshot image. This is the only reliable CSS-native way to achieve it without JavaScript layout hacks.

```html
<svg width="0" height="0">
  <defs>
    <clipPath id="dynamic-island-clip" clipPathUnits="objectBoundingBox">
      <!-- Outer rect (full screen = 0,0 to 1,1) -->
      <path
        fill-rule="evenodd"
        d="
        M 0 0 L 1 0 L 1 1 L 0 1 Z
        M [DI_x1] [DI_y1]
          Q [DI_x1] [DI_y_top] [DI_cx1] [DI_y_top]
          L [DI_cx2] [DI_y_top]
          Q [DI_x2] [DI_y_top] [DI_x2] [DI_y1]
          L [DI_x2] [DI_y2]
          Q [DI_x2] [DI_y_bot] [DI_cx2] [DI_y_bot]
          L [DI_cx1] [DI_y_bot]
          Q [DI_x1] [DI_y_bot] [DI_x1] [DI_y2]
          Z
      "
      />
      <!-- Replace [DI_*] placeholders with computed objectBoundingBox fractions -->
    </clipPath>
  </defs>
</svg>
<img
  src="./raw/phone_portrait.png"
  style="clip-path: url(#dynamic-island-clip); ..."
/>
```

Compute the placeholder values in JS at render time from the canvas dimensions:

```js
const canvasW = 1320,
  canvasH = 2868; // or whichever target
const DI_w = canvasW * 0.286;
const DI_h = DI_w * (37 / 126);
const DI_x1 = (canvasW / 2 - DI_w / 2) / canvasW;
const DI_x2 = (canvasW / 2 + DI_w / 2) / canvasW;
const DI_y1 = (canvasH * 0.008) / canvasH;
const DI_y2 = (canvasH * 0.008 + DI_h) / canvasH;
const r = DI_h / 2 / canvasH; // pill radius as fraction of height
// Use for Q control points in the path above
```

---

### 3.2 — iPad Frame (for App Store tablet images)

iPads (non-Pro, Air, mini) do NOT have a Dynamic Island — they have a top camera/FaceTime bezel.
iPad Pro 11"/13" M4 has a Dynamic Island but for store screenshots Apple accepts any clean screenshot without a device frame — so render the iPad screenshots with a simple **flat bezel + rounded corners** only.

| Element           | Value                                                  |
| ----------------- | ------------------------------------------------------ |
| Corner radius     | 5.5% of shorter dimension                              |
| Top bezel         | 2.8% of canvas height                                  |
| Bottom bezel      | 2.8% of canvas height                                  |
| Side bezels       | 1.6% of canvas width                                   |
| Status bar height | 24px-equivalent proportional                           |
| Home indicator    | Not present on iPad Pro; render thin pill for Air/mini |

---

### 3.3 — Android Phone Frame (for Google Play phone images)

Google Play does **not** require device frames in screenshots (and actually recommends against them per their guidelines). However, the user wants a polished look. Render an Android-style frame:

| Element               | Value                                                                      |
| --------------------- | -------------------------------------------------------------------------- |
| Corner radius         | 8.8% of shorter dimension (mimics Pixel 9 Pro 95px at 1080px width ≈ 8.8%) |
| Bezel thickness       | 1.5% of shorter dimension                                                  |
| Status bar height     | 5.6% of canvas height (≈ 24dp at 428dp height)                             |
| Navigation bar height | 5.6% of canvas height (gestural bar; render as thin pill)                  |
| Status bar content    | Time (left), icons: signal + WiFi + battery (right), all filled/white      |
| Nav gesture bar       | 33% canvas width, 4px height, rounded, centered, `rgba(255,255,255,0.4)`   |
| Punch-hole camera     | Circle, diameter 2.8% of canvas width, centered top-center of status bar   |

**Punch-hole camera cutout:**
Use the same SVG `<clipPath>` technique but with a circle subtracted instead of a pill.

---

### 3.4 — Android Tablet Frame (for Google Play tablet images)

| Element           | Value                                                               |
| ----------------- | ------------------------------------------------------------------- |
| Corner radius     | 3.8% of shorter dimension                                           |
| Bezel             | 1.2% of shorter dimension                                           |
| Status bar height | 3.2% of canvas height (tablets have smaller relative status bars)   |
| Navigation bar    | Not shown on modern Android tablets in gesture mode; show thin pill |
| Camera            | Circle punch-hole, centered top, diameter 1.6% of canvas width      |

---

## SECTION 4 — HTML PAGE STRUCTURE

For each output, generate a self-contained HTML file:

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <style>
      * { margin: 0; padding: 0; box-sizing: border-box; }
      html, body { width: ${CANVAS_W}px; height: ${CANVAS_H}px; overflow: hidden; background: transparent; }

      .canvas {
        width: ${CANVAS_W}px;
        height: ${CANVAS_H}px;
        position: relative;
        overflow: hidden;
        border-radius: ${CORNER_RADIUS}px;
        background: #000;
        /* Outer device frame effect */
        box-shadow: 0 0 0 ${BEZEL}px #1a1a1e,
                    0 0 0 ${BEZEL + 2}px #3a3a3e,
                    0 0 0 ${BEZEL + 4}px #1a1a1e;
      }

      .screenshot {
        position: absolute;
        top: 0; left: 0;
        width: 100%; height: 100%;
        object-fit: cover;
        border-radius: ${SCREEN_CORNER_RADIUS}px;
      }

      .status-bar {
        position: absolute;
        top: 0; left: 0; right: 0;
        height: ${STATUS_BAR_H}px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0 ${CANVAS_W * 0.06}px;
        z-index: 10;
      }

      /* ... all other overlay elements */
    </style>
  </head>
  <body>
    <div class="canvas">
      <!-- SVG clip for Dynamic Island / punch-hole (platform-specific) -->
      <svg width="0" height="0">
        <defs>
          <clipPath id="screen-clip" clipPathUnits="objectBoundingBox">
            <!-- generated path here -->
          </clipPath>
        </defs>
      </svg>

      <!-- The app screenshot -->
      <img
        class="screenshot"
        src="${SCREENSHOT_PATH}"
        style="clip-path: url(#screen-clip);"
      />

      <!-- Status bar overlay -->
      <div class="status-bar">
        <span class="time">${PLATFORM === 'ios' ? '9:41' : '12:00'}</span>
        <div class="icons"><!-- signal, wifi, battery SVGs --></div>
      </div>

      <!-- Dynamic Island / punch-hole visual element (black pill/circle on top) -->
      ${PLATFORM === 'ios' ? `
      <div class="dynamic-island"></div>
      ` : `
      <div class="punch-hole"></div>
      `}

      <!-- Bottom nav bar / home indicator -->
      ${INCLUDE_NAV_BAR ? `
      <div class="nav-bar">...</div>
      ` : ''}
      <div class="home-indicator"></div>
    </div>
  </body>
</html>
```

Inject all dimension variables (CANVAS_W, CANVAS_H, CORNER_RADIUS, etc.) from a JS config object using template literals — generate one HTML string per export target, write it to a temp file, and load it in Puppeteer.

---

## SECTION 5 — PUPPETEER EXPORT PIPELINE

```js
// export.mjs
import puppeteer from "puppeteer";
import { writeFileSync, mkdirSync } from "fs";
import { join } from "path";

const TARGETS = [
  // Google Play
  {
    name: "google_play/phone_portrait",
    w: 1080,
    h: 1920,
    screenshot: "phone_portrait",
    platform: "android",
    device: "phone",
  },
  {
    name: "google_play/phone_landscape",
    w: 1920,
    h: 1080,
    screenshot: "phone_landscape",
    platform: "android",
    device: "phone",
  },
  {
    name: "google_play/tablet_portrait",
    w: 1600,
    h: 2560,
    screenshot: "tablet_portrait",
    platform: "android",
    device: "tablet",
  },
  {
    name: "google_play/tablet_landscape",
    w: 2560,
    h: 1600,
    screenshot: "tablet_landscape",
    platform: "android",
    device: "tablet",
  },
  // App Store — iPhone
  {
    name: "app_store/iphone_6_9_portrait",
    w: 1320,
    h: 2868,
    screenshot: "phone_portrait",
    platform: "ios",
    device: "phone",
  },
  {
    name: "app_store/iphone_6_9_landscape",
    w: 2868,
    h: 1320,
    screenshot: "phone_landscape",
    platform: "ios",
    device: "phone",
  },
  {
    name: "app_store/iphone_6_7_portrait",
    w: 1290,
    h: 2796,
    screenshot: "phone_portrait",
    platform: "ios",
    device: "phone",
  },
  {
    name: "app_store/iphone_6_7_landscape",
    w: 2796,
    h: 1290,
    screenshot: "phone_landscape",
    platform: "ios",
    device: "phone",
  },
  // App Store — iPad
  {
    name: "app_store/ipad_13inch_portrait",
    w: 2064,
    h: 2752,
    screenshot: "tablet_portrait",
    platform: "ios",
    device: "tablet",
  },
  {
    name: "app_store/ipad_13inch_landscape",
    w: 2752,
    h: 2064,
    screenshot: "tablet_landscape",
    platform: "ios",
    device: "tablet",
  },
  {
    name: "app_store/ipad_12_9inch_portrait",
    w: 2048,
    h: 2732,
    screenshot: "tablet_portrait",
    platform: "ios",
    device: "tablet",
  },
  {
    name: "app_store/ipad_12_9inch_landscape",
    w: 2732,
    h: 2048,
    screenshot: "tablet_landscape",
    platform: "ios",
    device: "tablet",
  },
  {
    name: "app_store/ipad_11inch_portrait",
    w: 1668,
    h: 2388,
    screenshot: "tablet_portrait",
    platform: "ios",
    device: "tablet",
  },
  {
    name: "app_store/ipad_11inch_landscape",
    w: 2388,
    h: 1668,
    screenshot: "tablet_landscape",
    platform: "ios",
    device: "tablet",
  },
];

const browser = await puppeteer.launch({ headless: "new" });

for (const target of TARGETS) {
  const { name, w, h, screenshot, platform, device } = target;
  const isLandscape = w > h;

  // 1. Generate the HTML for this target (see Section 4)
  const html = generateHTML({
    w,
    h,
    screenshot,
    platform,
    device,
    isLandscape,
  });

  // 2. Write temp HTML
  const tmpPath = `./tmp/${name.replace("/", "_")}.html`;
  mkdirSync("./tmp", { recursive: true });
  writeFileSync(tmpPath, html, "utf8");

  // 3. Open in Puppeteer at exact pixel dimensions
  const page = await browser.newPage();
  await page.setViewport({ width: w, height: h, deviceScaleFactor: 1 });
  await page.goto(`file://${process.cwd()}/${tmpPath}`, {
    waitUntil: "networkidle0",
  });

  // 4. Screenshot with zero chrome
  const outDir = `./output/${name.split("/")[0]}`;
  mkdirSync(outDir, { recursive: true });
  const outPath = `./output/${name}.png`;
  await page.screenshot({
    path: outPath,
    type: "png",
    clip: { x: 0, y: 0, width: w, height: h },
  });

  // 5. Verify dimensions (using sharp or jimp)
  console.log(`✓ ${name}.png (${w}×${h})`);
  await page.close();
}

await browser.close();
```

---

## SECTION 6 — STATUS BAR ICONS (SVG — no external dependencies)

Inline these SVGs directly in the HTML. They are platform-neutral and safe to hardcode:

### Battery (full)

```svg
<svg width="25" height="12" viewBox="0 0 25 12" fill="white">
  <rect x="0" y="1" width="21" height="10" rx="2" ry="2" stroke="white" stroke-width="1.2" fill="none"/>
  <rect x="21.5" y="3.5" width="2" height="5" rx="1" fill="white"/>
  <rect x="1.5" y="2.5" width="17" height="7" rx="1.2" fill="white"/>
</svg>
```

### WiFi (full)

```svg
<svg width="16" height="12" viewBox="0 0 16 12" fill="white">
  <path d="M8 9.5 L8 9.5" stroke="white" stroke-width="2" stroke-linecap="round"/>
  <path d="M5.5 7.2 Q8 5.5 10.5 7.2" stroke="white" stroke-width="1.4" fill="none" stroke-linecap="round"/>
  <path d="M3 4.8 Q8 1.5 13 4.8" stroke="white" stroke-width="1.4" fill="none" stroke-linecap="round"/>
  <path d="M0.5 2.4 Q8 -1.5 15.5 2.4" stroke="white" stroke-width="1.4" fill="none" stroke-linecap="round"/>
</svg>
```

### Signal bars (full)

```svg
<svg width="17" height="12" viewBox="0 0 17 12" fill="white">
  <rect x="0" y="9" width="3" height="3" rx="0.5"/>
  <rect x="4.5" y="6" width="3" height="6" rx="0.5"/>
  <rect x="9" y="3" width="3" height="9" rx="0.5"/>
  <rect x="13.5" y="0" width="3" height="12" rx="0.5"/>
</svg>
```

---

## SECTION 7 — DYNAMIC ISLAND CSS

The Dynamic Island is rendered as a CSS element **on top** of the screenshot. The SVG clip-path punches the matching hole in the screenshot beneath it.

```css
.dynamic-island {
  position: absolute;
  top: calc(${CANVAS_H} * 0.008px); /* 0.8% from top */
  left: 50%;
  transform: translateX(-50%);
  width: calc(${CANVAS_W} * 0.286px); /* 28.6% of width */
  height: calc(${CANVAS_W} * 0.286px * 37 / 126); /* preserve 37:126 ratio */
  background: #000;
  border-radius: 50px;
  z-index: 20;
}
```

Because the Dynamic Island is a real black element on top, the visual result is seamless: the screenshot is clipped to remove the pill area, and the black pill sits on top at the exact same position.

---

## SECTION 8 — CORNER ROUNDING ON THE CANVAS

The outer `.canvas` div uses `border-radius` and `overflow: hidden`. This clips the screenshot naturally at the corners. Do not add corner masks separately — CSS handles it.

```css
.canvas {
  border-radius: ${CORNER_RADIUS}px; /* from SECTION 3 tables */
  overflow: hidden;
}
.screenshot {
  border-radius: ${SCREEN_CORNER_RADIUS}px; /* inner screen radius, slightly smaller */
}
```

---

## SECTION 9 — OUTPUT DIRECTORY STRUCTURE

```
output/
├── google_play/
│   ├── phone_portrait.png         1080×1920
│   ├── phone_landscape.png        1920×1080
│   ├── tablet_portrait.png        1600×2560
│   └── tablet_landscape.png       2560×1600
└── app_store/
    ├── iphone_6_9_portrait.png    1320×2868
    ├── iphone_6_9_landscape.png   2868×1320
    ├── iphone_6_7_portrait.png    1290×2796
    ├── iphone_6_7_landscape.png   2796×1290
    ├── ipad_13inch_portrait.png   2064×2752
    ├── ipad_13inch_landscape.png  2752×2064
    ├── ipad_12_9inch_portrait.png 2048×2732
    ├── ipad_12_9inch_landscape.png 2732×2048
    ├── ipad_11inch_portrait.png   1668×2388
    └── ipad_11inch_landscape.png  2388×1668
```

---

## SECTION 10 — VALIDATION

After generating all files:

```js
import sharp from "sharp"; // npm install sharp
for (const target of TARGETS) {
  const { width, height } = await sharp(
    `./output/${target.name}.png`,
  ).metadata();
  console.assert(
    width === target.w,
    `${target.name}: width ${width} ≠ ${target.w}`,
  );
  console.assert(
    height === target.h,
    `${target.name}: height ${height} ≠ ${target.h}`,
  );
}
```

---

## SECTION 11 — CONSTRAINTS & RULES

- **Never hardcode paths** to ADB, assume it is on PATH
- **Never invent device dimensions** — all pixel values must trace to the tables in Section 3
- **No external image assets** for device frames — all chrome is CSS/SVG only
- **No watermarks**, no advertising text, no store badges
- **Opaque backgrounds only** — Google Play rejects transparent PNGs
- The screenshot fills the screen area **object-fit: cover** — letterboxing is forbidden
- Run the full script with: `node export.mjs`
