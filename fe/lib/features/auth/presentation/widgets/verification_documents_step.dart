import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

class VerificationDocumentsStep extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onNext;

  const VerificationDocumentsStep({super.key, required this.onNext});

  @override
  State<VerificationDocumentsStep> createState() =>
      _VerificationDocumentsStepState();
}

class _VerificationDocumentsStepState extends State<VerificationDocumentsStep> {
  File? _ktpFile;
  File? _selfieFile;
  File? _strFile;
  bool _agreed = false;

  final LinearGradient _horizontalGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF578BB3), Color(0xFF194F78)],
  );

  Future<void> _pickImage(ValueSetter<File> onSelected) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      onSelected(File(picked.path));
    }
  }

  void _handleNext() {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus menyetujui Syarat & Ketentuan.')),
      );
      return;
    }

    widget.onNext({
      'ktpUrl': 'https://cdn1.katadata.co.id/media/images/thumb/2024/08/19/2024_08_19-12_25_12_49cbea96-5df2-11ef-b67d-0242ac120007_960x640_thumb.jpg',
      'faceWithKtpUrl': 'https://cdn1.katadata.co.id/media/images/thumb/2024/08/19/2024_08_19-12_25_12_49cbea96-5df2-11ef-b67d-0242ac120007_960x640_thumb.jpg',
      'strLicenseUrl': 'https://cdn1.katadata.co.id/media/images/thumb/2024/08/19/2024_08_19-12_25_12_49cbea96-5df2-11ef-b67d-0242ac120007_960x640_thumb.jpg',
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = _agreed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Dokumen Verifikasi',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _RequiredLabel(text: 'Unggah KTP'),
        const SizedBox(height: 8),
        _UploadCard(
          file: _ktpFile,
          onTap: () => _pickImage((file) => setState(() => _ktpFile = file)),
        ),
        const SizedBox(height: 16),
        _RequiredLabel(text: 'Unggah Verifikasi Wajah dengan KTP'),
        const SizedBox(height: 8),
        _UploadCard(
          file: _selfieFile,
          onTap: () => _pickImage((file) => setState(() => _selfieFile = file)),
        ),
        const SizedBox(height: 16),
        _RequiredLabel(text: 'Lisensi Praktik (STR)'),
        const SizedBox(height: 8),
        _UploadCard(
          file: _strFile,
          onTap: () => _pickImage((file) => setState(() => _strFile = file)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: _agreed,
              activeColor: const Color(0xFF194F78),
              onChanged: (value) => setState(() => _agreed = value ?? false),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Saya menyetujui ',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: 'Syarat & Ketentuan.',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Opacity(
          opacity: canSubmit ? 1 : 0.5,
          child: Container(
            decoration: BoxDecoration(
              gradient: _horizontalGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canSubmit ? _handleNext : null,
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text(
                      'Daftar',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _UploadCard extends StatelessWidget {
  final File? file;
  final VoidCallback onTap;

  const _UploadCard({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: const Color(0xFF3D7AB5),
          strokeWidth: 1,
          dashPattern: const [10, 10],
          radius: const Radius.circular(12),
        ),
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: file == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.upload,
                        color: Color(0xFF578BB3),
                        size: 30,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Klik untuk mengunggah',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      file!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  final String text;

  const _RequiredLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
