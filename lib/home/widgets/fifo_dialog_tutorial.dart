import 'dart:ui';
import 'package:flutter/material.dart';

class FifoDialogs {
  static void showTutorial(BuildContext context, Color primaryColor) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          backgroundColor: cs.surface,
          title: Text(
            "USER GUIDE",
            style: TextStyle(
              color: primaryColor,
              letterSpacing: 2,
              fontSize: 14,
            ),
          ),
          content: Text(
            "1. Set Page String & Frames\n"
            "2. Click INITIALIZE\n"
            "3. Use media keys to control memory cycle",
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("GOT IT", style: TextStyle(color: primaryColor)),
            ),
          ],
        ),
      ),
    );
  }
}
