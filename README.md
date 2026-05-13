# UNIEVENTNEW
unireposu
## Week 1
- Firebase project created
- Firestore Database started in Test Mode

## Week 2
- Users collection created (10 mock users)
- Universities collection created (10 mock universities)
- Events collection created (10 mock events)
- external_allowed boolean field added

## Week 3 - QA (Data Type Validation)

- Checked all collections for correct data types
- Verified Timestamp fields (date, created_at)
- Verified Boolean field (external_allowed)
- Fixed string/number mismatches if any
- Ensured founded_year is Number

## Week 5 - AI Data Format

AI tarafından üretilecek etkinlik verileri aşağıdaki JSON formatında olmalıdır:

{
  "title": "Etkinlik adı",
  "description": "Etkinlik açıklaması",
  "university": "Üniversite adı",
  "date": "YYYY-MM-DDTHH:MM:SSZ",
  "external_allowed": true
}

Kurallar:

- title → String
- description → String
- university → String
- date → ISO tarih formatı
- external_allowed → Boolean (true veya false)

## Week 6 - Data Cleaning

AI tarafından oluşturulan veriler kontrol edildi.

Kontrol edilen koleksiyonlar:
- users
- universities
- events

Kontrol edilen noktalar:
- Türkçe karakter encoding hataları (Ã¼, ÅŸ, Ã¶ vb.)
- Metin alanlarının doğruluğu

Sonuç:
Herhangi bir bozuk karakter veya encoding hatası bulunmadı. 
Veriler UTF-8 formatında doğru şekilde saklanmaktadır.

## Week 7 - User Schema Update

- Added interests field to users collection
- interests defined as Array
- Each user has multiple interest values

## Week 8 - Firestore Indexing

- Created composite index for events collection
- Fields: university, external_allowed
- Enabled efficient querying for multiple filters