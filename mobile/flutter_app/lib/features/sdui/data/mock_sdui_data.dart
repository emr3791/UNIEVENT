// Mock Server-Driven UI response payload for a specialized "Club Mini App"
final Map<String, dynamic> mockClubAppJson = {
  "appId": "tech_club_01",
  "theme": {
    "primaryColor": "#00FFCC",
    "backgroundColor": "#0F0F13",
    "fontFamily": "Poppins"
  },
  "layout": [
    {
      "type": "header",
      "properties": {
        "title": "Teknoloji ve İnovasyon Kulübü",
        "subtitle": "Kampüsün Geleceği",
        "imageUrl": "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=1000&auto=format&fit=crop"
      }
    },
    {
      "type": "section_title",
      "properties": {
        "text": "Yaklaşan Etkinlikler"
      }
    },
    {
      "type": "slider",
      "properties": {
        "items": [
          {
            "imageUrl": "https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=800&auto=format&fit=crop",
            "title": "Yapay Zeka Zirvesi"
          },
          {
            "imageUrl": "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=800&auto=format&fit=crop",
            "title": "Hackathon 2024"
          }
        ]
      }
    },
    {
      "type": "section_title",
      "properties": {
        "text": "Kulübe Üye Ol"
      }
    },
    {
      "type": "input",
      "properties": {
        "placeholder": "Öğrenci Email Adresi",
        "icon": "email"
      }
    },
    {
      "type": "button",
      "properties": {
        "text": "Başvuruyu Gönder",
        "action": "submit_form"
      }
    }
  ]
};
