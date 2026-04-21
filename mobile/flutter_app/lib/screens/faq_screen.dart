import 'package:flutter/material.dart';

// ── Data model ──────────────────────────────────────────────────────────────
// To add more questions just append a new FaqItem to the list below.
class FaqItem {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});
}

const List<FaqItem> _faqs = [
  FaqItem(
    question: 'UniEventAI nedir?',
    answer:
    'UniEventAI, üniversite etkinliklerini keşfetmenizi, duyuruları takip etmenizi ve diğer öğrencilerle bağlantı kurmanızı sağlayan bir platformdur.',
  ),
  FaqItem(
    question: 'Etkinliklere nasıl katılabilirim?',
    answer:
    'Ana sayfada ilgilendiğiniz etkinliği bulun ve "Katıl" butonuna tıklayın. Katıldığınız etkinlikler profilinizde görüntülenir.',
  ),
  FaqItem(
    question: 'Bildirimler nasıl çalışır?',
    answer:
    'Katıldığınız etkinlikler için hatırlatıcılar ve yeni duyurular hakkında anlık bildirimler alırsınız. Bildirim ayarlarını Profil → Ayarlar ekranından değiştirebilirsiniz.',
  ),
  FaqItem(
    question: 'Şifremi unuttum, ne yapmalıyım?',
    answer:
    'Giriş ekranındaki "Şifremi Unuttum" bağlantısına tıklayın. Kayıtlı e-posta adresinize sıfırlama bağlantısı gönderilecektir.',
  ),
  FaqItem(
    question: 'Etkinlik oluşturabilir miyim?',
    answer:
    'Şu an yalnızca yetkili kulüp ve organizasyon temsilcileri etkinlik oluşturabilmektedir. Etkinlik eklemek için üniversitenizin öğrenci işleri birimiyle iletişime geçin.',
  ),
  // ── Buraya yeni soru-cevap ekleyin ─────────────────────────────────────────
  // FaqItem(
  //   question: 'Yeni sorunuz?',
  //   answer: 'Cevabınız buraya.',
  // ),
];

// ── Screen ───────────────────────────────────────────────────────────────────
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // Tracks which panel is open; null = all closed
  int? _openIndex;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _faqs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final faq = _faqs[index];
        final isOpen = _openIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isOpen
                ? const Color(0xFF6366F1).withOpacity(0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOpen
                  ? const Color(0xFF6366F1).withOpacity(0.4)
                  : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(
                    () => _openIndex = isOpen ? null : index,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            faq.question,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isOpen
                                  ? const Color(0xFF6366F1)
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: isOpen ? 0.5 : 0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isOpen
                                ? const Color(0xFF6366F1)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    // Answer (shown when open)
                    if (isOpen) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Text(
                        faq.answer,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}