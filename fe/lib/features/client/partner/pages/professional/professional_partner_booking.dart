import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/models/psychologist_models.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/services/psychologist_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Booking extends StatefulWidget {
  final String psychologistId;
  final String psychologistName;
  final int price;

  const Booking({
    super.key,
    required this.psychologistId,
    required this.psychologistName,
    required this.price,
  });

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final List<String> _times = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];
  String? _selectedTime;
  PsychologistBookingMethod _selectedMethod = PsychologistBookingMethod.chat;
  bool _isLoading = false;

  late final PsychologistService _psychologistService = PsychologistService(
    ApiClient(baseUrl: dotenv.env['API_URL'] ?? 'http://10.72.12.108:3000'),
  );

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF194F78),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      _dateController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Booking Psikolog Berhasil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F4C7A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.go('/partner');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F4C7A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleBooking() async {
    if (_dateController.text.isEmpty) {
      _showErrorDialog('Silakan pilih tanggal');
      return;
    }
    if (_selectedTime == null) {
      _showErrorDialog('Silakan pilih waktu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        _showErrorDialog('User ID tidak ditemukan. Silakan login kembali.');
        return;
      }

      // Combine date and time
      final dateParts = _dateController.text.split('/');
      final bookingDateTime = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        int.parse(_selectedTime!.split(':')[0]),
        int.parse(_selectedTime!.split(':')[1]),
      );

      final response = await _psychologistService.createBooking(
        PsychologistBookingRequest(
          userId: userId,
          psychologistId: widget.psychologistId,
          fullName:
              Supabase
                  .instance
                  .client
                  .auth
                  .currentUser
                  ?.userMetadata?['full_name']
                  ?.toString() ??
              'Unknown',
          method: _selectedMethod,
          price: widget.price,
          scheduledAt: bookingDateTime.toIso8601String(),
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        ),
      );

      if (!mounted) return;

      if (response.isSuccess) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('Gagal membuat booking. Silakan coba lagi.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4D79A6),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Booking Psikolog',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Tanggal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F4C7A),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _pickDate(context),
                decoration: InputDecoration(
                  hintText: 'dd/mm/yy',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBFD0E6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBFD0E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1F4C7A)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Waktu Tersedia',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F4C7A),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _times.map((time) {
                  final isSelected = time == _selectedTime;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTime = time;
                      });
                    },
                    child: Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1F4C7A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1F4C7A)
                              : const Color(0xFFBFD0E6),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1F4C7A),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              const Text(
                'Metode Konsultasi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F4C7A),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MethodOption(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Chat',
                      isSelected: _selectedMethod == PsychologistBookingMethod.chat,
                      onTap: () => setState(() => _selectedMethod = PsychologistBookingMethod.chat),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MethodOption(
                      icon: Icons.graphic_eq_rounded,
                      label: 'Voice',
                      isSelected: _selectedMethod == PsychologistBookingMethod.voice,
                      onTap: () => setState(() => _selectedMethod = PsychologistBookingMethod.voice),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MethodOption(
                      icon: Icons.videocam_outlined,
                      label: 'Video',
                      isSelected: _selectedMethod == PsychologistBookingMethod.video,
                      onTap: () => setState(() => _selectedMethod = PsychologistBookingMethod.video),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Catatan Tambahan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F4C7A),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tuliskan catatan atau keluhan Anda...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBFD0E6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBFD0E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1F4C7A)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F4C7A),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Rp ${widget.price.toString()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F4C7A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4C7A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Konfirmasi Booking',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F4C7A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1F4C7A)
                : const Color(0xFFBFD0E6),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF1F4C7A),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1F4C7A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
