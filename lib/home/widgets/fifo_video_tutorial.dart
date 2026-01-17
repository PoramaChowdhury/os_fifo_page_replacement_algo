// import 'dart:async';
// import 'package:flutter/material.dart';
//
// class FifoVideoTutorial extends StatefulWidget {
//   const FifoVideoTutorial({super.key});
//
//   @override
//   State<FifoVideoTutorial> createState() => _FifoVideoTutorialState();
// }
//
// class _FifoVideoTutorialState extends State<FifoVideoTutorial> {
//   int currentStep = 0;
//   Timer? timer;
//   bool isPlaying = true;
//
//   final Color primaryColor = const Color(0xFF00E5FF);
//
//   final List<String> narration = [
//     "FIFO starts with empty memory frames.",
//     "Page 1 enters memory — MISS.",
//     "Page 2 enters memory — MISS.",
//     "Page 3 enters memory — MISS.",
//     "Page 4 arrives — Page 1 is replaced (FIFO).",
//     "Page 2 is accessed again — HIT.",
//     "FIFO always removes the oldest page first."
//   ];
//
//   final List<List<int?>> frames = [
//     [null, null, null],
//     [1, null, null],
//     [1, 2, null],
//     [1, 2, 3],
//     [4, 2, 3],
//     [4, 2, 3],
//     [4, 2, 3],
//   ];
//
//   final List<int?> replacedPage = [
//     null,
//     null,
//     null,
//     null,
//     1,
//     null,
//     null,
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _startPlayback();
//   }
//
//   void _startPlayback() {
//     timer?.cancel();
//     timer = Timer.periodic(const Duration(seconds: 5), (_) {
//       if (currentStep < frames.length - 1) {
//         setState(() => currentStep++);
//       } else {
//         timer?.cancel();
//         setState(() => isPlaying = false);
//       }
//     });
//   }
//
//   void _togglePlay() {
//     setState(() {
//       isPlaying = !isPlaying;
//       if (isPlaying) {
//         _startPlayback();
//       } else {
//         timer?.cancel();
//       }
//     });
//   }
//
//   void _restart() {
//     timer?.cancel();
//     setState(() {
//       currentStep = 0;
//       isPlaying = true;
//     });
//     _startPlayback();
//   }
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       appBar: AppBar(
//         title: const Text("FIFO Video Tutorial"),
//         backgroundColor: Colors.black,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => Navigator.pop(context),
//           )
//         ],
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text(
//             "MEMORY FRAMES",
//             style: TextStyle(
//               color: Colors.white38,
//               letterSpacing: 3,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           /// FRAME ANIMATION
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(
//               frames[currentStep].length,
//                   (i) => _frameBox(
//                 value: frames[currentStep][i],
//                 isReplaced: replacedPage[currentStep] ==
//                     frames[currentStep][i],
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 40),
//
//           /// NARRATION (LIKE VIDEO SUBTITLES)
//           Container(
//             padding: const EdgeInsets.all(16),
//             margin: const EdgeInsets.symmetric(horizontal: 30),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.4),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 500),
//               child: Text(
//                 narration[currentStep],
//                 key: ValueKey(currentStep),
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: Colors.white70,
//                   fontSize: 18,
//                   height: 1.4,
//                 ),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 40),
//
//           /// VIDEO CONTROLS
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.replay),
//                 color: Colors.white70,
//                 iconSize: 30,
//                 onPressed: _restart,
//               ),
//               const SizedBox(width: 20),
//               CircleAvatar(
//                 radius: 28,
//                 backgroundColor: primaryColor,
//                 child: IconButton(
//                   icon: Icon(
//                     isPlaying ? Icons.pause : Icons.play_arrow,
//                     color: Colors.black,
//                     size: 30,
//                   ),
//                   onPressed: _togglePlay,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _frameBox({int? value, bool isReplaced = false}) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 600),
//       margin: const EdgeInsets.symmetric(horizontal: 10),
//       height: 70,
//       width: 70,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: isReplaced
//             ? Colors.redAccent.withOpacity(0.6)
//             : value == null
//             ? Colors.white10
//             : primaryColor.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: isReplaced ? Colors.redAccent : primaryColor,
//           width: 2,
//         ),
//       ),
//       child: Text(
//         value?.toString() ?? "-",
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }
///working
// import 'dart:async';
// import 'package:flutter/material.dart';
//
// class FifoVideoTutorial extends StatefulWidget {
//   const FifoVideoTutorial({super.key});
//
//   @override
//   State<FifoVideoTutorial> createState() => _FifoVideoTutorialState();
// }
//
// class _FifoVideoTutorialState extends State<FifoVideoTutorial> {
//   int currentStep = 0;
//   Timer? timer;
//   bool isPlaying = true;
//   bool _showPointer = true;
//
//   final Color primaryColor = const Color(0xFF00E5FF);
//
//   /// Narration (subtitles)
//   final List<String> narration = [
//     "FIFO starts with empty memory frames.",
//     "Page 1 enters memory — MISS.",
//     "Page 2 enters memory — MISS.",
//     "Page 3 enters memory — MISS.",
//     "Page 4 arrives — Page 1 is replaced (FIFO).",
//     "Page 2 is accessed again — HIT.",
//     "FIFO always removes the oldest page first.",
//   ];
//
//   /// FIFO Theory / Instructions
//   final String fifoTheory = """
// FIFO (First-In-First-Out) Page Replacement Algorithm:
//
// • Pages are loaded into memory frames in order.
// • The page that enters first is removed first.
// • A MISS occurs when a page is not found in memory.
// • A HIT occurs when a page already exists in memory.
// • FIFO does not consider page usage frequency.
//
// Color Legend:
// 🟢 Green  → HIT
// 🔵 Blue   → MISS (new page)
// 🔴 Red    → Page Replacement
// ⚪ White  → Empty frame
// 🎯 Arrow → FIFO pointer (oldest page)
// """;
//
//   /// Frame states per step
//   final List<List<int?>> frames = [
//     [null, null, null],
//     [1, null, null],
//     [1, 2, null],
//     [1, 2, 3],
//     [4, 2, 3],
//     [4, 2, 3],
//     [4, 2, 3],
//   ];
//
//   /// Accessed page per step
//   final List<int?> accessedPage = [null, 1, 2, 3, 4, 2, null];
//
//   /// Replacement indicator
//   final List<bool> isReplacementStep =
//   [false, false, false, false, true, false, false];
//
//   /// FIFO pointer position
//   final List<int> fifoPointer = [0, 0, 1, 2, 0, 1, 1];
//
//   @override
//   void initState() {
//     super.initState();
//     _startPlayback();
//   }
//
//   void _startPlayback() {
//     timer?.cancel();
//     timer = Timer.periodic(const Duration(seconds: 3), (_) async {
//       if (currentStep < frames.length - 1) {
//         setState(() => _showPointer = false);
//
//         await Future.delayed(const Duration(milliseconds: 600));
//
//         setState(() {
//           currentStep++;
//           _showPointer = true;
//         });
//       } else {
//         timer?.cancel();
//         setState(() => isPlaying = false);
//       }
//     });
//   }
//
//   void _togglePlay() {
//     setState(() {
//       isPlaying = !isPlaying;
//       isPlaying ? _startPlayback() : timer?.cancel();
//     });
//   }
//
//   void _restart() {
//     timer?.cancel();
//     setState(() {
//       currentStep = 0;
//       isPlaying = true;
//       _showPointer = true;
//     });
//     _startPlayback();
//   }
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isHitStep =
//     narration[currentStep].toUpperCase().contains("HIT");
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       appBar: AppBar(
//         title: const Text("FIFO Video Tutorial"),
//         backgroundColor: Colors.black,
//       ),
//       body: Row(
//         children: [
//           /// LEFT — ANIMATION AREA
//           Expanded(
//             flex: 2,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   "MEMORY FRAMES",
//                   style: TextStyle(
//                     color: Colors.white38,
//                     letterSpacing: 3,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//
//                 /// Replacement Arrow
//                 SizedBox(
//                   height: 40,
//                   child: isReplacementStep[currentStep]
//                       ? const Icon(Icons.arrow_downward,
//                       size: 40, color: Colors.redAccent)
//                       : const SizedBox(),
//                 ),
//
//                 /// Frames
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                     frames[currentStep].length,
//                         (i) => Column(
//                       children: [
//                         /// FIFO Pointer
//                         AnimatedOpacity(
//                           opacity:
//                           (_showPointer && fifoPointer[currentStep] == i)
//                               ? 1
//                               : 0,
//                           duration: const Duration(milliseconds: 300),
//                           child: const Icon(
//                             Icons.arrow_drop_down,
//                             color: Colors.orangeAccent,
//                             size: 35,
//                           ),
//                         ),
//                         _frameBox(
//                           value: frames[currentStep][i],
//                           isReplaced: isReplacementStep[currentStep] &&
//                               fifoPointer[currentStep] == i,
//                           isHit: isHitStep &&
//                               accessedPage[currentStep] ==
//                                   frames[currentStep][i],
//                           isMiss: !isHitStep &&
//                               accessedPage[currentStep] ==
//                                   frames[currentStep][i],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 40),
//
//                 /// Subtitle
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 600),
//                   child: Container(
//                     key: ValueKey(currentStep),
//                     padding: const EdgeInsets.all(16),
//                     margin: const EdgeInsets.symmetric(horizontal: 30),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.4),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       narration[currentStep],
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                           color: Colors.white70, fontSize: 18),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 40),
//
//                 /// Controls
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.replay),
//                       color: Colors.white70,
//                       iconSize: 30,
//                       onPressed: _restart,
//                     ),
//                     const SizedBox(width: 20),
//                     CircleAvatar(
//                       radius: 28,
//                       backgroundColor: primaryColor,
//                       child: IconButton(
//                         icon: Icon(
//                           isPlaying ? Icons.pause : Icons.play_arrow,
//                           color: Colors.black,
//                           size: 30,
//                         ),
//                         onPressed: _togglePlay,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           /// RIGHT — THEORY / INSTRUCTION BOX
//           Expanded(
//             flex: 1,
//             child: Container(
//               margin: const EdgeInsets.all(20),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.45),
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: Colors.white24),
//               ),
//               child: SingleChildScrollView(
//                 child: Text(
//                   fifoTheory,
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                     height: 1.5,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// FRAME BOX
//   Widget _frameBox({
//     int? value,
//     bool isReplaced = false,
//     bool isHit = false,
//     bool isMiss = false,
//   }) {
//     Color bgColor;
//     Color borderColor;
//
//     if (value == null) {
//       bgColor = Colors.white.withOpacity(0.08);
//       borderColor = Colors.white24;
//     } else if (isReplaced) {
//       bgColor = Colors.redAccent.withOpacity(0.6);
//       borderColor = Colors.redAccent;
//     } else if (isHit) {
//       bgColor = Colors.greenAccent.withOpacity(0.45);
//       borderColor = Colors.greenAccent;
//     } else if (isMiss) {
//       bgColor = primaryColor.withOpacity(0.45);
//       borderColor = primaryColor;
//     } else {
//       bgColor = Colors.white.withOpacity(0.12);
//       borderColor = Colors.white24;
//     }
//
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 600),
//       margin: const EdgeInsets.symmetric(horizontal: 10),
//       height: 55,
//       width: 85,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: borderColor, width: 2),
//       ),
//       child: Text(
//         value?.toString() ?? "-",
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

///new
import 'dart:async';
import 'package:fifo_page_replacemnt/app/theme_service.dart';
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

  /// Narration (subtitles)
  final List<String> narration = [
    "FIFO starts with empty memory frames.",
    "Page 1 enters memory — MISS.",
    "Page 2 enters memory — MISS.",
    "Page 3 enters memory — MISS.",
    "Page 4 arrives — Page 1 is replaced (FIFO).",
    "Page 2 is accessed again — HIT.",
    "FIFO always removes the oldest page first.",
  ];

  /// FIFO Theory / Instructions
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

  /// Frame states per step
  final List<List<int?>> frames = [
    [null, null, null],
    [1, null, null],
    [1, 2, null],
    [1, 2, 3],
    [4, 2, 3],
    [4, 2, 3],
    [4, 2, 3],
  ];

  /// Accessed page per step
  final List<int?> accessedPage = [null, 1, 2, 3, 4, 2, null];

  /// Replacement indicator
  final List<bool> isReplacementStep = [false, false, false, false, true, false, false];

  /// FIFO pointer position
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
        final bool isHitStep = narration[currentStep].toUpperCase().contains("HIT");

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              "FIFO Video Tutorial",
              style: GoogleFonts.zalandoSans (
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),

            ),
            elevation: 0,
          ),
          body: Row(
            children: [
              /// LEFT — ANIMATION AREA
              Expanded(
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

                    /// Replacement Arrow
                    SizedBox(
                      height: 40,
                      child: isReplacementStep[currentStep]
                          ? Icon(
                        Icons.arrow_downward,
                        size: 40,
                        color: AppColors.error,
                      )
                          : const SizedBox(),
                    ),

                    /// Frames
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        frames[currentStep].length,
                            (i) => Column(
                          children: [
                            /// FIFO Pointer
                            AnimatedOpacity(
                              opacity: (_showPointer && fifoPointer[currentStep] == i) ? 1 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.warning,
                                size: 35,
                              ),
                            ),
                            _frameBox(
                              value: frames[currentStep][i],
                              isReplaced: isReplacementStep[currentStep] && fifoPointer[currentStep] == i,
                              isHit: isHitStep && accessedPage[currentStep] == frames[currentStep][i],
                              isMiss: !isHitStep && accessedPage[currentStep] == frames[currentStep][i],
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// Subtitle
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
                    /// Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay),
                          color: isDark ? Colors.white70 : Colors.black54,
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
              ),

              /// RIGHT — THEORY / INSTRUCTION BOX
              Expanded(
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
              ),
            ],
          ),
        );
      },
    );
  }

  /// FRAME BOX - THEME AWARE
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
      bgColor = isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.grey.shade200;   // 👈 visible light-mode bg

      borderColor = isDark
          ? Colors.white24
          : Colors.grey.shade400;  // 👈 visible border

      textColor = isDark
          ? Colors.white70
          : Colors.black54;
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
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
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



