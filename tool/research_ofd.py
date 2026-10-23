"""Capture public OFD responses, preserving bytes and request provenance.

Run: python -X utf8 tool/research_ofd.py --output build/ofd-research
Uses only Python's standard library. No CAPTCHA solving or browser automation.
The API URL is observed in the site's public JS, not guessed.
"""

from __future__ import annotations

import argparse
import hashlib
import html
import json
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qs, urlencode, urljoin, urlsplit, urlunsplit
from urllib.request import HTTPRedirectHandler, Request, build_opener


QR = "http://consumer.oofd.kz?i=1462733895&amp;f=010102236118&amp;s=2002.00&amp;t=20261007T153259"
HOST = "consumer.oofd.kz"
API_PATH = "/api/consumer-proxy/api/tickets/get-by-url"
HEADERS = {"User-Agent": "Mozilla/5.0", "Accept-Language": "ru"}


class SameOriginRedirects(HTTPRedirectHandler):
    """Do not send receipt identifiers to a different host or unsafe scheme."""

    def redirect_request(self, req, fp, code, msg, headers, newurl):
        target = urlsplit(urljoin(req.full_url, newurl))
        if (
            target.hostname != HOST
            or target.scheme not in {"https", "http"}
            or target.port is not None
            or target.username is not None
            or target.password is not None
        ):
            raise ValueError(f"Unexpected redirect: {newurl}")
        if urlsplit(req.full_url).scheme == "https" and target.scheme != "https":
            raise ValueError("HTTPS downgrade redirect rejected")
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def capture(opener, url: str, target: Path, *, api: bool = False) -> dict:
    headers = dict(HEADERS)
    if api:
        headers["Content-Type"] = "application/json"
    request = Request(url, headers=headers)
    started = datetime.now(timezone.utc).isoformat()
    try:
        response = opener.open(request, timeout=15)
    except HTTPError as error:
        response = error  # Error bodies are evidence too.
    with response:
        body = response.read()
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(body)
        target.with_suffix(".headers.txt").write_text(
            f"HTTP {response.status}\n{response.headers}", encoding="utf-8"
        )
        return {
            "requestedAtUtc": started,
            "requestUrl": url,
            "requestHeaders": headers,
            "finalUrl": response.url,
            "status": response.status,
            "responseHeaders": dict(response.headers.items()),
            "bodyFile": target.name,
            "bytes": len(body),
            "sha256": hashlib.sha256(body).hexdigest(),
        }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--qr", default=QR, help="Raw QR, including HTML entities")
    parser.add_argument("--output", type=Path, default=Path("build/ofd-research"))
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    print("Raw QR:", args.qr)
    args.output.joinpath("qr_raw.txt").write_text(args.qr + "\n", encoding="utf-8")
    uri = urlsplit(html.unescape(args.qr.strip()))
    if (
        uri.hostname != HOST
        or uri.scheme not in {"http", "https"}
        or uri.port is not None
        or uri.username is not None
        or uri.password is not None
    ):
        raise ValueError("Expected the consumer.oofd.kz QR URL")
    params = parse_qs(uri.query, keep_blank_values=True)
    if any(len(params.get(key, [])) != 1 or not params[key][0] for key in "ifst"):
        raise ValueError("QR must contain exactly one nonempty i, f, s, t")
    opener = build_opener(SameOriginRedirects())
    manifest = {"rawQr": args.qr, "decodedQr": html.unescape(args.qr), "responses": []}
    try:
        https = urlunsplit(uri._replace(scheme="https"))
        try:
            entry = capture(opener, https, args.output / "consumer.html")
        except URLError as error:
            manifest["httpsError"] = str(error)
            entry = capture(
                opener, urlunsplit(uri._replace(scheme="http")), args.output / "consumer.html"
            )
        manifest["responses"].append(entry)
        api = "https://" + HOST + API_PATH + "?" + urlencode(
            {key: params[key][0] for key in ("f", "i", "s", "t")}
        )
        manifest["responses"].append(
            capture(opener, api, args.output / "ticket.json", api=True)
        )
    finally:
        args.output.joinpath("provenance.json").write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
    for response in manifest["responses"]:
        print(response["status"], response["bodyFile"], response["sha256"])


if __name__ == "__main__":
    main()
