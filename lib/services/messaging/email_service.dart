// // lib/services/messaging/email_service.dart
// import 'dart:io';
// import 'package:mailer/mailer.dart';
// import 'package:mailer/smtp_server/gmail.dart';
//
// class EmailService {
//   final String _email = 'your-email@gmail.com';
//   final String _password = 'your-password';
//
//   Future<bool> sendEmail({
//     required String to,
//     required String subject,
//     required String body,
//     List<File>? attachments,
//   }) async {
//     try {
//       final smtpServer = gmail(_email, _password);
//
//       final message = Message()
//         ..from = Address(_email, 'The Temple of Tattooz')
//         ..recipients.add(to)
//         ..subject = subject
//         ..text = body;
//
//       if (attachments != null && attachments.isNotEmpty) {
//         for (final file in attachments) {
//           message.attachments.add(
//             Attachment(file: file),
//           );
//         }
//       }
//
//       await send(message, smtpServer);
//       return true;
//     } catch (e) {
//       print('Email send failed: $e');
//       return false;
//     }
//   }
//
//   Future<bool> sendInvoiceEmail({
//     required String to,
//     required String customerName,
//     required String invoiceId,
//     required File pdfFile,
//   }) async {
//     final subject = 'Invoice #$invoiceId from The Temple of Tattooz';
//     final body = '''
// Dear $customerName,
//
// Thank you for choosing The Temple of Tattooz!
//
// Please find your invoice attached for reference.
//
// Best regards,
// The Temple of Tattooz
// ''';
//
//     return sendEmail(
//       to: to,
//       subject: subject,
//       body: body,
//       attachments: [pdfFile],
//     );
//   }
//
//   Future<bool> sendAftercareEmail({
//     required String to,
//     required String customerName,
//     required String serviceType,
//   }) async {
//     final subject = 'Aftercare Instructions - The Temple of Tattooz';
//     final body = '''
// Dear $customerName,
//
// Thank you for getting your $serviceType at The Temple of Tattooz!
//
// Please follow these aftercare instructions carefully:
//
// 1. Keep the area clean and dry for the first 24 hours.
// 2. Wash gently with mild soap and water.
// 3. Apply a thin layer of aftercare ointment.
// 4. Avoid direct sunlight for 2 weeks.
// 5. Do not scratch or pick the area.
//
// For any questions, please contact us at +91-XXXXXXXXXX.
//
// Best regards,
// The Temple of Tattooz
// ''';
//
//     return sendEmail(
//       to: to,
//       subject: subject,
//       body: body,
//     );
//   }
// }