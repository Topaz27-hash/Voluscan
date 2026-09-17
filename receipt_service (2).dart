import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/parcel_measurement.dart';

class ReceiptService {
  static Future<Uint8List> build(ParcelMeasurement parcel) async {
    final document = pw.Document();
    final date = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());
    final reference = parcel.reference.trim().isEmpty
        ? 'VS-${DateTime.now().millisecondsSinceEpoch}'
        : parcel.reference.trim();

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(42),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              color: PdfColor.fromHex('#133C55'),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('VOLUSCAN', style: pw.TextStyle(color: PdfColors.white, fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  pw.Text('PARCEL RECEIPT', style: const pw.TextStyle(color: PdfColors.white, fontSize: 11)),
                ],
              ),
            ),
            pw.SizedBox(height: 28),
            pw.Text('Shipment summary', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Reference: $reference'),
            pw.Text('Generated: $date'),
            pw.SizedBox(height: 24),
            _row('Dimensions', '${parcel.length.toStringAsFixed(1)} × ${parcel.width.toStringAsFixed(1)} × ${parcel.height.toStringAsFixed(1)} cm'),
            _row('Divisor', parcel.divisor.toStringAsFixed(0)),
            _row('Actual weight', parcel.actualWeight == null ? 'Not provided' : '${parcel.actualWeight!.toStringAsFixed(2)} kg'),
            _row('Volumetric weight', '${parcel.volumetricWeight.toStringAsFixed(2)} kg'),
            pw.Divider(height: 30),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#EAF7F4'), borderRadius: pw.BorderRadius.circular(10)),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('CHARGEABLE WEIGHT', style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#246B62'))),
                pw.SizedBox(height: 5),
                pw.Text('${parcel.chargeableWeight.toStringAsFixed(2)} kg', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#133C55'))),
              ]),
            ),
            pw.Spacer(),
            pw.Text('Chargeable weight is the greater of actual and volumetric weight.', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ],
        ),
      ),
    );
    return document.save();
  }

  static pw.Widget _row(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ]),
      );
}
