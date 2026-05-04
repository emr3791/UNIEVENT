// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/event.dart';

// Small Y-rotation transition used for flip effect
class RotationYTransition extends StatelessWidget {
  final Animation<double> turns;
  final Widget child;
  const RotationYTransition(
      {Key? key, required this.turns, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: turns,
      builder: (context, _) {
        final angle = turns.value * math.pi;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}

// Input formatters
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final index = i + 1;
      if (index % 4 == 0 && index != digits.length) buffer.write(' ');
    }
    final formatted = buffer.toString();
    return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length));
  }
}

class ExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll('/', '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    String result = digits;
    if (digits.length >= 3) {
      result = '${digits.substring(0, 2)}/${digits.substring(2)}';
    } else if (digits.length >= 2) {
      result = digits.substring(0, 2);
    }
    return TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length));
  }
}

class LettersOnlyFormatter extends TextInputFormatter {
  final RegExp _reg = RegExp(r"[a-zA-ZğüşöçıİĞÜŞÖÇ ]");
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered =
        newValue.text.split('').where((c) => _reg.hasMatch(c)).join();
    return TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length));
  }
}

class PaymentScreen extends StatefulWidget {
  final Event event;
  const PaymentScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  int _quantity = 1;
  String _paymentMethod = 'credit_card';
  bool _agreeToTerms = false;
  bool _isProcessing = false;

  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpireController = TextEditingController();
  final _cardCvvController = TextEditingController();

  final FocusNode _cvvFocus = FocusNode();
  final FocusNode _expireFocus = FocusNode();
  bool _showBackOfCard = false;

  late final AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));

    _cvvFocus.addListener(() {
      if (_cvvFocus.hasFocus) {
        setState(() {
          _showBackOfCard = true;
          _flipController.forward();
        });
      } else {
        setState(() {
          _showBackOfCard = false;
          _flipController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _cardExpireController.dispose();
    _cardCvvController.dispose();
    _cvvFocus.dispose();
    _expireFocus.dispose();
    _flipController.dispose();
    super.dispose();
  }

  double get _totalPrice => (widget.event.price ?? 0) * _quantity;

  bool _validateForm() {
    if (_quantity < 1) {
      _showError('Lütfen en az 1 bilet seçin');
      return false;
    }
    if (!_agreeToTerms) {
      _showError('Lütfen şart ve koşulları kabul edin');
      return false;
    }
    if (_paymentMethod.contains('card')) {
      if (_cardNameController.text.isEmpty ||
          _cardNumberController.text.isEmpty ||
          _cardExpireController.text.isEmpty ||
          _cardCvvController.text.isEmpty) {
        _showError('Lütfen tüm kart bilgilerini girin');
        return false;
      }
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  Future<void> _processPayment() async {
    if (!_validateForm()) return;
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Ödeme Başarılı!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text('$_quantity adet bilet satın aldınız',
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('Biletleriniz e-postanıza gönderilmiştir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1)),
              child: const Text('Ana Sayfaya Dön',
                  style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }
    setState(() => _isProcessing = false);
  }

  Widget _buildCardFront(BuildContext context) {
    final theme = Theme.of(context);
    final rawDigits = _cardNumberController.text.replaceAll(' ', '');
    String masked;
    if (rawDigits.isEmpty) {
      masked = 'XXXX XXXX XXXX XXXX';
    } else if (rawDigits.length >= 4) {
      final last4 = rawDigits.substring(rawDigits.length - 4);
      masked = '•••• •••• •••• $last4';
    } else {
      final groups = <String>[];
      for (var i = 0; i < rawDigits.length; i += 4) {
        groups.add(rawDigits.substring(i, (i + 4).clamp(0, rawDigits.length)));
      }
      while (groups.length < 4) {
        groups.add('••••');
      }
      masked = groups.join(' ');
    }
    final name = _cardNameController.text.isEmpty
        ? 'KART SAHİBİ'
        : _cardNameController.text.toUpperCase();
    final expiry = _cardExpireController.text.isEmpty
        ? 'AA/YY'
        : _cardExpireController.text;    return Container(
      width: 320,
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [
          const Color(0xFF6D5AFE),
          theme.primaryColor.withAlpha((0.9 * 255).round())
        ]),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha((0.15 * 255).round()),
              blurRadius: 12,
              offset: const Offset(0, 8))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 48, height: 32, color: Colors.white24)
            ]),
            Text(masked,
                style: const TextStyle(
                    letterSpacing: 2,
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(name, style: const TextStyle(color: Colors.white)),
              Text(expiry, style: const TextStyle(color: Colors.white))
            ])
          ]),
    );
  }

  Widget _buildCardBack(BuildContext context) {
    final theme = Theme.of(context);
    final cvv =
        _cardCvvController.text.isEmpty ? 'CVV' : _cardCvvController.text;
    final cvvVisible = _showBackOfCard;    return Container(
      width: 320,
      height: 190,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.grey[900],
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha((0.15 * 255).round()),
                blurRadius: 12,
                offset: const Offset(0, 8))
          ]),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 40, color: Colors.black87),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Container(height: 36, color: Colors.white54)),
          const SizedBox(width: 12),
          Container(
              width: 60,
              height: 36,
              color: Colors.white,
              child: Center(child: Text(cvvVisible ? cvv : '•••')))
        ])
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {    return Scaffold(
      appBar: AppBar(
          title: const Text('Bilet Satın Al'),
          backgroundColor: const Color(0xFF6366F1),
          elevation: 0),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Event Summary
          Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF6366F1).withAlpha((0.05 * 255).round()),
              child: Row(children: [
                Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200]),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                            widget.event.imageUrl ??
                                'https://via.placeholder.com/80',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.event,
                                    color: Color(0xFF6366F1))))),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(widget.event.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Text(
                          'Fiyat: ₺${widget.event.price?.toStringAsFixed(2) ?? "0.00"}',
                          style: const TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w600))
                    ]))
              ])),

          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Animated Card Preview
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  transitionBuilder: (child, anim) =>
                      RotationYTransition(turns: anim, child: child),
                  child: _showBackOfCard
                      ? _buildCardBack(context)
                      : _buildCardFront(context),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Bilet Adedi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300] ?? Colors.grey),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null),
                  Expanded(
                      child: Center(
                          child: Text('$_quantity',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)))),
                  IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => _quantity++)),
                ]),
              ),

              const SizedBox(height: 24),
              const Text('Ödeme Yöntemi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300] ?? Colors.grey),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(children: [
                  _buildPaymentOption('credit_card', 'Kredi Kartı'),
                  const Divider(height: 0),
                  _buildPaymentOption('debit_card', 'Banka Kartı'),
                  const Divider(height: 0),
                  _buildPaymentOption('wallet', 'E-Cüzdan'),
                ]),
              ),

              const SizedBox(height: 24),

              if (_paymentMethod.contains('card'))
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Kart Bilgileri',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _cardNameController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp('[a-zA-ZğüşöçıİĞÜŞÖÇ ]')),
                        LengthLimitingTextInputFormatter(26),
                        LettersOnlyFormatter()
                      ],
                      decoration: InputDecoration(
                          hintText: 'Kart Sahibinin Adı',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)))),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _cardNumberController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        CardNumberInputFormatter()
                      ],
                      decoration: InputDecoration(
                          hintText: 'Kart Numarası',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8))),
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: TextField(
                          controller: _cardExpireController,
                          focusNode: _expireFocus,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            ExpiryInputFormatter()
                          ],
                          onChanged: (v) {
                            if (v.replaceAll('/', '').length >= 4) {
                              _cvvFocus.requestFocus();
                            }
                          },
                          decoration: InputDecoration(
                              hintText: 'AA/YY',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: TextField(
                            controller: _cardCvvController,
                            focusNode: _cvvFocus,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4)
                            ],
                            decoration: InputDecoration(
                                hintText: 'CVV',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            keyboardType: TextInputType.number,
                            onTap: () {
                              setState(() => _showBackOfCard = true);
                              _flipController.forward();
                            },
                            onChanged: (v) {
                              if (v.isNotEmpty) {
                                setState(() => _showBackOfCard = true);
                                _flipController.forward();
                              }
                            },
                            onEditingComplete: () {
                              setState(() => _showBackOfCard = false);
                              _flipController.reverse();
                            })),
                  ]),
                  const SizedBox(height: 24),
                ]),

              Row(children: [
                Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) =>
                        setState(() => _agreeToTerms = value ?? false),
                    activeColor: const Color(0xFF6366F1)),
                const Expanded(
                    child: Text('Şart ve koşulları kabul ediyorum',
                        style: TextStyle(fontSize: 12)))
              ]),

              const SizedBox(height: 24),

              Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFF6366F1)
                          .withAlpha((0.05 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF6366F1)
                              .withAlpha((0.2 * 255).round()))),
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Birim Fiyat:'),
                          Text(
                              '₺${widget.event.price?.toStringAsFixed(2) ?? "0.00"}')
                        ]),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [const Text('Adet:'), Text('$_quantity')]),
                    const Divider(height: 16),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Toplam:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('₺${_totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6366F1)))
                        ]),
                  ])),

              const SizedBox(height: 24),

              SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white)))
                          : const Text('Ödemeyi Tamamla',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)))),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label) {
    return RadioListTile<String>(
        value: value,
        groupValue: _paymentMethod,
        onChanged: (String? newValue) {
          if (newValue != null) setState(() => _paymentMethod = newValue);
        },
        title: Text(label),
        activeColor: const Color(0xFF6366F1));
  }
}
