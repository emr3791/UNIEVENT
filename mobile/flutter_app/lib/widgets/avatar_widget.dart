import 'dart:io';

import 'package:flutter/material.dart';
import '../models/user.dart';

class AvatarWidget extends StatelessWidget {
  final User user;
  final double size;
  final bool showBorder;

  const AvatarWidget({
    Key? key,
    required this.user,
    this.size = 56,
    this.showBorder = false,
  }) : super(key: key);

  Color _skinToneColor(String? tone) {
    switch (tone) {
      case 'light':
        return const Color(0xFFf7d6b2);
      case 'medium':
        return const Color(0xFFd4a97a);
      case 'dark':
        return const Color(0xFF8d5538);
      case 'olive':
        return const Color(0xFFb99b6b);
      case 'brown':
        return const Color(0xFFa67c52);
      default:
        return const Color(0xFFd4a97a);
    }
  }

  String _getAvatarEmoji() {
    String base;
    if (user.gender == 'female') {
      base = '👩';
    } else {
      if (user.avatarFacialHair == 'beard') {
        base = '🧔';
      } else {
        base = '👨';
      }
    }

    String skinTone = '';
    switch (user.avatarSkinTone) {
      case 'light': skinTone = '\u{1F3FB}'; break;
      case 'medium': skinTone = '\u{1F3FD}'; break;
      case 'dark': skinTone = '\u{1F3FF}'; break;
      default: skinTone = ''; break; // Default yellow/neutral
    }

    String hairStyle = '';
    if (base != '🧔') {
      switch (user.avatarHairStyle) {
        case 'curly': hairStyle = '\u{200D}\u{1F9B1}'; break;
        case 'white': hairStyle = '\u{200D}\u{1F9B3}'; break;
        case 'bald': hairStyle = '\u{200D}\u{1F9B2}'; break;
        default: hairStyle = ''; break;
      }
    }
    
    return base + skinTone + hairStyle;
  }

  @override
  Widget build(BuildContext context) {
    if (user.profileImage != null && user.profileImage!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(
          // ignore: unnecessary_null_comparison
          user.profileImage != null ? File(user.profileImage!) : File(''),
        ),
      );
    }

    final bgColor = _skinToneColor(user.avatarSkinTone);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: showBorder ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Center(
        child: Text(
          _getAvatarEmoji(),
          style: TextStyle(
            fontSize: size * 0.6,
          ),
        ),
      ),
    );
  }
}
