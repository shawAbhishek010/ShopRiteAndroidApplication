from __future__ import annotations

import base64
import json
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any

from razorpay_server_config import HOST, PORT, RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET

RAZORPAY_ORDERS_URL = "https://api.razorpay.com/v1/orders"


class RazorpayTestHandler(BaseHTTPRequestHandler):
    server_version = "ShopRiteRazorpayTest/1.0"

    def do_OPTIONS(self) -> None:
        self._send_json({"ok": True})

    def do_GET(self) -> None:
        if self.path == "/health":
            self._send_json({"ok": True, "service": "shoprite-razorpay-test"})
            return
        self._send_json({"error": "not found"}, status=404)

    def do_POST(self) -> None:
        key_id = RAZORPAY_KEY_ID.strip()
        key_secret = RAZORPAY_KEY_SECRET.strip()
        if not key_id or not key_secret:
            self._send_json(
                {
                    "error": (
                        "Set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET "
                        "environment variables with Test Mode keys."
                    )
                },
                status=500,
            )
            return

        if self.path == "/create-order":
            self._handle_create_order(key_id=key_id, key_secret=key_secret)
            return

        self._send_json({"error": "not found"}, status=404)

    def _handle_create_order(self, *, key_id: str, key_secret: str) -> None:
        try:
            content_length = int(self.headers.get("Content-Length", "0"))
            raw_body = self.rfile.read(content_length).decode("utf-8")
            payload = json.loads(raw_body or "{}")
            amount = int(payload.get("amount") or 0)
            currency = str(payload.get("currency") or "INR")
            receipt = str(payload.get("receipt") or "shoprite_test_receipt")
            notes = dict(payload.get("notes") or {})
            if amount <= 0:
                self._send_json({"error": "amount must be positive"}, status=400)
                return

            order = create_razorpay_order(
                key_id=key_id,
                key_secret=key_secret,
                amount=amount,
                currency=currency,
                receipt=receipt,
                notes=notes,
            )
            self._send_json(order)
        except (TypeError, ValueError, json.JSONDecodeError) as error:
            self._send_json({"error": str(error)}, status=400)
        except urllib.error.HTTPError as error:
            body = error.read().decode("utf-8", errors="replace")
            self._send_json(
                {"error": "Razorpay order creation failed", "details": body},
                status=error.code,
            )
        except urllib.error.URLError as error:
            self._send_json({"error": str(error)}, status=502)

    def log_message(self, format: str, *args: Any) -> None:
        return

    def _send_json(self, payload: dict[str, Any], status: int = 200) -> None:
        encoded = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(encoded)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
        self.end_headers()
        self.wfile.write(encoded)


def create_razorpay_order(
    *,
    key_id: str,
    key_secret: str,
    amount: int,
    currency: str,
    receipt: str,
    notes: dict[str, Any],
) -> dict[str, Any]:
    body = json.dumps(
        {
            "amount": amount,
            "currency": currency,
            "receipt": receipt,
            "notes": notes,
        }
    ).encode("utf-8")
    token = base64.b64encode(f"{key_id}:{key_secret}".encode("utf-8")).decode(
        "ascii"
    )
    request = urllib.request.Request(
        RAZORPAY_ORDERS_URL,
        data=body,
        headers={
            "Authorization": f"Basic {token}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=15) as response:
        response_body = response.read().decode("utf-8")
    return json.loads(response_body)

def main() -> None:
    server = ThreadingHTTPServer((HOST, PORT), RazorpayTestHandler)
    print(f"ShopRite Razorpay test server running at http://{HOST}:{PORT}")
    server.serve_forever()


if __name__ == "__main__":
    main()
