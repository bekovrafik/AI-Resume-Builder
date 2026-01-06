import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../resume/models/resume_model.dart';

class PdfGeneratorService {
  Future<Uint8List> generateResumePdf(ResumeData data, String theme) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          switch (theme) {
            case 'Modern':
              return [_buildModernLayout(data)];
            case 'Executive':
            default:
              return [_buildExecutiveLayout(data)];
          }
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
          "${data.email ?? ''} • ${data.phone ?? ''} • ${data.location ?? ''}",
          style: const pw.TextStyle(color: PdfColors.grey700),
        ),
        pw.Text(data.linkedIn ?? '',
            style: const pw.TextStyle(color: PdfColors.blue700)),
        pw.Divider(),

        // Summary
        if (data.summary != null) ...[
          pw.SizedBox(height: 10),
          pw.Text("EXECUTIVE SUMMARY",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(data.summary!, style: const pw.TextStyle(lineSpacing: 2)),
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
                    pw.Text(e.company ?? '',
                        style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                    if (e.achievements != null)
                      ...e.achievements!.map((a) => pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 10, top: 2),
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text("• "),
                                pw.Expanded(child: pw.Text(a))
                              ],
                            ),
                          ))
                  ],
                ),
              )),
        ],
        // Education
        if (data.education != null) ...[
          pw.SizedBox(height: 10),
          pw.Text("EDUCATION",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...data.education!.map((e) => pw.Container(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("${e.degree} - ${e.institution}"),
                    pw.Text(e.period ?? ''),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  pw.Widget _buildModernLayout(ResumeData data) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Sidebar
        pw.Container(
          width: 180,
          padding: const pw.EdgeInsets.only(right: 20, top: 0, bottom: 0),
          decoration: const pw.BoxDecoration(
            border: pw.Border(right: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (data.avatarUrl != null && File(data.avatarUrl!).existsSync())
                pw.Container(
                  width: 100,
                  height: 100,
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    image: pw.DecorationImage(
                      image: pw.MemoryImage(
                        File(data.avatarUrl!).readAsBytesSync(),
                      ),
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                ),
              pw.Text(
                data.fullName?.split(' ').first ?? "Name",
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey800,
                ),
              ),
              pw.Text(
                data.fullName?.split(' ').skip(1).join(' ') ?? "Surname",
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.normal,
                  color: PdfColors.blueGrey600,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text("CONTACT",
                  style: pw.TextStyle(
                      color: PdfColors.blueGrey400,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(data.email ?? ''),
              pw.Text(data.phone ?? ''),
              pw.Text(data.location ?? ''),
              pw.SizedBox(height: 20),
              if (data.skills != null && data.skills!.isNotEmpty) ...[
                pw.Text("SKILLS",
                    style: pw.TextStyle(
                        color: PdfColors.blueGrey400,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: data.skills!
                      .expand((cat) => cat.skills ?? <String>[])
                      .map((s) => pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: pw.BoxDecoration(
                                color: PdfColors.grey200,
                                borderRadius: pw.BorderRadius.circular(4)),
                            child: pw.Text(s,
                                style: const pw.TextStyle(fontSize: 10)),
                          ))
                      .toList(),
                )
              ]
            ],
          ),
        ),
        // Main Content
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  data.targetRole?.toUpperCase() ?? "TARGET ROLE",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey800,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 20),
                if (data.summary != null) ...[
                  pw.Text("PROFILE",
                      style: pw.TextStyle(
                          color: PdfColors.blueGrey800,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text(data.summary!,
                      style: const pw.TextStyle(lineSpacing: 1.5)),
                  pw.SizedBox(height: 20),
                ],
                if (data.experiences != null) ...[
                  pw.Text("EXPERIENCE",
                      style: pw.TextStyle(
                          color: PdfColors.blueGrey800,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  ...data.experiences!.map((e) => pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 15),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(e.role ?? '',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14)),
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(e.company ?? '',
                                    style: const pw.TextStyle(
                                        color: PdfColors.grey600)),
                                pw.Text(e.period ?? '',
                                    style: const pw.TextStyle(
                                        color: PdfColors.grey600,
                                        fontSize: 10)),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            if (e.achievements != null)
                              ...e.achievements!.map((a) => pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                        left: 0, top: 2),
                                    child: pw.Text("• $a",
                                        style: const pw.TextStyle(
                                            fontSize: 10,
                                            color: PdfColors.black)),
                                  ))
                          ],
                        ),
                      )),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }
}
