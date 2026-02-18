from bs4 import BeautifulSoup

with open("Duyurular.htm", "r", encoding="utf-8") as file:
    soup = BeautifulSoup(file.read(), "html.parser")

news_section = soup.select_one("section.news")

if not news_section:
    raise Exception("Announcements section not found")

items = news_section.select("a.item")

events = []

for item in items:
    title_el = item.select_one("span.subject")
    date_el = item.select_one("small.date")

    events.append({
        "title": title_el.get_text(strip=True) if title_el else None,
        "date": date_el.get_text(strip=True) if date_el else None,
        "url": item["href"]
    })

for e in events:
    print("Title:", e["title"])
    print("Date:", e["date"])
    print("URL:", e["url"])
    print("-" * 50)
