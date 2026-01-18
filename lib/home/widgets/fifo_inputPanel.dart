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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;

        return Form(
          key: formKey,
          child: FifoWidgets.glassContainer(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
          ),
        );
      },
    );
  }


  Widget _buildMobileLayout() {
    return Column(
      children: [
        Row(children: [Expanded(child: _pageInput())]),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _frameInput()),
            const SizedBox(width: 12),
            _runButton(),
            const SizedBox(width: 10),
            _resetButton(),
          ],
        ),
      ],
    );
  }


  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: _pageInput()),
        const SizedBox(width: 20),
        Expanded(child: _frameInput()),
        const SizedBox(width: 15),
        _runButton(),
        const SizedBox(width: 10),
        _resetButton(),
      ],
    );
  }


  Widget _pageInput() => TextFormField(
    controller: pageController,
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]'))],
    decoration: const InputDecoration(
      labelText: "PAGE STRING (Ex - 1 2 4 6 9)",
    ),
    validator: (val) =>
        (val == null || val.isEmpty) ? "Please enter numbers" : null,
  );

  Widget _frameInput() => TextFormField(
    controller: frameController,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: const InputDecoration(labelText: "Frames"),
    validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
  );

  Widget _runButton() => FifoWidgets.largeActionButton(
    icon: Icons.bolt,
    color: primaryColor,
    onPressed: onCalculate,
    tooltip: "Run Simulator",
  );

  Widget _resetButton() => FifoWidgets.largeActionButton(
    icon: Icons.refresh_rounded,
    color: Colors.redAccent,
    onPressed: onClear,
    tooltip: "System Reset",
  );
}
