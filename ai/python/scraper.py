"""Basit scraper iskeleti - örnek amaçlı.
Gerçek scraping yapmadan önce robots.txt ve ilgili sitelerin kullanım koşullarını kontrol edin.
"""
import requests
from bs4 import BeautifulSoup
import json
from pathlib import Path

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
        events.append({'title': title})
    return events


def save_raw(site_key, data):
    out = DATA_DIR / f'{site_key}.json'
    with out.open('w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def main():
    sample_sites = {
        'example_university': 'https://example.com/events'
    }
    for k, url in sample_sites.items():
        try:
            html = fetch(url)
            events = parse_events_from_html(html)
            save_raw(k, events)
            print(f'Saved {len(events)} events for {k}')
        except Exception as e:
            print('Error fetching', url, e)


if __name__ == '__main__':
    main()
