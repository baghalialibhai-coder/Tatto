// lib/services/messaging/whatsapp_service.dart
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static const String _apiUrl = 'https://api.whatsapp.com/send';

  static Future<void> sendMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final url = Uri.parse(
        '$_apiUrl?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw Exception('Could not launch WhatsApp');
      }
    } catch (e) {
      throw Exception('Failed to send WhatsApp message: $e');
    }
  }

  static String formatMessage({
    required String customerName,
    required String service,
    required String artist,
    required double amount,
    required String date,
    required String time,
    required String aftercareLink,
  }) {
    return '''
Hi $customerName,

Thank you for choosing The Temple of Tattooz!

Here are your service details:
- Service: $service
- Artist: $artist
- Amount: ₹$amount
- Date: $date
- Time: $time

Please follow the aftercare instructions carefully for best results.
Aftercare Guide: $aftercareLink

Thank you!
The Temple of Tattooz
''';
  }

  static String formatAftercareMessage({
    required String customerName,
    required String serviceType,
  }) {
    return '''
Hi $customerName,

Here are your aftercare instructions for $serviceType:

1. Keep the area clean and dry for the first 24 hours
2. Wash gently with mild soap and water
3. Apply a thin layer of aftercare ointment
4. Avoid direct sunlight for 2 weeks
5. Do not scratch or pick the area

For any questions, contact us at +91-XXXXXXXXXX

The Temple of Tattooz
''';
  }

  static Future<void> sendConsentConfirmation({
    required String phoneNumber,
    required String customerName,
    required String service,
    required String artist,
    required double amount,
    required String date,
    required String time,
  }) async {
    final message = formatMessage(
      customerName: customerName,
      service: service,
      artist: artist,
      amount: amount,
      date: date,
      time: time,
      aftercareLink: 'https://myapp.temple.com/aftercare',
    );

    await sendMessage(
      phoneNumber: phoneNumber,
      message: message,
    );
  }
}