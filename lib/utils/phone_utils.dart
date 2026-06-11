import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneUtils {
  static const _channel = MethodChannel('com.itl.flutter_contacts_app/phone');
  static Future<void> call(String phone) async {
    final number = phone.replaceAll(RegExp(r'\s'), '');

    if (!kIsWeb && Platform.isAndroid) {
      final status = await Permission.phone.request();
      if (status.isGranted) {
        try {
          await _channel.invokeMethod('directCall', {'number': number});
          return;
        } catch (_) {}
      }
      final uri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(uri)) await launchUrl(uri);
      return;
    }

    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> sms(String phone) async {
    final uri = Uri(scheme: 'sms', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> email(String address) async {
    final uri = Uri(scheme: 'mailto', path: address);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
