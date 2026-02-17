"""Basit NLP yardımcı fonksiyonları - başlangıç.
Yer, tarih ve konu çıkarmada kullanılacak placeholder fonksiyonlar.
"""
import re
from datetime import datetime


def extract_date(text):
    # Çok basit örnek: YYYY-MM-DD pattern
    m = re.search(r"(20\d{2}-\d{2}-\d{2})", text)
    if m:
        return m.group(1)
    return None


def extract_location(text):
    # Yer tespiti için placeholder: üniversite veya salon kelimeleri
    if 'üniversite' in text.lower():
        return 'Üniversite'
    if 'salon' in text.lower():
        return 'Salon'
    return None


def classify_topic(text):
    # Basit anahtar kelime tabanlı sınıflandırma
    t = text.lower()
    if 'seminar' in t or 'seminer' in t:
        return 'Seminer'
    if 'konferans' in t or 'conference' in t:
        return 'Konferans'
    return 'Genel'
