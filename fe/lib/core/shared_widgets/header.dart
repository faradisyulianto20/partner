import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/state/user_role_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Header extends StatelessWidget {
  final String userName;
  final String greeting;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const Header({
    super.key,
    this.userName = 'User',
    this.greeting = 'Selamat Pagi',
    this.onProfileTap,
    this.onNotificationTap
  });

  String _buildGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi';
    }
    if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    }
    if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    }
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final displayName = user?.userMetadata?['full_name'] ?? user?.email;
    final resolvedUserName = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : userName;
    final avatarUrl =
        user?.userMetadata?['avatar_url'] ??
        user?.userMetadata?['picture'] ??
        '';
    final resolvedGreeting = _buildGreeting();
    final VoidCallback resolvedProfileTap =
        onProfileTap ??
        () {
          final destination = userRoleState.isPsychologist
              ? '/psychologist/profile'
              : '/profile';
          context.push(destination);
        };
    final horizontalGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: const [Color(0xFF578BB3), Color(0xFF194F78)],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: horizontalGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resolvedGreeting + ', ' + resolvedUserName,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bagaimana perasaanmu hari ini?',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onNotificationTap ?? () {
                  // Handle notification tap
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: Color(0xFF1B517A),
                    size: 28,
                  ),
                ),
              ),
              SizedBox(width: 12),
              GestureDetector(
                onTap: resolvedProfileTap,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: avatarUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 28,
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
