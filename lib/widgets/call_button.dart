import 'package:flutter/material.dart';

class CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color iconColor;
  final VoidCallback onPressed;

  const CallButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.background = Colors.white24,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: background, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 26),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
