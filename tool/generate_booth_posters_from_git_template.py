from __future__ import annotations

import functools
import http.server
import json
import re
import shutil
import socketserver
import subprocess
import threading
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path

from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "generated" / "booth_posters_pdf"
OUTPUT_ZIP = ROOT / "generated" / "booth_posters_pdf.zip"
EXPORT_HTML = ROOT / "generated" / "_checkpoint_export.html"
BASE_URL = (
    "https://firestore.googleapis.com/v1/projects/sggw-days/"
    "databases/(default)/documents"
)
BOOTH_CATEGORIES = ("Wydziały", "Jednostki SGGW", "Koła i organizacje")
A4_SCREEN_SIZE = (794, 1123)
DEVICE_SCALE_FACTOR = 3
DEFAULT_POINT_NAME = "Punkt Kontrolny"
DEFAULT_CHECKPOINT_URL = "https://sggw-days.web.app/scan"


@dataclass
class PosterEntry:
    category: str
    article_title: str
    point_id: str
    point_name: str
    qr_code: str
    point_order: int

    @property
    def slug(self) -> str:
        return slugify(self.point_name)


def read_firestore_value(value: dict):
    if "stringValue" in value:
        return value["stringValue"]
    if "integerValue" in value:
        return int(value["integerValue"])
    if "doubleValue" in value:
        return float(value["doubleValue"])
    if "booleanValue" in value:
        return value["booleanValue"]
    if "nullValue" in value:
        return None
    if "arrayValue" in value:
        return [
            read_firestore_value(item)
            for item in value.get("arrayValue", {}).get("values", [])
        ]
    if "mapValue" in value:
        return {
            key: read_firestore_value(inner)
            for key, inner in value.get("mapValue", {}).get("fields", {}).items()
        }
    return None


def normalize_document(document: dict) -> dict:
    return {
        "id": document["name"].split("/")[-1],
        **{
            key: read_firestore_value(value)
            for key, value in document.get("fields", {}).items()
        },
    }


def fetch_json(path: str) -> dict:
    with urllib.request.urlopen(f"{BASE_URL}/{path}") as response:
        return json.load(response)


def is_building_point(point: dict) -> bool:
    return point["id"].startswith("point-budynek-") or str(
        point.get("name", ""),
    ).startswith("Budynek ")


def preferred_point(article: dict, points_by_id: dict[str, dict]) -> dict | None:
    linked_points = [
        points_by_id[point_id]
        for point_id in article.get("treasurePointIds", [])
        if point_id in points_by_id
    ]
    for point in linked_points:
        if not is_building_point(point):
            return point
    return None


def build_entries() -> list[PosterEntry]:
    points = {
        point["id"]: point
        for point in map(
            normalize_document,
            fetch_json("treasure_points?pageSize=250").get("documents", []),
        )
    }
    articles = [
        normalize_document(document)
        for document in fetch_json("wiki_articles?pageSize=250").get("documents", [])
    ]

    entries: list[PosterEntry] = []
    for article in articles:
        if article.get("category") not in BOOTH_CATEGORIES:
            continue
        if not article.get("treasurePointIds"):
            continue

        point = preferred_point(article, points)
        if not point:
            continue

        entries.append(
            PosterEntry(
                category=article.get("category", ""),
                article_title=article.get("title", ""),
                point_id=point["id"],
                point_name=point.get("name", ""),
                qr_code=point.get("qrCode")
                or f"https://sggw-days.web.app/scan/{point['id']}",
                point_order=int(point.get("order", 9999)),
            ),
        )

    entries.sort(
        key=lambda entry: (
            entry.point_order,
            BOOTH_CATEGORIES.index(entry.category),
            entry.article_title.casefold(),
        ),
    )
    return entries


def slugify(value: str) -> str:
    simplified = value.lower()
    replacements = {
        "ą": "a",
        "ć": "c",
        "ę": "e",
        "ł": "l",
        "ń": "n",
        "ó": "o",
        "ś": "s",
        "ż": "z",
        "ź": "z",
    }
    for source, target in replacements.items():
        simplified = simplified.replace(source, target)
    simplified = re.sub(r"[^a-z0-9]+", "-", simplified)
    return simplified.strip("-")


def load_promo_html_from_git() -> str:
    return (ROOT / "docs" / "promo.html").read_text(encoding="utf-8")


def extract_style_block(html: str) -> str:
    match = re.search(r"<style>(.*?)</style>", html, flags=re.S)
    if not match:
        raise RuntimeError("Could not extract style block from docs/promo.html")
    return match.group(1).strip()


def extract_wrapper_three(html: str) -> str:
    start_marker = '<div\n        id="wrapper-3"'
    end_marker = '\n\n      <!-- ============================================== -->\n      <!-- PLAKAT 4:'
    start_index = html.index(start_marker)
    end_index = html.index(end_marker, start_index)
    wrapper = html[start_index:end_index].strip()
    return re.sub(
        r'src="(?!https?:|data:)([^\"]+)"',
        r'src="../docs/\1"',
        wrapper,
    )


def write_export_template() -> None:
    html = load_promo_html_from_git()
    style_block = extract_style_block(html)
    wrapper_three = extract_wrapper_three(html)
    export_script = f"""
      const DEFAULT_CHECKPOINT_URL = {json.dumps(DEFAULT_CHECKPOINT_URL)};
      const DEFAULT_POINT_NAME = {json.dumps(DEFAULT_POINT_NAME)};

      function updateGroup(className, url) {{
        if (!url) return;
        document.querySelectorAll('.' + className).forEach((img) => {{
          const size = img.dataset.size || '300x300';
          img.src = `https://api.qrserver.com/v1/create-qr-code/?size=${{size}}&data=${{encodeURIComponent(url)}}`;
        }});
      }}

      function updateCheckpointPoster() {{
        const params = new URLSearchParams(window.location.search);
        const pointName = params.get('point') || DEFAULT_POINT_NAME;
        const checkpointUrl = params.get('checkpoint') || DEFAULT_CHECKPOINT_URL;
        updateGroup('qr-check', checkpointUrl);
        document.querySelectorAll('.checkpoint-point-name').forEach((node) => {{
          node.textContent = pointName;
        }});
      }}

      document.addEventListener('DOMContentLoaded', updateCheckpointPoster);
    """.strip()
    export_styles = """
      html,
      body {
        background: white !important;
        margin: 0 !important;
        padding: 0 !important;
        overflow: hidden !important;
      }

      .no-print {
        display: none !important;
      }

      .poster-wrapper,
      .poster-container {
        margin: 0 !important;
        padding: 0 !important;
        border: none !important;
        border-radius: 0 !important;
        box-shadow: none !important;
        overflow: visible !important;
      }
    """.strip()
    export_html = f"""<!doctype html>
<html lang=\"pl\">
  <head>
    <meta charset=\"UTF-8\" />
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />
    <title>Checkpoint Export</title>
    <script src=\"https://cdn.tailwindcss.com\"></script>
    <style>
{style_block}

{export_styles}
    </style>
    <script>
{export_script}
    </script>
  </head>
  <body>
{wrapper_three}
  </body>
</html>
"""
    EXPORT_HTML.write_text(export_html, encoding="utf-8")


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format: str, *args) -> None:
        return


class ReusableTCPServer(socketserver.TCPServer):
    allow_reuse_address = True


def start_http_server() -> tuple[ReusableTCPServer, threading.Thread, str]:
    handler = functools.partial(QuietHandler, directory=str(ROOT))
    server = ReusableTCPServer(("127.0.0.1", 0), handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    port = server.server_address[1]
    return server, thread, f"http://127.0.0.1:{port}/{EXPORT_HTML.relative_to(ROOT).as_posix()}"


def render_png(url: str, destination: Path) -> None:
    width, height = A4_SCREEN_SIZE
    command = [
        "chromium",
        "--headless",
        "--no-sandbox",
        "--disable-gpu",
        "--disable-dev-shm-usage",
        "--hide-scrollbars",
        "--run-all-compositor-stages-before-draw",
        "--default-background-color=ffffffff",
        f"--window-size={width},{height}",
        f"--force-device-scale-factor={DEVICE_SCALE_FACTOR}",
        "--virtual-time-budget=12000",
        f"--screenshot={destination}",
        url,
    ]
    subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


def write_pdf_from_png(image_path: Path, pdf_path: Path, title: str) -> None:
    pdf = canvas.Canvas(str(pdf_path), pagesize=A4)
    pdf.setTitle(title)
    pdf.drawImage(str(image_path), 0, 0, width=A4[0], height=A4[1])
    pdf.showPage()
    pdf.save()


def poster_filename(index: int, entry: PosterEntry) -> str:
    return f"{index:02d}_{entry.slug}.pdf"


def write_manifest(entries: list[PosterEntry]) -> None:
    manifest = [
        {
            "category": entry.category,
            "articleTitle": entry.article_title,
            "pointId": entry.point_id,
            "pointName": entry.point_name,
            "pointOrder": entry.point_order,
            "qrCode": entry.qr_code,
            "fileName": poster_filename(index, entry),
        }
        for index, entry in enumerate(entries, start=1)
    ]
    (OUTPUT_DIR / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def rebuild_zip_archive() -> None:
    if OUTPUT_ZIP.exists():
        OUTPUT_ZIP.unlink()
    shutil.make_archive(str(OUTPUT_ZIP.with_suffix("")), "zip", OUTPUT_DIR)


def render_posters(entries: list[PosterEntry]) -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for file_path in OUTPUT_DIR.iterdir():
        if file_path.is_file():
            file_path.unlink()

    write_export_template()
    server, thread, base_url = start_http_server()
    try:
        for index, entry in enumerate(entries, start=1):
            file_name = poster_filename(index, entry)
            png_path = OUTPUT_DIR / file_name.replace(".pdf", ".png")
            pdf_path = OUTPUT_DIR / file_name
            query = urllib.parse.urlencode(
                {
                    "point": entry.point_name,
                    "checkpoint": entry.qr_code,
                },
            )
            render_png(f"{base_url}?{query}", png_path)
            write_pdf_from_png(png_path, pdf_path, f"Plakat stoiska - {entry.point_name}")
            png_path.unlink(missing_ok=True)
    finally:
        server.shutdown()
        server.server_close()
        thread.join(timeout=1)
        EXPORT_HTML.unlink(missing_ok=True)

    write_manifest(entries)
    rebuild_zip_archive()


def main() -> None:
    entries = build_entries()
    render_posters(entries)
    print(f"Generated {len(entries)} HTML-based PDF posters in {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
