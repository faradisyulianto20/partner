import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.titleColor = const Color(0xFF1B517A),
    this.iconColor = const Color(0xFF1B517A),
    this.titleStyle,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final EdgeInsets padding;
  final Color titleColor;
  final Color iconColor;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final TextStyle? resolvedTitleStyle =
        titleStyle ??
        Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: titleColor,
        );

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (onBack != null)
              IconButton(
                onPressed: onBack,
                icon: Icon(Icons.arrow_back_ios, color: iconColor),
              )
            else
              const SizedBox(width: 48),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: resolvedTitleStyle,
              ),
            ),
            SizedBox(width: 48, child: Center(child: trailing)),
          ],
        ),
      ),
    );
  }
}
