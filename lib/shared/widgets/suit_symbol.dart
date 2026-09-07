import 'package:flutter/material.dart';

import '../../core/cards/cards.dart';

/// Font-independent card marks, including on offline Flutter web builds.
class SuitSymbol extends StatelessWidget {
  const SuitSymbol({
    super.key,
    required this.suit,
    required this.color,
    required this.size,
  });
  final Suit suit;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _SuitPainter(suit, color));
}

class _SuitPainter extends CustomPainter {
  const _SuitPainter(this.suit, this.color);
  final Suit suit;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final paint = Paint()..color = color;
    final path = Path();
    switch (suit) {
      case Suit.diamonds:
        path.moveTo(50, 2);
        path.lineTo(88, 50);
        path.lineTo(50, 98);
        path.lineTo(12, 50);
        path.close();
      case Suit.hearts:
        path.moveTo(50, 94);
        path.cubicTo(36, 77, 4, 55, 4, 30);
        path.cubicTo(4, 1, 37, -2, 50, 23);
        path.cubicTo(63, -2, 96, 1, 96, 30);
        path.cubicTo(96, 55, 64, 77, 50, 94);
        path.close();
      case Suit.spades:
        path.moveTo(50, 2);
        path.cubicTo(36, 21, 5, 41, 5, 62);
        path.cubicTo(5, 84, 34, 90, 46, 69);
        path.cubicTo(45, 83, 40, 93, 32, 98);
        path.lineTo(68, 98);
        path.cubicTo(60, 93, 55, 83, 54, 69);
        path.cubicTo(66, 90, 95, 84, 95, 62);
        path.cubicTo(95, 41, 64, 21, 50, 2);
        path.close();
      case Suit.clubs:
        canvas.drawCircle(const Offset(50, 26), 24, paint);
        canvas.drawCircle(const Offset(27, 59), 24, paint);
        canvas.drawCircle(const Offset(73, 59), 24, paint);
        path.moveTo(45, 50);
        path.lineTo(55, 50);
        path.cubicTo(54, 76, 58, 89, 69, 98);
        path.lineTo(31, 98);
        path.cubicTo(42, 89, 46, 76, 45, 50);
        path.close();
    }
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SuitPainter oldDelegate) =>
      oldDelegate.suit != suit || oldDelegate.color != color;
}
