// // lib/services/reports/report_service.dart
// import 'dart:typed_data';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:excel/excel.dart';
// import 'package:tattoo/core/enums/payment_method.dart';
// import '../../core/enums/payment_status.dart';
// import '../../core/enums/service_category.dart';
// import '../../models/consent_form_model.dart';
//
// class ReportService {
//   // ============================================================
//   // PDF Report
//   // ============================================================
//
//   static Future<Uint8List> generatePDFReport({
//     required List<ConsentFormModel> forms,
//     required String title,
//     required String studioName,
//     required DateTimeRange dateRange,
//   }) async {
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: pw.EdgeInsets.all(40),
//         build: (pw.Context context) {
//           return [
//             pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 // Studio Name
//                 pw.Text(
//                   studioName,
//                   style: pw.TextStyle(
//                     fontSize: 28,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.blue800,
//                   ),
//                 ),
//                 pw.SizedBox(height: 4),
//
//                 // Title
//                 pw.Text(
//                   title,
//                   style: pw.TextStyle(
//                     fontSize: 22,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.black,
//                   ),
//                 ),
//                 pw.SizedBox(height: 4),
//
//                 // Date Range
//                 pw.Text(
//                   'Period: ${_formatDate(dateRange.start)} - ${_formatDate(dateRange.end)}',
//                   style: pw.TextStyle(
//                     fontSize: 12,
//                     color: PdfColors.grey700,
//                   ),
//                 ),
//                 pw.SizedBox(height: 8),
//
//                 // Generated Date
//                 pw.Text(
//                   'Generated: ${_formatDateTime(DateTime.now())}',
//                   style: pw.TextStyle(
//                     fontSize: 10,
//                     color: PdfColors.grey500,
//                   ),
//                 ),
//                 pw.Divider(),
//                 pw.SizedBox(height: 16),
//
//                 // Summary Section
//                 pw.Text(
//                   '📊 Summary',
//                   style: pw.TextStyle(
//                     fontSize: 18,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.blue800,
//                   ),
//                 ),
//                 pw.SizedBox(height: 12),
//
//                 // Summary Cards
//                 pw.Container(
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.grey100,
//                     borderRadius: pw.BorderRadius.circular(8),
//                   ),
//                   padding: pw.EdgeInsets.all(16),
//                   child: pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildSummaryItem(
//                         label: 'Total Customers',
//                         value: forms.length.toString(),
//                         icon: '👤',
//                       ),
//                       _buildSummaryItem(
//                         label: 'Total Revenue',
//                         value: '₹${_calculateTotal(forms).toStringAsFixed(0)}',
//                         icon: '💰',
//                       ),
//                       _buildSummaryItem(
//                         label: 'Paid',
//                         value: forms.where((f) => f.payment.status == PaymentStatus.paid).length.toString(),
//                         icon: '✅',
//                         color: PdfColors.green,
//                       ),
//                       _buildSummaryItem(
//                         label: 'Pending',
//                         value: forms.where((f) => f.payment.status == PaymentStatus.pending).length.toString(),
//                         icon: '⏳',
//                         color: PdfColors.orange,
//                       ),
//                       _buildSummaryItem(
//                         label: 'Partial',
//                         value: forms.where((f) => f.payment.status == PaymentStatus.partial).length.toString(),
//                         icon: '🔄',
//                         color: PdfColors.orange,
//                       ),
//                     ],
//                   ),
//                 ),
//                 pw.SizedBox(height: 24),
//
//                 // Table Section
//                 pw.Text(
//                   '📋 Detailed Report',
//                   style: pw.TextStyle(
//                     fontSize: 18,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.blue800,
//                   ),
//                 ),
//                 pw.SizedBox(height: 12),
//
//                 // Table Header
//                 pw.Container(
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.blue700,
//                     borderRadius: pw.BorderRadius.circular(4),
//                   ),
//                   padding: pw.EdgeInsets.all(10),
//                   child: pw.Row(
//                     children: [
//                       _buildHeaderCell('#', flex: 1),
//                       _buildHeaderCell('Customer', flex: 3),
//                       _buildHeaderCell('Service', flex: 2),
//                       _buildHeaderCell('Artist', flex: 2),
//                       _buildHeaderCell('Date', flex: 2),
//                       _buildHeaderCell('Amount', flex: 2, alignment: pw.Alignment.centerRight),
//                       _buildHeaderCell('Status', flex: 2, alignment: pw.Alignment.center),
//                     ],
//                   ),
//                 ),
//
//                 // Table Rows
//                 ...forms.asMap().entries.map((entry) {
//                   final index = entry.key;
//                   final form = entry.value;
//                   final isEven = index % 2 == 0;
//
//                   return pw.Container(
//                     decoration: pw.BoxDecoration(
//                       color: isEven ? PdfColors.white : PdfColors.grey100,
//                       border: pw.Border(
//                         bottom: pw.BorderSide(
//                           color: PdfColors.grey300,
//                           width: 0.5,
//                         ),
//                       ),
//                     ),
//                     padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                     child: pw.Row(
//                       children: [
//                         _buildDataCell('${index + 1}', flex: 1),
//                         _buildDataCell(form.customer.name, flex: 3),
//                         _buildDataCell(form.service.category.label, flex: 2),
//                         _buildDataCell(form.artistName, flex: 2),
//                         _buildDataCell(form.appointment.date.toString(), flex: 2),
//                         _buildDataCell(
//                           '₹${form.payment.finalAmount.toStringAsFixed(0)}',
//                           flex: 2,
//                           alignment: pw.Alignment.centerRight,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                         _buildDataCell(
//                           form.payment.status.label,
//                           flex: 2,
//                           alignment: pw.Alignment.center,
//                           textColor: form.payment.status == PaymentStatus.paid
//                               ? PdfColors.green
//                               : form.payment.status == PaymentStatus.partial
//                               ? PdfColors.orange
//                               : PdfColors.red,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//
//                 pw.SizedBox(height: 20),
//
//                 // Footer
//                 pw.Divider(),
//                 pw.SizedBox(height: 8),
//                 pw.Text(
//                   'Report generated by The Temple of Tattooz Management System',
//                   style: pw.TextStyle(
//                     fontSize: 10,
//                     color: PdfColors.grey500,
//                     fontStyle: pw.FontStyle.italic,
//                   ),
//                 ),
//                 pw.Text(
//                   'This is a system-generated report. For any queries, contact support.',
//                   style: pw.TextStyle(
//                     fontSize: 10,
//                     color: PdfColors.grey500,
//                     fontStyle: pw.FontStyle.italic,
//                   ),
//                 ),
//               ],
//             ),
//           ];
//         },
//       ),
//     );
//
//     return await pdf.save();
//   }
//
//   // ============================================================
//   // PDF Helper Methods
//   // ============================================================
//
//   static pw.Widget _buildSummaryItem({
//     required String label,
//     required String value,
//     required String icon,
//     PdfColor? color,
//   }) {
//     return pw.Column(
//       children: [
//         pw.Text(
//           icon,
//           style: pw.TextStyle(fontSize: 24),
//         ),
//         pw.SizedBox(height: 4),
//         pw.Text(
//           value,
//           style: pw.TextStyle(
//             fontSize: 18,
//             fontWeight: pw.FontWeight.bold,
//             color: color ?? PdfColors.black,
//           ),
//         ),
//         pw.Text(
//           label,
//           style: pw.TextStyle(
//             fontSize: 10,
//             color: PdfColors.grey600,
//           ),
//         ),
//       ],
//     );
//   }
//
//   static pw.Widget _buildHeaderCell(
//       String text, {
//         int flex = 1,
//         pw.Alignment alignment = pw.Alignment.centerLeft,
//       }) {
//     return pw.Expanded(
//       flex: flex,
//       child: pw.Container(
//         alignment: alignment,
//         child: pw.Text(
//           text,
//           style: pw.TextStyle(
//             color: PdfColors.white,
//             fontWeight: pw.FontWeight.bold,
//             fontSize: 11,
//           ),
//         ),
//       ),
//     );
//   }
//
//   static pw.Widget _buildDataCell(
//       String text, {
//         int flex = 1,
//         pw.Alignment alignment = pw.Alignment.centerLeft,
//         PdfColor? textColor,
//         pw.FontWeight? fontWeight,
//       }) {
//     return pw.Expanded(
//       flex: flex,
//       child: pw.Container(
//         alignment: alignment,
//         child: pw.Text(
//           text,
//           style: pw.TextStyle(
//             color: textColor ?? PdfColors.black,
//             fontWeight: fontWeight ?? pw.FontWeight.normal,
//             fontSize: 10,
//           ),
//          // overflow: pw.TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
//
//   // ============================================================
//   // Excel Report - ✅ FIXED (No column width issues)
//   // ============================================================
//
//   static List<int> generateExcelReport({
//     required List<ConsentFormModel> forms,
//     required String studioName,
//     required String title,
//     required DateTimeRange dateRange,
//   }) {
//     final excel = Excel.createExcel();
//     final sheet = excel['Report'];
//
//     // Title Row
//     sheet.appendRow([
//       TextCellValue(studioName),
//     ]);
//     sheet.appendRow([
//       TextCellValue(title),
//     ]);
//     sheet.appendRow([
//       TextCellValue('Period: ${_formatDate(dateRange.start)} - ${_formatDate(dateRange.end)}'),
//     ]);
//     sheet.appendRow([]); // Empty row
//
//     // Summary
//     sheet.appendRow([
//       TextCellValue('SUMMARY'),
//     ]);
//     sheet.appendRow([
//       TextCellValue('Total Customers'),
//       TextCellValue(forms.length.toString()),
//     ]);
//     sheet.appendRow([
//       TextCellValue('Total Revenue'),
//       TextCellValue('₹${_calculateTotal(forms).toStringAsFixed(0)}'),
//     ]);
//     sheet.appendRow([
//       TextCellValue('Paid'),
//       TextCellValue(forms.where((f) => f.payment.status == PaymentStatus.paid).length.toString()),
//     ]);
//     sheet.appendRow([
//       TextCellValue('Pending'),
//       TextCellValue(forms.where((f) => f.payment.status == PaymentStatus.pending).length.toString()),
//     ]);
//     sheet.appendRow([
//       TextCellValue('Partial'),
//       TextCellValue(forms.where((f) => f.payment.status == PaymentStatus.partial).length.toString()),
//     ]);
//     sheet.appendRow([]); // Empty row
//
//     // Headers
//     final headers = [
//       '#',
//       'Customer Name',
//       'Mobile',
//       'Service',
//       'Artist',
//       'Date',
//       'Time',
//       'Total Amount',
//       'Discount',
//       'Final Amount',
//       'Payment Status',
//       'Payment Method',
//       'Transaction ID',
//       'Health Conditions',
//       'Consent Signed',
//       'Created Date',
//     ];
//     sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
//
//     // Data
//     for (var i = 0; i < forms.length; i++) {
//       final form = forms[i];
//       sheet.appendRow([
//         TextCellValue('${i + 1}'),
//         TextCellValue(form.customer.name),
//         TextCellValue(form.customer.mobile),
//         TextCellValue(form.service.category.label),
//         TextCellValue(form.artistName),
//         TextCellValue(form.appointment.date.toString()),
//         TextCellValue(form.appointment.time),
//         TextCellValue(form.payment.totalAmount.toStringAsFixed(0)),
//         TextCellValue(form.payment.discount.toStringAsFixed(0)),
//         TextCellValue(form.payment.finalAmount.toStringAsFixed(0)),
//         TextCellValue(form.payment.status.label),
//         TextCellValue(form.payment.methods.map((m) => m.label).join(', ')),
//         TextCellValue(form.payment.id),
//         TextCellValue(form.healthConditions.isNotEmpty ? form.healthConditions.join(', ') : 'None'),
//         TextCellValue(form.consentConfirmed ? 'Yes' : 'No'),
//         TextCellValue(_formatDateTime(form.createdAt)),
//       ]);
//     }
//
//     return excel.encode()!;
//   }
//
//   // ============================================================
//   // Helper Methods
//   // ============================================================
//
//   static double _calculateTotal(List<ConsentFormModel> forms) {
//     return forms.fold(0.0, (sum, form) => sum + form.payment.finalAmount);
//   }
//
//   static String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
//   }
//
//   static String _formatDateTime(DateTime dateTime) {
//     return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
//   }
//
//   // ============================================================
//   // Chart Generation (Bonus)
//   // ============================================================
//
//   static Map<String, dynamic> generateStats(List<ConsentFormModel> forms) {
//     final totalRevenue = _calculateTotal(forms);
//     final totalCustomers = forms.length;
//     final paidCount = forms.where((f) => f.payment.status == PaymentStatus.paid).length;
//     final pendingCount = forms.where((f) => f.payment.status == PaymentStatus.pending).length;
//     final partialCount = forms.where((f) => f.payment.status == PaymentStatus.partial).length;
//
//     // Revenue by artist
//     final Map<String, double> artistRevenue = {};
//     for (final form in forms) {
//       artistRevenue[form.artistName] =
//           (artistRevenue[form.artistName] ?? 0) + form.payment.finalAmount;
//     }
//
//     // Popular services
//     final Map<String, int> serviceCount = {};
//     for (final form in forms) {
//       serviceCount[form.service.category.label] =
//           (serviceCount[form.service.category.label] ?? 0) + 1;
//     }
//
//     return {
//       'totalRevenue': totalRevenue,
//       'totalCustomers': totalCustomers,
//       'paidCount': paidCount,
//       'pendingCount': pendingCount,
//       'partialCount': partialCount,
//       'artistRevenue': artistRevenue,
//       'serviceCount': serviceCount,
//     };
//   }
// }