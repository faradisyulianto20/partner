import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceInput extends StatefulWidget {
  const VoiceInput({super.key});

  @override
  State<VoiceInput> createState() => _VoiceInputState();
}

class _VoiceInputState extends State<VoiceInput> with TickerProviderStateMixin {
  // ← Hanya pakai speech_to_text, hapus AudioRecorder
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  bool _isRecording = false;
  bool _isPaused = false;
  String _transcriptText = '';
  bool _textConfirmed = false; // ← track jika text sudah confirmed (warna biru)
  int _dotCount = 0; // ← animasi dots
  int _seconds = 0;

  Timer? _timer;
  Timer? _confirmationTimer; // ← delay untuk efek abu-abu → biru
  Timer? _dotTimer; // ← animasi dots
  late AnimationController _waveController;

  final LinearGradient horizontalGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF578BB3), Color(0xFF194F78)],
  );

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _initSpeech(); // tidak perlu await di sini
  }

  Future<void> _restartListening() async {
    if (!_speechToText.isAvailable || !mounted) return;

    final locales = await _speechToText.locales();
    final idLocale = locales.firstWhere(
      (l) => l.localeId.startsWith('id'),
      orElse: () => locales.first,
    );

    await _speechToText.listen(
      onResult: (result) {
        if (mounted && result.recognizedWords.isNotEmpty) {
          setState(() {
            // Append ke transcript sebelumnya, bukan replace
            _transcriptText = '$_transcriptText ${result.recognizedWords}'
                .trim();
          });
        }
      },
      localeId: idLocale.localeId,
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 8),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        onDevice: false,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  Future<void> _initSpeech() async {
    try {
      // Android hanya butuh RECORD_AUDIO, bukan Permission.speech
      final micStatus = await Permission.microphone.request();
      debugPrint('Mic: $micStatus');

      if (!micStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission mikrofon diperlukan')),
          );
        }
        return;
      }

      final enabled = await _speechToText.initialize(
        onError: (error) => debugPrint('STT Error: $error'),
        onStatus: (status) {
          debugPrint('STT Status: $status');

          if (status == 'notListening' &&
              _isRecording &&
              !_isPaused &&
              mounted) {
            // Jika tiba-tiba berhenti saat masih recording, coba restart
            Future.delayed(const Duration(milliseconds: 300), () {
              if (_isRecording && !_isPaused && mounted) {
                _restartListening();
              }
            });
          }

          // ← Auto restart jika tiba-tiba done saat masih recording
          if (status == 'done' && _isRecording && !_isPaused && mounted) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (_isRecording && !_isPaused && mounted) {
                _restartListening(); // restart tanpa reset transcript
              }
            });
          }
        },
        debugLogging: true,
      );

      debugPrint('Speech enabled: $enabled');
      if (mounted) setState(() => _speechEnabled = enabled);
    } catch (e) {
      debugPrint('Init speech error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confirmationTimer?.cancel();
    _dotTimer?.cancel();
    _waveController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_speechEnabled) {
      await _initSpeech();
      if (!_speechEnabled || !mounted) return;
    }

    // Cari locale Indonesia, fallback ke default device
    final locales = await _speechToText.locales();
    final idLocale = locales.firstWhere(
      (l) => l.localeId.startsWith('id'),
      orElse: () => locales.first,
    );
    debugPrint('Menggunakan locale: ${idLocale.localeId}');

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: idLocale.localeId,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 8), // ← naikkan jeda
        listenOptions: SpeechListenOptions(
          partialResults: true,
          onDevice: false, // ← KUNCI: pakai cloud STT
          cancelOnError: false,
          listenMode: ListenMode.dictation,
        ),
      );

      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _isPaused = false;
        _seconds = 0;
        _transcriptText = '';
        _textConfirmed = false;
        _dotCount = 0;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && _isRecording && !_isPaused) setState(() => _seconds++);
      });
    } catch (e) {
      debugPrint('Error start recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      // Reset confirmation status
      _confirmationTimer?.cancel();
      _textConfirmed = false;

      setState(() => _transcriptText = result.recognizedWords);

      // Delay 300ms untuk efek abu-abu → biru
      _confirmationTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() => _textConfirmed = true);
        }
      });

      // Start animasi dots
      _startDotsAnimation();
    }
  }

  void _startDotsAnimation() {
    _dotTimer?.cancel();
    _dotCount = 0;
    _dotTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4; // 0, 1, 2, 3, 0, 1, 2, 3 ...
        });
      }
    });
  }

  Future<void> _pauseResumeRecording() async {
    var locales = await _speechToText.locales();
    var idLocale = locales.firstWhere(
      (locale) => locale.localeId.contains('id'),
      orElse: () => locales.first, // Jika ID tidak ada, pakai default perangkat
    );

    if (_isPaused) {
      // Resume: mulai listen lagi
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: idLocale.localeId,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.dictation,
        ),
      );
      if (mounted) setState(() => _isPaused = false);
    } else {
      // Pause
      await _speechToText.stop();
      if (mounted) setState(() => _isPaused = true);
    }
  }

  Future<void> _stopAndClear() async {
    _timer?.cancel();
    _confirmationTimer?.cancel();
    _dotTimer?.cancel();
    await _speechToText.cancel(); // ← cancel, buang hasil

    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _seconds = 0;
      _transcriptText = '';
      _textConfirmed = false;
      _dotCount = 0;
    });

    context.go('/home/emotion-description');
  }

  Future<void> _confirm() async {
    _timer?.cancel();
    _confirmationTimer?.cancel();
    _dotTimer?.cancel();
    await _speechToText.stop(); // ← stop, simpan hasil transcript

    if (!mounted) return;
    // TODO: kirim _transcriptText ke halaman berikutnya jika perlu
    context.go('/home/emotion-description');
  }

  String get _formattedTime {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // Helper untuk dots animasi
  String get _animatedDots {
    if (!_isRecording) return '';
    const dots = ['', '.', '..', '...'];
    return ' ${dots[_dotCount]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isRecording ? null : _stopAndClear,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: _isRecording
                          ? Colors.grey[400]
                          : const Color(0xFF1B517A),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Deskripsi Emosi',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B517A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          const SizedBox(height: 42),
          // Transcript
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  // Tampilkan transcript atau placeholder + animated dots
                  _isRecording
                      ? (_transcriptText.isEmpty
                            ? 'Mendengarkan...'
                            : _transcriptText + _animatedDots)
                      : '...',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    // Abu-abu dulu, lalu berubah biru setelah 300ms
                    color: (_isRecording && _transcriptText.isNotEmpty)
                        ? (_textConfirmed
                              ? const Color(0xFF1B517A) // BIRU (confirmed)
                              : Colors.grey[400]) // ABU-ABU (waiting)
                        : Colors.grey[400],
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Waveform
          SizedBox(
            height: 80,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                return _Waveform(
                  isActive: _isRecording && !_isPaused,
                  animValue: _waveController.value,
                );
              },
            ),
          ),

          const SizedBox(height: 240),

          // Bottom bar dengan Stack untuk button menonjol
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Background container
              Container(
                padding: EdgeInsets.only(
                  top: 32, // ← beri ruang untuk button yang menonjol
                  left: 32,
                  right: 32,
                  bottom: 24 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Cancel button
                    _CircleButton(
                      onTap: _stopAndClear,
                      backgroundColor: const Color(0xFFFFE5E5),
                      icon: Icons.close,
                      iconColor: const Color(0xFFE57373),
                      size: 60,
                    ),

                    // Timer di tengah bawah mic button
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B517A),
                      ),
                    ),

                    // Confirm button
                    _CircleButton(
                      onTap: _confirm,
                      backgroundColor: const Color(0xFFDFF5E3),
                      icon: Icons.check,
                      iconColor: const Color(0xFF66BB6A),
                      size: 60,
                    ),
                  ],
                ),
              ),

              // ← Mic button di Stack langsung, bukan di dalam Column/Row
              Positioned(
                top: -48, // ← setengah ukuran button (92/2)
                left: 0,
                right: 0,
                child: Center(
                  child: _CircleButton(
                    onTap: _isRecording
                        ? _pauseResumeRecording
                        : _startRecording,
                    backgroundColor: horizontalGradient,
                    icon: _isPaused
                        ? Icons.play_arrow
                        : (_isRecording ? Icons.pause : Icons.mic),
                    iconColor: Colors.white,
                    size: 92,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final dynamic backgroundColor;
  final IconData icon;
  final Color iconColor;
  final double size;

  const _CircleButton({
    required this.onTap,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: backgroundColor is LinearGradient ? null : null,
          color: backgroundColor is LinearGradient ? null : backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: iconColor, width: 2),
        ),
        child: backgroundColor is LinearGradient
            ? Container(
                decoration: BoxDecoration(
                  gradient: backgroundColor as LinearGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: size * 0.45),
              )
            : Icon(icon, color: iconColor, size: size * 0.45),
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  final bool isActive;
  final double animValue;

  const _Waveform({required this.isActive, required this.animValue});

  static const List<double> _baseHeights = [
    10,
    18,
    30,
    45,
    55,
    62,
    58,
    48,
    36,
    22,
    14,
    22,
    36,
    48,
    58,
    62,
    55,
    45,
    30,
    18,
  ];

  @override
  Widget build(BuildContext context) {
    const barCount = 10;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(barCount, (i) {
        // Gunakan real-time amplitude dari microphone
        double height;

        if (isActive) {
          // Jika tidak recording, tampilkan static waveform
          final phase = (animValue + i / barCount) % 1.0;
          final wave = (sin(phase * 2 * pi) + 1) / 2; // 0.0 → 1.0

          // Mix antara base height & variasi wave agar natural
          final base = _baseHeights[i];
          height = base * 0.6 + base * 0.6 * wave;
        } else {
          height = 14.0; // tinggi bar saat tidak aktif
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 10,
          height: height.clamp(6.0, 70.0),
          decoration: BoxDecoration(
            color: Color.fromRGBO(45, 106, 159, isActive ? 0.8 : 0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
