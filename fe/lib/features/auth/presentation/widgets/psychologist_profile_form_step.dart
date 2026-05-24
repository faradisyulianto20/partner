import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PsychologistProfileFormStep extends StatefulWidget {
  final VoidCallback onNext;

  const PsychologistProfileFormStep({super.key, required this.onNext});

  @override
  State<PsychologistProfileFormStep> createState() =>
      _PsychologistProfileFormStepState();
}

class _PsychologistProfileFormStepState
    extends State<PsychologistProfileFormStep> {
  final List<TextEditingController> _educationControllers = [
    TextEditingController(),
  ];
  final _nikController = TextEditingController();
  final _strController = TextEditingController();
  final _experienceController = TextEditingController(text: '0');
  final _clinicController = TextEditingController();

  String? _selectedSpecialization;

  final LinearGradient _horizontalGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF578BB3), Color(0xFF194F78)],
  );

  final List<String> _specializations = const [
    'Psikolog Klinis',
    'Psikolog Anak',
    'Psikolog Industri',
    'Psikolog Pendidikan',
    'Konselor',
  ];

  @override
  void dispose() {
    for (final controller in _educationControllers) {
      controller.dispose();
    }
    _nikController.dispose();
    _strController.dispose();
    _experienceController.dispose();
    _clinicController.dispose();
    super.dispose();
  }

  void _addEducationField() {
    setState(() {
      _educationControllers.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Input Data Profil',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          'Riwayat Pendidikan',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        for (final controller in _educationControllers) ...[
          TextField(
            controller: controller,
            decoration: _inputDecoration('Riwayat pendidikan anda'),
          ),
          const SizedBox(height: 12),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: _addEducationField,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF194F78)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Tambah Jenjang',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF194F78),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Nomor Induk Kependudukan (NIK)',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nikController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('Masukkan nomor NIK'),
        ),
        const SizedBox(height: 16),
        Text(
          'Nomor Surat Tanda Registrasi (STR)',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _strController,
          decoration: _inputDecoration('Masukkan nomor STR'),
        ),
        const SizedBox(height: 16),
        Text(
          'Tahun Pengalaman Kerja',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _experienceController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('0'),
        ),
        const SizedBox(height: 16),
        Text(
          'Nama Klinik Praktik',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _clinicController,
          decoration: _inputDecoration('Nama klinik'),
        ),
        const SizedBox(height: 16),
        Text(
          'Spesialisasi',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() {
              _selectedSpecialization = value;
            });
          },
          position:
              PopupMenuPosition.under, // Memaksa menu muncul di bawah tombol
          offset: const Offset(40, 8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              bottomLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
              bottomRight: Radius.circular(16.0),
            ),
          ),
          color: Colors.white,
          elevation: 4,
          itemBuilder: (context) {
            return _specializations.map((item) {
              final isSelected = _selectedSpecialization == item;
              return PopupMenuItem<String>(
                value: item,
                padding: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1F4C7A) : Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1F4C7A)
                          : const Color(0xFFBFD0E6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.nunito(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1F4C7A),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedSpecialization ?? 'Pilih spesialisasi',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: _selectedSpecialization == null
                          ? Colors.black38
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            gradient: _horizontalGradient,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onNext,
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Text(
                    'Lanjutkan',
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
        const SizedBox(height: 16),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: Colors.black38, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF578BB3)),
      ),
    );
  }
}
