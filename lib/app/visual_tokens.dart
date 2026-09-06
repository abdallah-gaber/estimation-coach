import 'package:flutter/material.dart';

/// Only the shared values needed by the first card surface.
abstract final class VisualTokens {
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const table = Color(0xFF164D40);
  static const paper = Color(0xFFF6F7F2);
  static const ink = Color(0xFF172F29);
  static const accent = Color(0xFFF0CF83);
  static const rank = TextStyle(fontSize: 26, fontWeight: FontWeight.w700);
  static const suit = TextStyle(fontSize: 38, height: 1.1);
}
