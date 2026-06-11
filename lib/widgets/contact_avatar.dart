import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../utils/app_colors.dart';

class ContactAvatar extends StatelessWidget {
  final Contact contact;
  final double radius;
  final double fontSize;

  const ContactAvatar({
    super.key,
    required this.contact,
    this.radius = 28,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && contact.avatarPath != null) {
      final file = File(contact.avatarPath!);
      if (file.existsSync()) {
        return CircleAvatar(radius: radius, backgroundImage: FileImage(file));
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.avatarColor(contact.name),
      child: Text(
        contact.initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
