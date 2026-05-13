"""Basit scraper iskeleti - örnek amaçlı.
Gerçek scraping yapmadan önce robots.txt ve ilgili sitelerin kullanım koşullarını kontrol edin.
"""

import requests
from bs4 import BeautifulSoup
import json
from pathlib import Path
import firebase_admin
from firebase_admin import credentials, firestore

def categorize_event(description):
    description = description.lower()

    # Teknoloji
    if any(word in description for word in ["yazılım", "hackathon", "ai", "yapay zeka", "kodlama", "startup", "teknoloji"]):
        return "Teknoloji"

    # Eğitim
    elif any(word in description for word in ["eğitim", "workshop", "seminer", "ders", "kurs", "konferans"]):
        return "Eğitim"

    # Sanat
    elif any(word in description for word in ["konser", "müzik", "tiyatro", "sergi", "sanat"]):
        return "Sanat"

    # Eğlence
    elif any(word in description for word in ["festival", "parti", "eğlence", "etkinlik", "gece"]):
        return "Eğlence"

    # Spor
    elif any(word in description for word in ["futbol", "basketbol", "turnuva", "spor"]):
        return "Spor"

    else:
        return "Diğer"
    
DATA_DIR = Path(__file__).resolve().parents[1] / 'data' / 'raw'
DATA_DIR.mkdir(parents=True, exist_ok=True)


def fetch(url, timeout=10):
    resp = requests.get(url, timeout=timeout)
    resp.raise_for_status()
    return resp.text


def parse_events_from_html(html):
    soup = BeautifulSoup(html, 'lxml')
    # Placeholder parsing, her üniversite için ayrı parser yazılmalı
    events = []
    for item in soup.select('.event, .duyuru')[:5]:
        title = item.get_text(strip=True)
        description = title
        category = categorize_event(description)

        events.append({
             'title': title,
             'description': description,
             'category': category
        })

    return events


def save_raw(site_key, data):
    out = DATA_DIR / f'{site_key}.json'
    with out.open('w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
def save_to_firestore(events):
    cred = credentials.Certificate("ai/python/serviceAccountKey.json")

    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)

    db = firestore.client()

    for event in events:
        db.collection("events").add(event)

    print(f"uploaded {len(events)} events to Firestore")

def main():
    events = [
        {
            "title": "Hackathon 48 Saat",
            "description": "48 saatlik yazılım geliştirme yarışması",
            "category": categorize_event("48 saatlik yazılım geliştirme yarışması")
        },
        {
            "title": "Girişimcilik Workshop",
            "description": "Startup kurma ve yatırım alma süreci",
            "category": categorize_event("Startup kurma ve yatırım alma süreci")
        },
        {
            "title": "Bahar Konseri",
            "description": "Canlı müzik ve konser etkinliği",
            "category": categorize_event("Canlı müzik ve konser etkinliği")
        }
    ]

    save_raw("test_events", events)
    save_to_firestore(events)
    print(f"saved {len(events)} events for test_events")
    
if __name__ == '__main__':
    main()
