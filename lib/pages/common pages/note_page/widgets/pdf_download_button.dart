import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:med/models/note_model.dart';

class PDFDownloadButton extends StatelessWidget {
  final List<Note> notes;

  const PDFDownloadButton({super.key, required this.notes});

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Text('My Notes', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          ...notes.map((note) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            child: pw.Text('• ${note.text}', style: const pw.TextStyle(fontSize: 14)),
          )),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
      tooltip: 'Download as PDF',
      onPressed: () => _generatePdf(context),
    );
  }
}
