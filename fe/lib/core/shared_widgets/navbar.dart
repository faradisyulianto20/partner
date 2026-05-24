import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isPsychologist;

  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isPsychologist,
  });

  static const _color = Color(0xFF1B517A);

  @override
  Widget build(BuildContext context) {
    final _items = isPsychologist
        ? const [
            (icon: Icons.home, label: 'Home'),
            (icon: Icons.edit_note, label: 'Journal'),
            (icon: Icons.people, label: 'Client'),
            (icon: Icons.person, label: 'Profile'),
          ]
        : const [
            (icon: Icons.home, label: 'Home'),
            (icon: Icons.people, label: 'Partner'),
            (icon: Icons.edit_note, label: 'Journal'),
            (icon: Icons.person, label: 'Profile'),
          ];
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: 10 + bottomPadding,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _items.length,
          (i) => _navItem(_items[i].icon, _items[i].label, i),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? 18 : 8,
            vertical: 4,
          ),
          decoration: isActive
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color.fromARGB(106, 27, 81, 122),
                      Color(0xFFE6F3FD),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B517A).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 350),
                scale: isActive ? 1.15 : 1.0,
                curve: Curves.easeInOutCubic,
                child: Icon(
                  icon,
                  size: 35,
                  color: isActive ? _color : const Color(0xFF9E9E9E),
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 6),
                AnimatedOpacity(
                  opacity: isActive ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      color: _color,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
