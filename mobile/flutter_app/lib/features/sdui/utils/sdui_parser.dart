import 'package:flutter/material.dart';

class SduiParser {
  /// Parses a given list of JSON widget nodes into Flutter Widgets
  static List<Widget> parseLayout(List<dynamic> layoutData, Color primaryColor) {
    return layoutData.map<Widget>((node) {
      final type = node['type'] as String;
      final properties = node['properties'] as Map<String, dynamic>;

      switch (type) {
        case 'header':
          return _buildHeader(properties);
        case 'section_title':
          return _buildSectionTitle(properties);
        case 'slider':
          return _buildSlider(properties);
        case 'input':
          return _buildInput(properties, primaryColor);
        case 'button':
          return _buildButton(properties, primaryColor);
        default:
          return const SizedBox.shrink(); // Unknown type fallback
      }
    }).toList();
  }

  static Widget _buildHeader(Map<String, dynamic> props) {
    return Container(
      width: double.infinity,
      height: 250,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: DecorationImage(
          image: NetworkImage(props['imageUrl']),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withAlpha(153), BlendMode.darken),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            props['title'],
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            props['subtitle'],
            style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 16),
          )
        ],
      ),
    );
  }

  static Widget _buildSectionTitle(Map<String, dynamic> props) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Text(
        props['text'],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  static Widget _buildSlider(Map<String, dynamic> props) {
    final items = props['items'] as List<dynamic>;
    
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(item['imageUrl']),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withAlpha(102), BlendMode.darken),
              ),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(16),
            child: Text(
              item['title'],
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildInput(Map<String, dynamic> props, Color primaryColor) {
    IconData iconData = Icons.text_fields;
    if (props['icon'] == 'email') iconData = Icons.email;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: props['placeholder'],
          prefixIcon: Icon(iconData, color: primaryColor),
          filled: true,
          fillColor: Colors.grey.withAlpha(26),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  static Widget _buildButton(Map<String, dynamic> props, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            // Mock Action
            debugPrint('Action Triggered: ${props['action']}');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            props['text'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
