import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/models/human_partner_models.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/services/human_partner_service.dart';
import 'package:hackathon/core/theme/app_gradients.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/services/auth_state.dart';

class HumanPartnerPage extends StatefulWidget {
  const HumanPartnerPage({super.key});

  @override
  State<HumanPartnerPage> createState() => _HumanPartnerPageState();
}

class _HumanPartnerPageState extends State<HumanPartnerPage> {
  static final String _baseUrl = AppConstants.baseUrl;
  static const _primary = Color(0xFF1B517A);
  static const _secondary = Color(0xFF2F6FB4);
  static const _titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: _primary,
  );

  late final ApiClient _apiClient = ApiClient(baseUrl: _baseUrl);
  late final HumanPartnerService _humanPartnerService = HumanPartnerService(
    _apiClient,
  );

  _PartnerState _state = _PartnerState.searching;
  Timer? _pollingTimer;
  bool _isJoining = false;
  String? _matchId;
  String? _partnerUserId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _joinQueue();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _apiClient.close();
    super.dispose();
  }

  Future<void> _joinQueue() async {
    if (_isJoining) return;
    final userId = authState.userId;
    if (userId == null || userId.isEmpty) {
      _showSnackBar('User belum login.');
      return;
    }

    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });

    try {
      final response = await _humanPartnerService
          .joinQueue(HumanPartnerQueueRequest(userId: userId))
          .timeout(const Duration(seconds: 12));
      if (!response.isSuccess) {
        setState(() => _errorMessage = 'Gagal bergabung ke antrean.');
        return;
      }

      final data = response.data.data;
      final map = data is Map ? Map<String, dynamic>.from(data) : null;
      final status = map?['status']?.toString();

      if (status == 'matched') {
        _pollingTimer?.cancel();
        setState(() {
          _state = _PartnerState.found;
          _matchId = map?['matchId']?.toString();
          _partnerUserId = map?['partnerUserId']?.toString();
        });
      } else {
        setState(() => _state = _PartnerState.searching);
        _startPolling();
      }
    } catch (_) {
      setState(() => _errorMessage = 'Terjadi kesalahan saat mencari partner.');
      _startPolling();
    } finally {
      if (!mounted) return;
      setState(() => _isJoining = false);
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    // Polling sederhana setiap 4 detik sampai matched.
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _joinQueue();
    });
  }

  Future<void> _leaveQueue() async {
    final userId = authState.userId;
    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      await _humanPartnerService.leaveQueue(
        HumanPartnerQueueRequest(userId: userId),
      );
    } catch (_) {
      // Ignore leave failures for now.
    }
  }

  Future<void> _resetToSearching() async {
    _pollingTimer?.cancel();
    setState(() {
      _state = _PartnerState.searching;
      _matchId = null;
      _partnerUserId = null;
    });
    await _joinQueue();
  }

  void _acceptPartner() {
    _pollingTimer?.cancel();
    setState(() => _state = _PartnerState.method);
  }

  Future<void> _cancelSearch() async {
    _pollingTimer?.cancel();
    await _leaveQueue();
    if (!mounted) return;
    context.pop();
  }

  Future<void> _openChat(String route) async {
    final matchId = _matchId;
    if (matchId == null || matchId.isEmpty) {
      _showSnackBar('Match belum tersedia.');
      return;
    }

    final response = await _humanPartnerService.getMatch(matchId);
    if (!response.isSuccess) {
      _showSnackBar('Gagal memuat detail match.');
      return;
    }

    if (!mounted) return;
    context.push(
      route,
      extra: {'matchId': matchId, 'match': response.data.data},
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_state) {
      _PartnerState.searching => 'Mencari Partner',
      _PartnerState.found => 'Mencari Partner',
      _PartnerState.method => 'Pilih Metode Komunikasi',
    };

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F9),
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(title),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppGradients.horizontal),
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: switch (_state) {
            _PartnerState.searching => _SearchingState(
              onCancel: _cancelSearch,
              errorMessage: _errorMessage,
            ),
            _PartnerState.found => _FoundState(
              onReject: _resetToSearching,
              onAccept: _acceptPartner,
              partnerUserId: _partnerUserId,
            ),
            _PartnerState.method => _MethodState(
              partnerUserId: _partnerUserId,
              onOpenChat: () => _openChat('/partner/human-partner/chat'),
              onOpenVoice: () => _openChat('/partner/human-partner/voice-call'),
              onOpenVideo: () => _openChat('/partner/human-partner/video-call'),
            ),
          },
        ),
      ),
    );
  }
}

enum _PartnerState { searching, found, method }

class _SearchingState extends StatelessWidget {
  final VoidCallback onCancel;
  final String? errorMessage;

  const _SearchingState({required this.onCancel, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _MascotBadge(size: 124),
          const SizedBox(height: 16),
          const Text(
            'Mencari Partner Untukmu...',
            style: _HumanPartnerPageState._titleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Kami sedang mencari seseorang yang siap\n'
            'mendengarkan dan berbagi cerita\n'
            'bersamamu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Color(0xFF4F6B86),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const _StatusPill(text: 'Memahami kebutuhan emosionalmu...'),
          const SizedBox(height: 10),
          const _StatusPill(text: 'Mencari partner yang tersedia...'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: _HumanPartnerPageState._primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        'Batalkan Pencarian',
                        style: TextStyle(
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
        ],
      ),
    );
  }
}

class _FoundState extends StatelessWidget {
  final VoidCallback onReject;
  final VoidCallback onAccept;
  final String? partnerUserId;

  const _FoundState({
    required this.onReject,
    required this.onAccept,
    this.partnerUserId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Partner Berhasil Ditemukan!',
            style: _HumanPartnerPageState._titleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Partner yang sesuai dengan kebutuhan emosionalmu\n'
            'telah siap untuk terhubung denganmu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          _PartnerCard(partnerUserId: partnerUserId),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CircleActionButton(
                background: const Color(0xFFE35B4E),
                icon: Icons.close_rounded,
                onTap: onReject,
              ),
              const SizedBox(width: 24),
              _CircleActionButton(
                background: const Color(0xFF5DBB78),
                icon: Icons.favorite,
                onTap: onAccept,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tolak atau terima untuk memulai percakapan',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8B95A6),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodState extends StatelessWidget {
  final String? partnerUserId;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenVoice;
  final VoidCallback onOpenVideo;

  const _MethodState({
    this.partnerUserId,
    required this.onOpenChat,
    required this.onOpenVoice,
    required this.onOpenVideo,
  });

  @override
  Widget build(BuildContext context) {
    final partnerName = partnerUserId ?? 'partner';
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 64),
          const _MascotBadge(size: 124, isActive: false),
          const SizedBox(height: 16),
          Text(
            'Mulai percakapan dengan $partnerName',
            style: _HumanPartnerPageState._titleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih cara komunikasi yang nyaman bagimu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF4F6B86),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          _MethodTile(
            title: 'Chat',
            subtitle: 'Percakapan Teks',
            icon: Icons.chat_bubble_outline_rounded,
            onTap: onOpenChat,
          ),
          const SizedBox(height: 12),
          _MethodTile(
            title: 'Voice Call',
            subtitle: 'Panggilan Suara',
            icon: Icons.mic_none_rounded,
            onTap: onOpenVoice,
          ),
          const SizedBox(height: 12),
          _MethodTile(
            title: 'Video Call',
            subtitle: 'Panggilan Video',
            icon: Icons.videocam_outlined,
            onTap: onOpenVideo,
          ),
        ],
      ),
    );
  }
}

class _MascotBadge extends StatefulWidget {
  final double size;
  final bool isActive; // tambah ini

  const _MascotBadge({
    required this.size,
    this.isActive = true, // default aktif
  });

  @override
  State<_MascotBadge> createState() => _MascotBadgeState();
}

class _MascotBadgeState extends State<_MascotBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (widget.isActive) _controller.repeat();
  }

  @override
  void didUpdateWidget(_MascotBadge old) {
    super.didUpdateWidget(old);

    if (widget.isActive != old.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset(); // opsional: reset posisi gelombang
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rippleAreaSize = widget.size * 1;

    return SizedBox(
      width: rippleAreaSize,
      height: rippleAreaSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hanya render CustomPaint jika aktif
          if (widget.isActive)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(rippleAreaSize, rippleAreaSize),
                  painter: _RipplePainter(
                    animValue: _controller.value,
                    color: _HumanPartnerPageState._secondary,
                    rippleCount: 3,
                  ),
                );
              },
            ),
          // Badge tetap tampil
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: _HumanPartnerPageState._secondary),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  gradient: AppGradients.horizontal,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _HumanPartnerPageState._secondary,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                    child: SvgPicture.asset(
                      'assets/images/mascot/mascot-white.svg',
                      width: widget.size * 0.7,
                      height: widget.size * 0.7,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double animValue;
  final Color color;
  final int rippleCount;

  _RipplePainter({
    required this.animValue,
    required this.color,
    this.rippleCount = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;

    for (int i = 0; i < rippleCount; i++) {
      final delay = i / rippleCount;
      final progress = (animValue + delay) % 1.0;
      final radius = baseRadius + (progress * baseRadius * 0.6);
      final opacity = (1.0 - progress) * 0.6;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) => old.animValue != animValue;
}

class _StatusPill extends StatelessWidget {
  final String text;

  const _StatusPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB9C8D8)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _HumanPartnerPageState._primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7C8CA0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final String? partnerUserId;

  const _PartnerCard({this.partnerUserId});

  @override
  Widget build(BuildContext context) {
    final partnerName = partnerUserId ?? 'Partner';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB9C8D8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const _MascotBadge(size: 148, isActive: false),
          const SizedBox(height: 12),
          Text(
            partnerName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _HumanPartnerPageState._primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '71 Tahun • Surakarta',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: const Text(
              'Laki-laki',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Color(0xFF7C8CA0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1.5, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            '"Suka ngobrol tentang kemunduran negara\nIndonesia"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: Color(0xFF707B8C),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final Color background;
  final IconData icon;
  final VoidCallback onTap;

  const _CircleActionButton({
    required this.background,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MethodTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppGradients.horizontal,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _HumanPartnerPageState._primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
