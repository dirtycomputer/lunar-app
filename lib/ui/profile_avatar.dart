import 'package:flutter/material.dart';
import '../models/profile.dart';
import 'design.dart';

String catalogLanguageName(String code) =>
    const {
      'en': 'English',
      'zh': 'Chinese',
      'fr': 'French',
      'de': 'German',
      'es': 'Spanish',
      'it': 'Italian',
      'pt': 'Portuguese',
      'nl': 'Dutch',
      'sv': 'Swedish',
      'pl': 'Polish',
      'el': 'Greek',
      'tr': 'Turkish',
      'ja': 'Japanese',
      'ko': 'Korean',
      'hi': 'Hindi',
      'id': 'Indonesian',
      'fil': 'Filipino',
      'vi': 'Vietnamese',
      'th': 'Thai',
      'ms': 'Malay',
      'sw': 'Swahili',
      'ar': 'Arabic',
      'no': 'Norwegian',
      'uk': 'Ukrainian',
    }[code] ??
    code;

/// Synthetic catalog entries use initials, never somebody else's face.
class ProfileAvatar extends StatelessWidget {
  final Person person;
  final double width, height;
  const ProfileAvatar(this.person,
      {super.key, required this.width, required this.height});
  @override
  Widget build(BuildContext context) {
    if (person.image.startsWith('assets/')) {
      return Image.asset(person.image,
          width: width,
          height: height,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -.3));
    }
    var hash = 0;
    for (final c in person.id.codeUnits) {
      hash = (hash * 31 + c) & 0x7fffffff;
    }
    final index = hash % accentColors.length;
    final words = person.name.trim().split(RegExp(r'\s+'));
    final initials =
        words.take(2).map((w) => w.characters.first).join().toUpperCase();
    return Semantics(
        label: person.name,
        child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(color: accentTints[index]),
            alignment: Alignment.center,
            child: Text(initials,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                    fontSize: (width * .28).clamp(18, 64),
                    letterSpacing: -1,
                    fontWeight: FontWeight.w600,
                    color: accentColors[index]))));
  }
}
