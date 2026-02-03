# UniEventAI — Proje Dokümanı

## Özet
UniEventAI, Türkiye genelindeki üniversitelerin etkinlik verilerini otomatik toplayıp öğrencilerin ilgi alanlarına göre kişiselleştirilmiş öneriler sunan mobil bir platformdur.

## Amaç & Hedefler
- Bilgi kirliliğini azaltmak ve etkinliklere erişimi kolaylaştırmak.
- Ulusal düzeyde üniversite etkinliklerini tek bir noktada toplamak.
- Kişiselleştirilmiş öneriler ile öğrenci katılımını artırmak.

## MVP (Minimum Viable Product)
- Temel scraper altyapısı (belirli sayıda üniversite için)
- Temel NLP ile etkinlik tarih/konu/yer sınıflandırması
- Flutter mobil uygulamasında etkinlik listesi ve filtreleme
- Kullanıcı ilgi alanlarına göre basit öneri düzeni

## Teknolojiler
- Flutter, Dart — Mobil uygulama
- Python — Scraper/NLP ve öneri motoru
- Node.js — API / Auth
- Firebase / MongoDB — Veri yönetimi

## Mimari (kısa)
1. Scraper pipeline (Python): sitelerden veri çek → ham veriyi `data/raw` kaydet
2. Processing (Python): temizleme, NLP sınıflandırması → `data/processed`
3. Backend (Node.js): API ve kullanıcı yönetimi
4. Mobil (Flutter): kullanıcı arayüzü ve öneri gösterimi

## Etik ve Yasal Notlar
- Web scraping yaparken hedef sitelerin robots.txt ve kullanım koşullarına uyulacak.
- Kişisel veri toplanmayacak; eğer toplanacaksa açık rıza alınacak ve GDPR/KVK uyumluluğu sağlanacak.

## İlk Yol Haritası (6 sprint önerisi)
1. Sprint: Proje altyapısı, temel scraper örnekleri (3-5 üniversite)
2. Sprint: Veri modeli, basit NLP etiketleme
3. Sprint: Backend API ve auth
4. Sprint: Flutter temel ekranlar (listeleme, filtre)
5. Sprint: Öneri motoru entegre, testler
6. Sprint: CI/CD, deployment ve test otomasyonları

---
