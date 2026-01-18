
import 'dart:ui';
import 'package:flutter/material.dart';

class FifoWidgets {
  static Widget glassContainer({
    required Widget child,
    required EdgeInsets margin,
  }) {
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;

        return Container(
          margin: margin,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surface.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: cs.onSurface.withOpacity(0.12),
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget statBox(String label, String value, Color color) {
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;

        return Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withOpacity(0.45),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget largeActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: IconButton(
          icon: Icon(icon, color: color, size: 28),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
