import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'fifo_widgets.dart';

class FifoInputPanel extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController pageController;
  final TextEditingController frameController;
  final Color primaryColor;
  final VoidCallback onCalculate;
  final VoidCallback onClear;

  const FifoInputPanel({
    super.key,
    required this.formKey,
    required this.pageController,
    required this.frameController,
    required this.primaryColor,
    required this.onCalculate,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: FifoWidgets.glassContainer(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page String Input
            Expanded(
              flex: 4,
              child: TextFormField(
                controller: pageController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
                ],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputStyle("PAGE STRING (Ex - 1 2 4 6 9)"),
                validator: (val) =>
                (val == null || val.isEmpty) ? "Please enter numbers" : null,
              ),
            ),
            const SizedBox(width: 20),
            // Frames Input
            Expanded(
              child: TextFormField(
                controller: frameController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: _inputStyle("FRAMES"),
                validator: (val) =>
                (val == null || val.isEmpty) ? "Required" : null,
              ),
            ),
            const SizedBox(width: 15),
            // Run Button
            FifoWidgets.largeActionButton(
              icon: Icons.bolt,
              color: primaryColor,
              onPressed: onCalculate,
              tooltip: "Run Simulator",
            ),
            const SizedBox(width: 10),
            // Reset Button
            FifoWidgets.largeActionButton(
              icon: Icons.refresh_rounded,
              color: Colors.redAccent,
              onPressed: onClear,
              tooltip: "System Reset",
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: Colors.white38,
      fontSize: 13,
      letterSpacing: 1.2,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white10),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: primaryColor, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Colors.white.withOpacity(0.02),
  );
}