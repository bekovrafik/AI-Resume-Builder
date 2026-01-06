import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../resume/models/resume_model.dart';

class PdfGeneratorService {
  Future<Uint8List> generateResumePdf(ResumeData data, String theme) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return _buildExecutiveLayout(data); // TODO: Switch based on theme
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildExecutiveLayout(ResumeData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Text(
          data.fullName ?? "Candidate Name",
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          data.targetRole ?? "Target Role",
          style: const pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
            "${data.email ?? ''} • ${data.phone ?? ''} • ${data.location ?? ''}"),
        pw.Text(data.linkedIn ?? ''),
        pw.Divider(),

        // Summary
        if (data.summary != null) ...[
          pw.SizedBox(height: 10),
          pw.Text("EXECUTIVE SUMMARY",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(data.summary!),
        ],

        // Experience
        if (data.experiences != null) ...[
          pw.SizedBox(height: 10),
          pw.Text("EXPERIENCE",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...data.experiences!.map((e) => pw.Container(
                padding: const pw.EdgeInsets.only(top: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(e.role ?? '',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(e.period ?? ''),
                        ]),
                    pw.Text(e.company ?? ''),
                    if (e.achievements != null)
                      ...e.achievements!.map((a) => pw.Bullet(text: a))
                  ],
                ),
              )),
        ]
      ],
    );
  }
}
