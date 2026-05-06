# ShopRite Python Recommender

This local service recommends products from the user's recent search history.
It uses only the Python standard library.

Run it before starting Flutter:

```powershell
python python_recommender\recommendation_server.py
```

The Flutter app calls:

```text
http://127.0.0.1:8787/recommend
```

For Android emulator builds, pass the host machine URL:

```powershell
flutter run --dart-define=RECOMMENDER_URL=http://10.0.2.2:8787/recommend
```

The request body is:

```json
{
  "limit": 8,
  "searches": ["sneakers", "bags"],
  "products": []
}
```

The response body is:

```json
{
  "recommendations": ["shoe-01", "bag-04"]
}
```
