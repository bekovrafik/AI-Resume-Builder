import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/export/services/pdf_generator_service.dart';
import 'package:mobile_app/features/resume/models/resume_model.dart';
import 'package:printing/printing.dart';

class ResumePreviewScreen extends ConsumerWidget {
  final ResumeData resumeData;
  final String theme;

  const ResumePreviewScreen({
    super.key,
    required this.resumeData,
    this.theme = 'Executive',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blueprint Preview')),
      body: PdfPreview(
        build: (format) =>
            PdfGeneratorService().generateResumePdf(resumeData, theme),
        canDebug: false,
        actions: [
          // Custom actions if needed
        ],
      ),
    );
  }
}
