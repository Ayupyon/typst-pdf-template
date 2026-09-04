#!/usr/bin/env python3
"""Compile and structurally verify Rin's focused PDF/HTML gate fixture."""

from __future__ import annotations

import hashlib
import re
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "tests" / "fixtures" / "dual-output.typ"
MISSING_ALT = ROOT / "tests" / "fixtures" / "missing-alt.typ"
EMPTY_ALT = ROOT / "tests" / "fixtures" / "empty-alt.typ"


def run(*args: str, ok: bool = True) -> subprocess.CompletedProcess[str]:
    proc = subprocess.run(
        args,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if ok and proc.returncode != 0:
        raise AssertionError(
            f"command failed ({proc.returncode}): {' '.join(args)}\n{proc.stderr}"
        )
    return proc


def require(text: str, pattern: str, description: str) -> None:
    if re.search(pattern, text, flags=re.S) is None:
        raise AssertionError(f"missing {description}: /{pattern}/")


def main() -> None:
    if shutil.which("typst") is None or shutil.which("pdftotext") is None:
        raise AssertionError("typst and pdftotext are required")

    with tempfile.TemporaryDirectory(prefix="rin-template-gate-") as directory:
        output = Path(directory)
        pdf = output / "dual-output.pdf"
        dated_pdf = output / "deterministic-date.pdf"
        html_a = output / "dual-output-a.html"
        html_b = output / "dual-output-b.html"
        text_path = output / "dual-output.txt"

        run("typst", "compile", "--root", str(ROOT), str(FIXTURE), str(pdf))
        run(
            "typst",
            "compile",
            "--root",
            str(ROOT),
            str(ROOT / "tests" / "fixtures" / "deterministic-date.typ"),
            str(dated_pdf),
        )
        run(
            "typst",
            "compile",
            "--features",
            "html",
            "--pretty",
            "--root",
            str(ROOT),
            str(FIXTURE),
            str(html_a),
        )
        run(
            "typst",
            "compile",
            "--features",
            "html",
            "--pretty",
            "--root",
            str(ROOT),
            str(FIXTURE),
            str(html_b),
        )
        run("pdftotext", "-layout", str(pdf), str(text_path))
        dated_text_path = output / "deterministic-date.txt"
        run("pdftotext", "-layout", str(dated_pdf), str(dated_text_path))

        pdf_text = text_path.read_text(encoding="utf-8")
        html = html_a.read_text(encoding="utf-8")
        html_rebuilt = html_b.read_text(encoding="utf-8")

        for visible in (
            "Definition 1.1",
            "Theorem 1.1",
            "Theorem 1.2",
            "Lemma 1.1",
            "Theorem 2.1",
            "Lemma 2.1",
            "定理 2.2",
        ):
            if visible not in pdf_text:
                raise AssertionError(f"PDF is missing visible block number: {visible}")
            if visible not in html:
                raise AssertionError(f"HTML is missing visible block number: {visible}")

        for class_name in (
            "rin-block--definition",
            "rin-block--theorem",
            "rin-block--lemma",
            "rin-proof",
            "rin-block__heading",
            "rin-block__body",
        ):
            require(html, rf'class="[^"]*{re.escape(class_name)}', class_name)

        anchors = (
            "group-definition",
            "first-theorem",
            "inverse-theorem",
            "first-lemma",
            "second-theorem",
            "second-lemma",
            "localized-theorem",
        )
        for anchor in anchors:
            require(html, rf'id="{anchor}"', f"stable anchor {anchor}")

        for anchor in (
            "group-definition",
            "first-theorem",
            "inverse-theorem",
            "first-lemma",
            "second-theorem",
            "second-lemma",
            "localized-theorem",
        ):
            require(html, rf'href="#{anchor}"', f"reference link to {anchor}")

        for visible in ("证明。", "定理 2.2"):
            if visible not in pdf_text or visible not in html:
                raise AssertionError(f"localized label missing from an output: {visible}")

        dated_text = dated_text_path.read_text(encoding="utf-8")
        if "2026-09-04" not in dated_text:
            raise AssertionError("explicit deterministic date is missing from PDF")

        require(html, r'<svg(?:\s|>)', "inline Fletcher SVG")
        require(html, r'class="rin-diagram"', "diagram wrapper")
        require(html, r'role="img"', "diagram image role")
        require(
            html,
            r'aria-label="A commutative triangle with arrows from A to B, B to C, and A to C"',
            "diagram accessible label",
        )
        require(html, r'<figcaption[^>]*>.*A commutative triangle\.', "diagram caption")

        ids_a = sorted(re.findall(r'id="([^"]+)"', html))
        ids_b = sorted(re.findall(r'id="([^"]+)"', html_rebuilt))
        if ids_a != ids_b:
            raise AssertionError("HTML IDs changed across identical rebuilds")
        if hashlib.sha256(html_a.read_bytes()).digest() != hashlib.sha256(
            html_b.read_bytes()
        ).digest():
            raise AssertionError("HTML output is not deterministic across identical rebuilds")

        for invalid, name in ((MISSING_ALT, "missing"), (EMPTY_ALT, "empty")):
            rejected = run(
                "typst",
                "compile",
                "--features",
                "html",
                "--root",
                str(ROOT),
                str(invalid),
                str(output / f"{name}-alt.html"),
                ok=False,
            )
            if rejected.returncode == 0:
                raise AssertionError(f"diagram with {name} alt text unexpectedly compiled")
            if "diagram requires non-empty alt text" not in rejected.stderr:
                raise AssertionError(f"{name}-alt failure did not explain the requirement")

    print("Rin 0.3 dual-output gate passed")


if __name__ == "__main__":
    main()
