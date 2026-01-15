import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class _FifoStep {
  final int page;
  final List<int?> frames;
  final bool isHit;
  _FifoStep({required this.page, required this.frames, required this.isHit});
}

class FifoHome extends StatefulWidget {
  const FifoHome({super.key});
  @override
  State<FifoHome> createState() => _FifoHomeState();
}

class _FifoHomeState extends State<FifoHome> with TickerProviderStateMixin {
  final TextEditingController pageController = TextEditingController();
  final TextEditingController frameController = TextEditingController();

  List<_FifoStep> allSteps = [];
  List<_FifoStep> visibleSteps = [];
  int currentStep = 0;
  Timer? playTimer;
  bool isPlaying = false;

  // Modern Color Palette
  final Color primaryColor = const Color(0xFF00E5FF); // Neon Cyan
  final Color bgDark = const Color(0xFF0D1117);     // GitHub Dark
  final Color glassColor = Colors.white.withOpacity(0.05);

  void calculateFIFO() {
    if (pageController.text.isEmpty || frameController.text.isEmpty) return;
    final pages = pageController.text.trim().split(RegExp(r'\s+')).map(int.parse).toList();
    final frameCount = int.tryParse(frameController.text) ?? 3;

    List<int?> frames = List.filled(frameCount, null);
    int pointer = 0;
    allSteps.clear();
    visibleSteps.clear();
    currentStep = 0;

    for (int page in pages) {
      bool hit = frames.contains(page);
      if (!hit) {
        frames[pointer] = page;
        pointer = (pointer + 1) % frameCount;
      }
      allSteps.add(_FifoStep(page: page, frames: List.from(frames), isHit: hit));
    }
    setState(() {});
  }

  void nextStep() {
    if (currentStep < allSteps.length) {
      setState(() {
        visibleSteps.add(allSteps[currentStep]);
        currentStep++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int hits = visibleSteps.where((s) => s.isHit).length;
    int misses = visibleSteps.where((s) => !s.isHit).length;

    return Scaffold(
      backgroundColor: bgDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            colors: [primaryColor.withOpacity(0.1), bgDark],
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildInputSection(),
                const SizedBox(height: 20),
                _buildStats(hits, misses),
                const SizedBox(height: 20),
                Expanded(child: _buildVisualizer()),
                _buildControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text("MEMORY KERNEL V2.0", style: TextStyle(color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.bold)),
        Text("FIFO Page Replacement Simulator", style: TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildInputSection() {
    return _glassMorphicContainer(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: pageController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Page String (e.g. 7 0 1 2)"),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: frameController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Frames"),
            ),
          ),
          const SizedBox(width: 15),
          ElevatedButton(
            onPressed: calculateFIFO,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.black),
            child: const Text("INITIALIZE"),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int hits, int misses) {
    double ratio = visibleSteps.isEmpty ? 0 : (hits / visibleSteps.length) * 100;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statTile("HITS", hits.toString(), Colors.greenAccent),
        _statTile("MISSES", misses.toString(), Colors.redAccent),
        _statTile("RATIO", "${ratio.toStringAsFixed(1)}%", primaryColor),
      ],
    );
  }

  Widget _buildVisualizer() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: visibleSteps.length,
      itemBuilder: (context, index) {
        final step = visibleSteps[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          margin: const EdgeInsets.only(right: 12),
          width: 80,
          child: Column(
            children: [
              CircleAvatar(backgroundColor: step.isHit ? Colors.green : Colors.red, radius: 15, child: Text(step.isHit ? "H" : "M", style: const TextStyle(fontSize: 10, color: Colors.white))),
              const SizedBox(height: 10),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text(step.page.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              ...step.frames.map((f) => Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                height: 40,
                width: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(4), color: f == step.page ? primaryColor.withOpacity(0.4) : Colors.transparent),
                child: Text(f?.toString() ?? "-", style: const TextStyle(color: Colors.white70)),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(onPressed: () => setState(() => visibleSteps.clear()), icon: const Icon(Icons.refresh, color: Colors.white)),
          const SizedBox(width: 20),
          FloatingActionButton.extended(
            onPressed: nextStep,
            label: const Text("NEXT CYCLE"),
            icon: const Icon(Icons.arrow_forward_ios),
            backgroundColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _glassMorphicContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: glassColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
          child: child,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
  );

  Widget _statTile(String label, String value, Color color) => Column(
    children: [
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
    ],
  );
}
