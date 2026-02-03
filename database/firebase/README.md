# Firebase Notları

Eğer Firebase tercih edilirse:
- Firestore etkinlik koleksiyonu (document per event)
- Authentication: Google / Email
- Functions: zamanlanmış scraping tetikleyicileri (tercihen Cloud Run ile çalışan scrapers önerilir)

Gizli anahtarlar `secrets` veya `.env` içinde saklanmalı, repo'ya koyulmamalıdır.
