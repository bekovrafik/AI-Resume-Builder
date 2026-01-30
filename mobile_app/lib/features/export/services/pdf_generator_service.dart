import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../resume/models/resume_model.dart';

class PdfGeneratorService {
  Future<Uint8List> generateResumePdf(ResumeData data, String theme) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final fontItalic = await PdfGoogleFonts.interItalic();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
          italic: fontItalic,
        ),
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
    const primaryColor = PdfColors.black;
    const accentColor = PdfColors.grey700;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Text(
          data.fullName?.toUpperCase() ?? "CANDIDATE NAME",
          style: pw.TextStyle(
            fontSize: 26,
            fontWeight: pw.FontWeight.bold,
            color: primaryColor,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          data.targetRole ?? "Target Role",
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: accentColor,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "${data.email ?? ''}  •  ${data.phone ?? ''}",
              style: const pw.TextStyle(fontSize: 10, color: accentColor),
            ),
            pw.Text(
              data.location ?? '',
              style: const pw.TextStyle(fontSize: 10, color: accentColor),
            ),
          ],
        ),
        if (data.linkedIn != null && data.linkedIn!.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(data.linkedIn!,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.blue700)),
        ],
        pw.SizedBox(height: 12),
        pw.Container(height: 2, color: PdfColors.black),
        pw.SizedBox(height: 16),

        // Summary
        if (data.summary != null) ...[
          _buildSectionHeader("PROFESSIONAL SUMMARY"),
          pw.SizedBox(height: 8),
          pw.Text(data.summary!,
              style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5)),
          pw.SizedBox(height: 20),
        ],

        // Experience
        if (data.experiences != null && data.experiences!.isNotEmpty) ...[
          _buildSectionHeader("PROFESSIONAL EXPERIENCE"),
          pw.SizedBox(height: 12),
          ...data.experiences!.map((e) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(e.role ?? '',
                              style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(e.period ?? '',
                              style: const pw.TextStyle(
                                  fontSize: 9, color: accentColor)),
                        ]),
                    pw.SizedBox(height: 2),
                    pw.Text(e.company ?? '',
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontStyle: pw.FontStyle.italic,
                            color: PdfColors.grey900)),
                    pw.SizedBox(height: 6),
                    if (e.achievements != null)
                      ...e.achievements!.map((a) => pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 12, top: 3),
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  margin: const pw.EdgeInsets.only(
                                      top: 4, right: 8),
                                  width: 3,
                                  height: 3,
                                  decoration: const pw.BoxDecoration(
                                      color: PdfColors.black,
                                      shape: pw.BoxShape.circle),
                                ),
                                pw.Expanded(
                                    child: pw.Text(a,
                                        style:
                                            const pw.TextStyle(fontSize: 10))),
                              ],
                            ),
                          ))
                  ],
                ),
              )),
          pw.SizedBox(height: 10),
        ],

        // Skills
        if (data.skills != null && data.skills!.isNotEmpty) ...[
          _buildSectionHeader("CORE COMPETENCIES"),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 20,
            runSpacing: 10,
            children: data.skills!
                .map((cat) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(cat.category ?? '',
                            style: pw.TextStyle(
                                fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text(cat.skills?.join(' • ') ?? '',
                            style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ))
                .toList(),
          ),
          pw.SizedBox(height: 20),
        ],

        // Education
        if (data.education != null && data.education!.isNotEmpty) ...[
          _buildSectionHeader("EDUCATION"),
          pw.SizedBox(height: 12),
          ...data.education!.map((e) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(e.degree ?? '',
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text(e.institution ?? '',
                            style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Text(e.period ?? '',
                        style: const pw.TextStyle(
                            fontSize: 9, color: accentColor)),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  pw.Widget _buildSectionHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
            letterSpacing: 1.2,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 0.5, color: PdfColors.grey300),
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
