import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/core/theme/app_gradients.dart';

enum PsychologistDetailMode { session, request, done }

class PsychologistDetailData {
  final String name;
  final String age;
  final String gender;
  final String time;
  final String type;
  final String mood;
  final String note;

  const PsychologistDetailData({
    required this.name,
    required this.age,
    required this.gender,
    required this.time,
    required this.type,
    required this.mood,
    required this.note,
  });
}

Future<void> showPsychologistDetailSheet({
  required BuildContext context,
  required PsychologistDetailData data,
  required PsychologistDetailMode mode,
  String title = 'Detail Klien',
  VoidCallback? onPrimaryTap,
  VoidCallback? onSecondaryTap,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) {
      return PsychologistDetailSheet(
        data: data,
        mode: mode,
        title: title,
        onPrimaryTap: onPrimaryTap,
        onSecondaryTap: onSecondaryTap,
      );
    },
  );
}

class PsychologistDetailSheet extends StatelessWidget {
  final PsychologistDetailData data;
  final PsychologistDetailMode mode;
  final String title;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  const PsychologistDetailSheet({
    super.key,
    required this.data,
    required this.mode,
    required this.title,
    this.onPrimaryTap,
    this.onSecondaryTap,
  });

  bool get _isDone => mode == PsychologistDetailMode.done;

  String get _primaryLabel {
    switch (mode) {
      case PsychologistDetailMode.session:
        return 'Mulai Sesi';
      case PsychologistDetailMode.request:
        return 'Terima';
      case PsychologistDetailMode.done:
        return 'Selesai Konsultasi';
    }
  }

  IconData get _typeIcon {
    switch (data.type) {
      case 'Video Call':
        return Icons.videocam;
      case 'Voice Call':
        return Icons.call;
      default:
        return Icons.chat_bubble;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1B517A);
    final softBlue = const Color(0xFF7DA0C4);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: softBlue, width: 1),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFE3ECF6),
                  child: Icon(Icons.person, color: Color(0xFF4D6E8A)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data.age}  -  ${data.gender}',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Informasi Sesi',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          _InfoTile(
            icon: Icons.access_time,
            label: 'Jadwal Sesi',
            value: data.time,
          ),
          const SizedBox(height: 10),
          _InfoTile(
            icon: _typeIcon,
            label: 'Tipe Konsultasi',
            value: data.type,
          ),
          const SizedBox(height: 10),
          _InfoTile(
            icon: Icons.sentiment_satisfied_alt,
            label: 'Mood Terakhir',
            value: data.mood,
          ),
          const SizedBox(height: 16),
          Text(
            'Catatan Klien',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: softBlue, width: 1),
            ),
            child: Text(
              data.note,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (mode == PsychologistDetailMode.request)
            Row(
              children: [
                Expanded(
                  child: _PrimaryButton(
                    label: _primaryLabel,
                    isDone: _isDone,
                    onTap: onPrimaryTap ?? () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSecondaryTap ?? () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE76F51),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Tolak',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE76F51),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            _PrimaryButton(
              label: _primaryLabel,
              isDone: _isDone,
              onTap: _isDone
                  ? null
                  : onPrimaryTap ?? () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isDone;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabledColor = const Color(0xFFE6E6E6);
    final disabledTextColor = const Color(0xFF8A8A8A);

    return Container(
      decoration: BoxDecoration(
        gradient: isDone ? null : AppGradients.horizontal,
        color: isDone ? disabledColor : null,
        borderRadius: BorderRadius.circular(12),
        border: isDone
            ? Border.all(color: const Color(0xFFBDBDBD), width: 1.2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDone ? disabledTextColor : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppGradients.horizontal,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
