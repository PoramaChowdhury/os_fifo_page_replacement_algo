
import 'dart:async';
import 'package:fifo_page_replacemnt/app/theme_service.dart';
import 'package:fifo_page_replacemnt/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fifo_page_replacemnt/app/app_colors.dart';

class FifoVideoTutorial extends StatefulWidget {
  const FifoVideoTutorial({super.key});

  @override
  State createState() => _FifoVideoTutorialState();
}

class _FifoVideoTutorialState extends State<FifoVideoTutorial> {
  int currentStep = 0;
  Timer? timer;
  bool isPlaying = true;
  bool _showPointer = true;

  final List<String> narration = [
    "FIFO starts with empty memory frames.",
    "Page 1 enters memory — MISS.",
    "Page 2 enters memory — MISS.",
    "Page 3 enters memory — MISS.",
    "Page 4 arrives — Page 1 is replaced (FIFO).",
    "Page 2 is accessed again — HIT.",
    "FIFO always removes the oldest page first.",
  ];

  final String fifoTheory = """
FIFO (First-In-First-Out) Page Replacement Algorithm:

• Pages are loaded into memory frames in order.
• The page that enters first is removed first.
• A MISS occurs when a page is not found in memory.
• A HIT occurs when a page already exists in memory.
• FIFO does not consider page usage frequency.

Color Legend:
🟢 Green → HIT
🔵 Blue → MISS (new page)
🔴 Red → Page Replacement
⚪ White → Empty frame
🎯 Arrow → FIFO pointer (oldest page)
""";

  final List<List<int?>> frames = [
    [null, null, null],
    [1, null, null],
    [1, 2, null],
    [1, 2, 3],
    [4, 2, 3],
    [4, 2, 3],
    [4, 2, 3],
  ];

  final List<int?> accessedPage = [null, 1, 2, 3, 4, 2, null];
  final List<bool> isReplacementStep = [
    false,
    false,
    false,
    false,
    true,
    false,
    false,
  ];
  final List<int> fifoPointer = [0, 0, 1, 2, 0, 1, 1];

  @override
  void initState() {
    super.initState();
    _startPlayback();
  }

  void _startPlayback() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (currentStep < frames.length - 1) {
        setState(() => _showPointer = false);
        await Future.delayed(const Duration(milliseconds: 600));
        setState(() {
          currentStep++;
          _showPointer = true;
        });
      } else {
        timer?.cancel();
        setState(() => isPlaying = false);
      }
    });
  }

  void _togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
      isPlaying ? _startPlayback() : timer?.cancel();
    });
  }

  void _restart() {
    timer?.cancel();
    setState(() {
      currentStep = 0;
      isPlaying = true;
      _showPointer = true;
    });
    _startPlayback();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final bool isDark = themeService.isDarkMode;
        final bool isHitStep = narration[currentStep].toUpperCase().contains(
          "HIT",
        );
        final bool isMobile = Responsive.isMobile(context);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              "FIFO Video Tutorial",
              style: GoogleFonts.zalandoSans(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevation: 0,
          ),
          body: SafeArea(
            child: isMobile
                ? Column(
                    children: [
                      _animationPanel(isDark, isHitStep),
                      _theoryPanel(isDark),
                    ],
                  )
                : Row(
                    children: [
                      _animationPanel(isDark, isHitStep),
                      _theoryPanel(isDark),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _animationPanel(bool isDark, bool isHitStep) {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "MEMORY FRAMES",
            style: GoogleFonts.nunitoSans(
              color: isDark ? Colors.white38 : Colors.black54,
              letterSpacing: 4,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 40,
            child: isReplacementStep[currentStep]
                ? const Icon(
                    Icons.arrow_downward,
                    size: 40,
                    color: AppColors.error,
                  )
                : const SizedBox(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              frames[currentStep].length,
              (i) => Column(
                children: [
                  AnimatedOpacity(
                    opacity: (_showPointer && fifoPointer[currentStep] == i)
                        ? 1
                        : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.warning,
                      size: 35,
                    ),
                  ),
                  _frameBox(
                    value: frames[currentStep][i],
                    isReplaced:
                        isReplacementStep[currentStep] &&
                        fifoPointer[currentStep] == i,
                    isHit:
                        isHitStep &&
                        accessedPage[currentStep] == frames[currentStep][i],
                    isMiss:
                        !isHitStep &&
                        accessedPage[currentStep] == frames[currentStep][i],
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: Container(
              key: ValueKey(currentStep),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                narration[currentStep],
                textAlign: TextAlign.center,
                style: GoogleFonts.charisSil(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 30,
                onPressed: _restart,
              ),
              const SizedBox(width: 20),
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryCyan,
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: _togglePlay,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _theoryPanel(bool isDark) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withOpacity(0.45)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey.shade200,
          ),
        ),
        child: SingleChildScrollView(
          child: Text(
            fifoTheory,
            style: GoogleFonts.rubik(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _frameBox({
    int? value,
    bool isReplaced = false,
    bool isHit = false,
    bool isMiss = false,
    required bool isDark,
  }) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (value == null) {
      bgColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;
      borderColor = isDark ? Colors.white24 : Colors.grey.shade400;
      textColor = isDark ? Colors.white70 : Colors.black54;
    } else if (isReplaced) {
      bgColor = AppColors.error.withOpacity(0.6);
      borderColor = AppColors.error;
      textColor = Colors.white;
    } else if (isHit) {
      bgColor = AppColors.success.withOpacity(0.45);
      borderColor = AppColors.success;
      textColor = Colors.white;
    } else if (isMiss) {
      bgColor = AppColors.primaryCyan.withOpacity(0.45);
      borderColor = AppColors.primaryCyan;
      textColor = Colors.white;
    } else {
      bgColor = Colors.white.withOpacity(isDark ? 0.12 : 0.2);
      borderColor = Colors.white24;
      textColor = isDark ? Colors.white70 : Colors.black54;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 55,
      width: 85,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Text(
        value?.toString() ?? "-",
        style: GoogleFonts.nunitoSans(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
