from __future__ import annotations

import json
import math
import os
import re
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any


TOKEN_PATTERN = re.compile(r"[a-z0-9]+")
STOP_WORDS = {
    "a",
    "an",
    "and",
    "for",
    "in",
    "of",
    "or",
    "the",
    "to",
    "with",
}
SYNONYMS = {
    "sneaker": {"shoe", "shoes", "trainer", "trainers"},
    "sneakers": {"shoe", "shoes", "trainer", "trainers"},
    "trainer": {"shoe", "shoes", "sneaker", "sneakers"},
    "trainers": {"shoe", "shoes", "sneaker", "sneakers"},
    "dress": {"dresses", "gown", "party"},
    "dresses": {"dress", "gown", "party"},
    "bag": {"bags", "backpack", "tote", "sling"},
    "bags": {"bag", "backpack", "tote", "sling"},
    "jacket": {"jackets", "coat", "outerwear"},
    "jackets": {"jacket", "coat", "outerwear"},
    "sock": {"socks", "liner", "cotton"},
    "socks": {"sock", "liner", "cotton"},
    "accessory": {"accessories", "watch", "necklace", "scarf", "belt"},
    "accessories": {"accessory", "watch", "necklace", "scarf", "belt"},
}


def tokenize(value: Any) -> list[str]:
    text = str(value or "").lower()
    return [
        token
        for token in TOKEN_PATTERN.findall(text)
        if len(token) > 1 and token not in STOP_WORDS
    ]


def expand_token(token: str) -> set[str]:
    return {token, *SYNONYMS.get(token, set())}


def build_user_profile(searches: list[str]) -> dict[str, float]:
    profile: dict[str, float] = {}
    for index, query in enumerate(searches):
        recency_weight = 1 / math.sqrt(index + 1)
        for token in tokenize(query):
            for expanded in expand_token(token):
                profile[expanded] = profile.get(expanded, 0.0) + recency_weight
    return profile


def score_product(product: dict[str, Any], profile: dict[str, float]) -> float:
    name_tokens = tokenize(product.get("name"))
    category_tokens = tokenize(product.get("category"))
    description_tokens = tokenize(product.get("description"))

    score = 0.0
    for token in name_tokens:
        score += profile.get(token, 0.0) * 4.0
    for token in category_tokens:
        score += profile.get(token, 0.0) * 5.5
    for token in description_tokens:
        score += profile.get(token, 0.0) * 1.5

    rating = float(product.get("rating") or 0)
    discount = float(product.get("discount") or 0)
    views = float(product.get("views") or 0)
    cart_adds = float(product.get("addToCartCount") or 0)
    stock = int(product.get("stock") or 0)

    score += rating
    score += min(discount, 40.0) / 20.0
    score += math.log1p(max(views, 0.0)) * 0.15
    score += math.log1p(max(cart_adds, 0.0)) * 0.25
    if stock <= 0:
        score -= 8.0

    return score


def recommend(payload: dict[str, Any]) -> list[str]:
    products = payload.get("products") or []
    searches = payload.get("searches") or []
    limit = int(payload.get("limit") or 8)
    profile = build_user_profile([str(query) for query in searches])

    if not profile:
        ranked = sorted(
            products,
            key=lambda item: (
                float(item.get("rating") or 0),
                float(item.get("views") or 0),
                float(item.get("discount") or 0),
            ),
            reverse=True,
        )
    else:
        ranked = sorted(
            products,
            key=lambda item: score_product(item, profile),
            reverse=True,
        )

    return [str(item.get("id")) for item in ranked[:limit] if item.get("id")]


class RecommendationHandler(BaseHTTPRequestHandler):
    server_version = "ShopRiteRecommender/1.0"

    def do_OPTIONS(self) -> None:
        self._send_json({"ok": True})

    def do_GET(self) -> None:
        if self.path == "/health":
            self._send_json({"ok": True, "service": "shoprite-recommender"})
            return
        self._send_json({"error": "not found"}, status=404)

    def do_POST(self) -> None:
        if self.path != "/recommend":
            self._send_json({"error": "not found"}, status=404)
            return

        try:
            content_length = int(self.headers.get("Content-Length", "0"))
            body = self.rfile.read(content_length).decode("utf-8")
            payload = json.loads(body or "{}")
            recommendations = recommend(payload)
            self._send_json({"recommendations": recommendations})
        except (TypeError, ValueError, json.JSONDecodeError) as error:
            self._send_json({"error": str(error)}, status=400)

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


def main() -> None:
    host = os.environ.get("RECOMMENDER_HOST", "127.0.0.1")
    port = int(os.environ.get("RECOMMENDER_PORT", "8787"))
    server = ThreadingHTTPServer((host, port), RecommendationHandler)
    print(f"ShopRite recommender running at http://{host}:{port}")
    server.serve_forever()


if __name__ == "__main__":
    main()
