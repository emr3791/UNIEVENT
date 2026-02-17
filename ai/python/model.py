"""Öneri motoru iskeleti - baseline.
Bu dosya daha sonra kullanıcı etkileşimleri ve içerik tabanlı özniteliklerle doldurulacak.
"""
import json


class Recommender:
    def __init__(self):
        # placeholder: load models/indices
        pass

    def recommend_for_user(self, user_profile, events, k=10):
        # Basit: aynı şehirdeki etkinlikleri üst sıraya koy
        city = user_profile.get('city')
        ranked = sorted(events, key=lambda e: 0 if e.get('location') == city else 1)
        return ranked[:k]


if __name__ == '__main__':
    rec = Recommender()
    sample_user = {'city': 'İstanbul'}
    sample_events = [{'title': 'X', 'location': 'İstanbul'}, {'title': 'Y', 'location': 'Ankara'}]
    print(rec.recommend_for_user(sample_user, sample_events))
