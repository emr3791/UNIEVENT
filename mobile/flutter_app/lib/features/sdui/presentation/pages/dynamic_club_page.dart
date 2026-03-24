import 'package:flutter/material.dart';
import '../../utils/sdui_parser.dart';
import '../../data/mock_sdui_data.dart';
import '../../../../core/utils/haptic_utils.dart';

class DynamicClubPage extends StatelessWidget {
  const DynamicClubPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine dynamic primary color from the JSON schema if applicable
    Color primaryColor = Theme.of(context).primaryColor;
    try {
      final themeHex = mockClubAppJson['theme']['primaryColor'] as String;
      primaryColor = Color(int.parse(themeHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      debugPrint('Theme parse error: $e');
    }

    final layoutData = mockClubAppJson['layout'] as List<dynamic>;
    final widgets = SduiParser.parseLayout(layoutData, primaryColor);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            HapticUtils.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets,
        ),
      ),
    );
  }
}
