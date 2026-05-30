import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/theme/app_gradients.dart';
import 'package:hackathon/core/shared_widgets/waveform.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/services/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIPartnerVoice extends StatefulWidget {
  const AIPartnerVoice({super.key});

  @override
  State<AIPartnerVoice> createState() => _AIPartnerVoiceState();
}

class _AIPartnerVoiceState extends State<AIPartnerVoice>
    with TickerProviderStateMixin {
  static final String _baseUrl = AppConstants.baseUrl;

  late AnimationController _waveController;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  io.Socket? _socket;
  StreamSubscription<Uint8List>? _audioSubscription;
  final List<int> _assistantAudioBytes = [];
  String? _sessionId;
  String _partialTranscript = '';
  String _assistantText = '';

  bool _isRecording = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _stopRecording();
    _socket?.dispose();
    _player.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
      return;
    }

    await _startRecording();
  }

  Future<void> _startRecording() async {
    if (_isRecording || _isConnecting) return;

    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      _showSnackBar('Permission mikrofon diperlukan.');
      return;
    }

    debugPrint('🎤 _startRecording — connecting socket');
    setState(() {
      _isConnecting = true;
      _assistantText = '';
      _partialTranscript = '';
      _assistantAudioBytes.clear();
    });

    _connectSocket();

    final config = RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000,
      numChannels: 1,
    );

    final audioStream = await _recorder.startStream(config);
    _audioSubscription = audioStream.listen((chunk) {
      final base64Chunk = base64Encode(chunk);
      _socket?.emit('audio', {'chunk': base64Chunk});
    });

    setState(() {
      _isRecording = true;
      _isConnecting = false;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording && !_isConnecting) return;
    debugPrint('🛑 _stopRecording — emitting stop');
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    try {
      await _recorder.stop();
    } catch (_) {}

    _socket?.emit('stop');

    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _isConnecting = false;
    });
  }

  void _connectSocket() {
    _socket?.dispose();

    final socket = io.io(
      '$_baseUrl/ai/voice',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) async {
      final userId = authState.userId;
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('ai_chat_session_id_${authState.userId}');
      debugPrint(
        '🔌 Socket connected — emitting start | userId: $userId | sessionId: $sessionId',
      );
      socket.emit('start', {
        'userId': userId,
        'sampleRate': 16000,
        'sessionId': sessionId,
      });
    });

    socket.on('session', (data) {
      if (data is Map) {
        _sessionId = data['sessionId']?.toString();
        debugPrint('📋 onSession — sessionId: $_sessionId');
      }
    });

    socket.on('transcript', (data) {
      if (data is Map) {
        final text = data['text']?.toString() ?? '';
        final isFinal = data['isFinal'] == true;
        debugPrint('📝 onTranscript — isFinal: $isFinal | text: $text');
        setState(() => _partialTranscript = text);
      }
    });

    socket.on('assistant_text', (data) {
      if (data is Map) {
        final text = data['text']?.toString() ?? '';
        debugPrint('🤖 onAssistantText — text: $text');
        setState(() => _assistantText = text);
      }
    });

    socket.on('assistant_audio', (data) async {
      if (data is Map) {
        final chunk = data['chunk']?.toString();
        final isLast = data['isLast'] == true;
        debugPrint(
          '🔊 onAssistantAudio — chunkLen: ${chunk?.length ?? 0} | isLast: $isLast',
        );
        if (chunk != null && chunk.isNotEmpty) {
          _assistantAudioBytes.addAll(base64Decode(chunk));
        }
        if (isLast && _assistantAudioBytes.isNotEmpty) {
          debugPrint(
            '▶️ Playing audio — total bytes: ${_assistantAudioBytes.length}',
          );
          await _playAssistantAudio(Uint8List.fromList(_assistantAudioBytes));
          _assistantAudioBytes.clear();
        }
      }
    });

    socket.on('error', (data) {
      final message = data is Map ? data['message']?.toString() : null;
      debugPrint('❌ Socket error: $message');
      if (message != null && message.isNotEmpty) {
        _showSnackBar(message);
      }
    });

    socket.onDisconnect((_) {
      debugPrint('🔌 Socket disconnected');
      setState(() {
        _isRecording = false;
        _isConnecting = false;
      });
    });

    _socket = socket;
    socket.connect();
  }

  Future<void> _playAssistantAudio(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/ai_voice_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );
    await file.writeAsBytes(bytes, flush: true);
    await _player.setFilePath(file.path);
    await _player.play();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isWaveActive = _isRecording;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text('AI Partner Voice'),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () async {
              await _stopRecording();
              if (context.mounted) context.pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.message_rounded),
              onPressed: () async {
                await _stopRecording();
                if (context.mounted)
                  context.push(
                    '/partner/ai-partner/chat',
                    extra: {'sessionId': _sessionId},
                  );
              },
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppGradients.horizontal),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 80,
                    child: AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, _) {
                        return Waveform(
                          isActive: isWaveActive,
                          animValue: _waveController.value,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _partialTranscript.isEmpty
                          ? 'Mulai bicara untuk mengirim ke AI.'
                          : _partialTranscript,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1B517A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_assistantText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _assistantText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (_sessionId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Session: $_sessionId',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _VoiceControlPanel(
              onToggle: _toggleRecording,
              isRecording: _isRecording,
              isConnecting: _isConnecting,
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceControlPanel extends StatelessWidget {
  final VoidCallback onToggle;
  final bool isRecording;
  final bool isConnecting;

  const _VoiceControlPanel({
    required this.onToggle,
    required this.isRecording,
    required this.isConnecting,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: 36,
            left: 24,
            right: 24,
            bottom: 64 + MediaQuery.of(context).padding.bottom,
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
        ),
        Positioned(
          top: -62,
          left: 0,
          right: 0,
          child: Center(child: _GradientMascotButton(onTap: onToggle)),
        ),
        if (isConnecting)
          const Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1B517A),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GradientMascotButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GradientMascotButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(102),
          border: Border.all(color: const Color(0xFF1B517A), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Container(
            width: 112,
            height: 112,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppGradients.horizontal,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                child: SvgPicture.asset(
                  'assets/images/mascot/mascot-white.svg',
                  width: 72,
                  height: 72,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
