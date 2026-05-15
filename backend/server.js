const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");
const bcrypt = require("bcrypt"); // Orijinal bcrypt
const { body, validationResult } = require("express-validator");

const app = express();

// --- GÜVENLİK 1: CORS POLİTİKASI ---
const allowedOrigins = [
  "http://localhost:3000",
  "http://localhost:5173",
];

const corsOptions = {
  origin: function (origin, callback) {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error("CORS policy violation: Bu adresten istek atılamaz."));
    }
  },
  methods: ["GET", "POST", "PUT", "DELETE"],
  credentials: true,
};

app.use(cors(corsOptions));
app.use(express.json());

// --- FIREBASE BAŞLATMA ---
if (!process.env.FIREBASE_KEY) {
  console.error("FIREBASE_KEY environment variable is missing.");
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(JSON.parse(process.env.FIREBASE_KEY)),
});

const db = admin.firestore();

// --- TEMEL UÇ NOKTA ---
app.get("/", (req, res) => {
  res.send("UNIEVENT Backend çalışıyor 🚀");
});

// --- ETKİNLİK (EVENTS) UÇLARI ---

// 1. Tüm etkinlikleri getir, filtrele (Üniversite ve Dışarıya Açıklık) veya isme göre ara
app.get("/api/events", async (req, res) => {
  try {
    const { search, university, external_allowed } = req.query;
    let eventsRef = db.collection("events");

    // Firebase Seviyesinde Filtreleme: ÜNİVERSİTE
    if (university) {
      eventsRef = eventsRef.where("university", "==", university);
    }
    
    // Firebase Seviyesinde Filtreleme: DIŞARIYA AÇIK MI?
    if (external_allowed !== undefined) {
      // URL'den gelen "true" veya "false" stringini gerçek boolean değere çeviriyoruz
      const isExternal = external_allowed === 'true';
      eventsRef = eventsRef.where("external_allowed", "==", isExternal);
    }

    const snapshot = await eventsRef.get();

    let events = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    // Node.js Seviyesinde İsim Arama (Search)
    if (search) {
      const searchLower = search.toLowerCase();
      events = events.filter((event) =>
        event.title.toLowerCase().includes(searchLower)
      );
    }

    res.json(events);
  } catch (error) {
    console.error("Error fetching events:", error);
    res.status(500).json({ error: "Etkinlikler getirilirken hata oluştu" });
  }
});

// 2. Sadece belirli bir etkinliğin detaylarını getir
app.get("/api/events/:id", async (req, res) => {
  try {
    const eventId = req.params.id;
    const doc = await db.collection("events").doc(eventId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: "Etkinlik bulunamadı" });
    }

    const eventData = {
      id: doc.id,
      ...doc.data(),
    };

    res.json(eventData);
  } catch (error) {
    console.error("Error fetching event details:", error);
    res.status(500).json({ error: "Hata oluştu" });
  }
});

// --- AUTH (KAYIT VE GİRİŞ) UÇLARI ---

const registerValidation = [
  body("fullName").trim().notEmpty().withMessage("İsim alanı boş bırakılamaz.").isLength({ min: 2 }).withMessage("İsim en az 2 karakter olmalıdır."),
  body("email").trim().isEmail().withMessage("Geçerli bir e-posta adresi giriniz.").normalizeEmail(),
  body("password").isLength({ min: 6 }).withMessage("Şifre en az 6 karakter olmalıdır.").matches(/\d/).withMessage("Şifre en az bir rakam içermelidir.")
];

app.post("/api/auth/register", registerValidation, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) { return res.status(400).json({ errors: errors.array() }); }

    const { fullName, email, password } = req.body;
    const usersRef = db.collection("users");
    const snapshot = await usersRef.where("email", "==", email).get();

    if (!snapshot.empty) { return res.status(400).json({ error: "Bu e-posta adresi zaten kullanımda." }); }

    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    const newUser = {
      fullName: fullName, email: email, password: hashedPassword,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    };

    const docRef = await usersRef.add(newUser);
    res.status(201).json({ message: "Kayıt başarıyla oluşturuldu", userId: docRef.id });

  } catch (error) {
    console.error("Kayıt hatası:", error);
    res.status(500).json({ error: "Kayıt işlemi sırasında bir hata oluştu." });
  }
});

const loginValidation = [
  body("email").isEmail().withMessage("Geçerli bir e-posta adresi giriniz.").normalizeEmail(),
  body("password").notEmpty().withMessage("Şifre alanı boş bırakılamaz.")
];

// 2. GİRİŞ YAP (Login) - JWT EKLENDİ
app.post("/api/auth/login", loginValidation, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password } = req.body;
    const usersRef = db.collection("users");
    const snapshot = await usersRef.where("email", "==", email).get();

    if (snapshot.empty) {
      return res.status(404).json({ error: "Bu e-posta adresine ait kullanıcı bulunamadı." });
    }

    let userData;
    let userId;
    snapshot.forEach(doc => {
      userId = doc.id;
      userData = doc.data();
    });

    const isPasswordValid = await bcrypt.compare(password, userData.password);

    if (!isPasswordValid) {
      return res.status(401).json({ error: "Hatalı şifre girdiniz." });
    }

    // --- JWT TOKEN OLUŞTURMA BÖLÜMÜ ---
    // Kullanıcının ID ve email bilgisini içeren, 7 gün geçerli bir dijital kart oluşturuyoruz.
    // Gerçek projelerde "super_gizli_anahtar" yerine process.env.JWT_SECRET kullanılır.
    const token = jwt.sign(
      { id: userId, email: userData.email }, 
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    // Yanıta token'ı da ekliyoruz
    res.status(200).json({ 
      message: "Giriş başarılı", 
      token: token, // Flutter ekibi bu token'ı cihaz hafızasına kaydedecek
      user: { id: userId, fullName: userData.fullName, email: userData.email } 
    });

  } catch (error) {
    console.error("Giriş hatası:", error);
    res.status(500).json({ error: "Giriş işlemi sırasında bir hata oluştu." });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, "0.0.0.0", () => { console.log(`Server running on port ${PORT}`); });