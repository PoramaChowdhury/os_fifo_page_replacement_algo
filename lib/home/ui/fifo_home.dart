// import 'dart:async';
// import 'dart:ui';
// import 'package:fifo_page_replacemnt/app/theme_service.dart';
// import 'package:fifo_page_replacemnt/database/database_service.dart';
// import 'package:fifo_page_replacemnt/home/widgets/fifo_video_tutorial.dart';
// import 'package:fifo_page_replacemnt/home/widgets/fifo_dialog_tutorial.dart';
// import 'package:fifo_page_replacemnt/home/widgets/fifo_history_sheet.dart';
// import 'package:fifo_page_replacemnt/home/widgets/fifo_inputPanel.dart';
// import 'package:fifo_page_replacemnt/fifo%20calculator/fifo_logic.dart';
// import 'package:fifo_page_replacemnt/home/widgets/fifo_memory.dart';
// import 'package:fifo_page_replacemnt/model/fifo_model.dart';
// import 'package:fifo_page_replacemnt/home/widgets/fifo_stats_dashboard_widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../widgets/fifo_widgets.dart';
//
//
// class FifoHome extends StatefulWidget {
//   const FifoHome({super.key});
//
//   @override
//   State<FifoHome> createState() => _FifoHomeState();
// }
//
// class _FifoHomeState extends State<FifoHome> {
//   final TextEditingController _pageController = TextEditingController(text: "");
//   final TextEditingController _frameController = TextEditingController(
//     text: "",
//   );
//   final ScrollController _horizontalController = ScrollController();
//
//   List<FifoStep> allSteps = [];
//   List<FifoStep> visibleSteps = [];
//   int currentStep = 0;
//   Timer? playTimer;
//   bool isPlaying = false;
//   String replacementLog = "INITIALIZE  TO BEGIN";
//
//   final Color primaryColor = const Color(0xFF00E5FF);
//   final Color bgDark = const Color(0xFF0D1117);
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _showTutorial());
//   }
//
//   Future<void> saveHistory() async {
//     final status = await DatabaseService.saveHistory(
//       pages: _pageController.text,
//       frameCount: _frameController.text,
//       allSteps: allSteps,
//     );
//     setState(() => replacementLog = status);
//   }
//
//   void _showHistoryList() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: bgDark,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => FifoHistorySheet(
//         bgDark: bgDark,
//         primaryColor: primaryColor,
//         onHistorySelected: (pages, frames) {
//           setState(() {
//             _pageController.text = pages;
//             _frameController.text = frames;
//             calculateFIFO();
//           });
//         },
//       ),
//     );
//   }
//
//   void calculateFIFO() {
//     final results = FifoLogic.calculate(
//       pageInput: _pageController.text,
//       frameInput: _frameController.text,
//     );
//
//     setState(() {
//       allSteps = results['steps'];
//       visibleSteps.clear();
//       currentStep = 0;
//       replacementLog = results['log'];
//     });
//
//     if (allSteps.isNotEmpty) {
//       saveHistory();
//     }
//   }
//
//   void nextStep() {
//     if (currentStep < allSteps.length) {
//       setState(() {
//         visibleSteps.add(allSteps[currentStep]);
//         replacementLog = allSteps[currentStep].log;
//         currentStep++;
//       });
//       _scrollToEnd();
//     } else {
//       playTimer?.cancel();
//       setState(() => isPlaying = false);
//     }
//   }
//
//   void prevStep() {
//     if (currentStep > 0) {
//       setState(() {
//         visibleSteps.removeLast();
//         currentStep--;
//         replacementLog = currentStep > 0
//             ? allSteps[currentStep - 1].log
//             : "BACK AT START";
//       });
//     }
//   }
//
//   void skipToEnd() {
//     if (allSteps.isEmpty) calculateFIFO();
//     playTimer?.cancel();
//     setState(() {
//       visibleSteps = List.from(allSteps);
//       currentStep = allSteps.length;
//       isPlaying = false;
//       replacementLog = "FINAL STATE REACHED";
//     });
//     _scrollToEnd();
//   }
//
//   void clearAll() {
//     playTimer?.cancel();
//     setState(() {
//       _pageController.clear();
//       _frameController.clear();
//       visibleSteps.clear();
//       allSteps.clear();
//       currentStep = 0;
//       isPlaying = false;
//       replacementLog = "SYSTEM RESET COMPLETE";
//     });
//   }
//
//   void _scrollToEnd() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_horizontalController.hasClients) {
//         _horizontalController.animateTo(
//           _horizontalController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   void _showTutorial() {
//     FifoDialogs.showTutorial(context, primaryColor);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     int totalHits = visibleSteps.where((s) => s.isHit).length;
//     int totalMisses = visibleSteps.where((s) => !s.isHit).length;
//     double hitRatio = visibleSteps.isEmpty
//         ? 0
//         : (totalHits / visibleSteps.length) * 100;
//     double missRatio = visibleSteps.isEmpty
//         ? 0
//         : (totalMisses / visibleSteps.length) * 100;
//     final pages = _pageController.text
//         .trim()
//         .split(RegExp(r'\s+'))
//         .where((s) => s.isNotEmpty);
//     int uniquePages = pages
//         .map(int.tryParse)
//         .where((p) => p != null)
//         .toSet()
//         .length;
//
//     return Scaffold(
//       backgroundColor: bgDark,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildTopBar(),
//             FifoInputPanel(
//               formKey: _formKey,
//               pageController: _pageController,
//               frameController: _frameController,
//               primaryColor: primaryColor,
//               onCalculate: () {
//                 if (_formKey.currentState!.validate()) calculateFIFO();
//               },
//               onClear: clearAll,
//             ),
//             FifoDashboard(
//               hits: totalHits,
//               misses: totalMisses,
//               hitRatio: hitRatio,
//               missRatio: missRatio,
//               uniquePages: uniquePages,
//               primaryColor: primaryColor,
//             ),
//             _buildStatusBanner(),
//
//             Expanded(
//               child: FifoMemoryGrid(
//                 visibleSteps: visibleSteps,
//                 horizontalController: _horizontalController,
//                 primaryColor: primaryColor,
//               ),
//             ),
//             _buildMediaConsole(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Widget _buildTopBar() => Padding(
//   //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//   //   child: Row(
//   //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //     children: [
//   //       IconButton(
//   //         icon: const Icon(Icons.history, color: Colors.white70),
//   //         onPressed: _showHistoryList,
//   //       ),
//   //       Column(
//   //         children: [
//   //           Text(
//   //             " Page Replacement Algorithm",
//   //             style: TextStyle(
//   //               color: primaryColor,
//   //               letterSpacing: 4,
//   //               fontWeight: FontWeight.bold,
//   //               fontSize: 28,
//   //             ),
//   //           ),
//   //           Text(
//   //             "FIFO",
//   //             style: TextStyle(
//   //               color: primaryColor,
//   //               fontWeight: FontWeight.bold,
//   //               fontSize: 28,
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //       Row(
//   //         children: [
//   //           IconButton(
//   //             icon: const Icon(
//   //               Icons.play_circle_outline,
//   //               color: Colors.white70,
//   //             ),
//   //             tooltip: "FIFO Video Tutorial",
//   //             onPressed: () {
//   //               Navigator.push(
//   //                 context,
//   //                 MaterialPageRoute(
//   //                   builder: (_) => const FifoVideoTutorial(),
//   //                 ),
//   //               );
//   //             },
//   //           ),
//   //           IconButton(
//   //             icon: const Icon(Icons.logout, color: Colors.white70),
//   //             onPressed: () =>
//   //                 Supabase.instance.client.auth.signOut(),
//   //           ),
//   //         ],
//   //       ),
//   //     ],
//   //   ),
//   // );
//   Widget _buildTopBar() => Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         // Left: History Button
//         IconButton(
//           icon: Icon(Icons.history,
//             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//           ),
//           onPressed: _showHistoryList,
//         ),
//
//         // Center: Title (unchanged)
//         Column(
//           children: [
//             Text(
//               " Page Replacement Algorithm",
//               style: TextStyle(
//                 color: Theme.of(context).primaryColor,
//                 letterSpacing: 4,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 28,
//               ),
//             ),
//             Text(
//               "FIFO",
//               style: TextStyle(
//                 color: Theme.of(context).primaryColor,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 28,
//               ),
//             ),
//           ],
//         ),
//
//         // Right: 3 Buttons (Tutorial + THEME TOGGLE + Signout)
//         Row(
//           children: [
//             // 1. Tutorial Button (your original)
//             IconButton(
//               icon: const Icon(Icons.play_circle_outline, color: Colors.white70),
//               tooltip: "FIFO Video Tutorial",
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const FifoVideoTutorial()),
//                 );
//               },
//             ),
//
//             // 2. THEME TOGGLE BUTTON ⭐ NEW ⭐
//             Consumer<ThemeService>(
//               builder: (context, themeService, child) {
//                 return IconButton(
//                   icon: Icon(
//                     themeService.isDarkMode
//                         ? Icons.light_mode
//                         : Icons.dark_mode,
//                     color: Colors.white70,
//                     size: 26,
//                   ),
//                   onPressed: themeService.toggleTheme,
//                   tooltip: themeService.isDarkMode
//                       ? 'Switch to Light Mode'
//                       : 'Switch to Dark Mode',
//                 );
//               },
//             ),
//
//             // 3. Signout Button (your original)
//             IconButton(
//               icon: const Icon(Icons.logout, color: Colors.white70),
//               onPressed: () => Supabase.instance.client.auth.signOut(),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
//
//   Widget _buildStatusBanner() => Container(
//     width: double.infinity,
//     padding: const EdgeInsets.symmetric(vertical: 6),
//     color: primaryColor.withOpacity(0.1),
//     child: Text(
//       replacementLog,
//       textAlign: TextAlign.center,
//       style: TextStyle(
//         color: primaryColor,
//         fontSize: 12,
//         fontWeight: FontWeight.bold,
//         fontFamily: 'monospace',
//       ),
//     ),
//   );
//
//
//
//   Widget _buildMediaConsole() => FifoWidgets.glassContainer(
//     margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _mediaBtn(
//           Icons.first_page,
//           () => setState(() {
//             visibleSteps.clear();
//             currentStep = 0;
//           }),
//         ),
//         _mediaBtn(Icons.chevron_left, prevStep),
//         const SizedBox(width: 15),
//         GestureDetector(
//           onTap: () {
//             if (isPlaying) {
//               playTimer?.cancel();
//               setState(() => isPlaying = false);
//             } else {
//               if (currentStep >= allSteps.length) {
//                 visibleSteps.clear();
//                 currentStep = 0;
//               }
//               setState(() => isPlaying = true);
//               playTimer = Timer.periodic(
//                 const Duration(seconds: 1),
//                 (t) => nextStep(),
//               );
//             }
//           },
//           child: CircleAvatar(
//             radius: 25,
//             backgroundColor: primaryColor,
//             child: Icon(
//               isPlaying ? Icons.pause : Icons.play_arrow,
//               color: Colors.black,
//             ),
//           ),
//         ),
//         const SizedBox(width: 15),
//         _mediaBtn(Icons.chevron_right, nextStep),
//         _mediaBtn(Icons.last_page, skipToEnd),
//       ],
//     ),
//   );
//
//   Widget _mediaBtn(IconData icon, VoidCallback action) => IconButton(
//     icon: Icon(icon, color: Colors.white70),
//     onPressed: action,
//   );
// }
import 'dart:async';
import 'dart:ui';

import 'package:fifo_page_replacemnt/app/theme_service.dart';
import 'package:fifo_page_replacemnt/database/database_service.dart';
import 'package:fifo_page_replacemnt/home/widgets/fifo_video_tutorial.dart';
import 'package:fifo_page_replacemnt/home/widgets/fifo_dialog_tutorial.dart';
import 'package:fifo_page_replacemnt/home/widgets/fifo_history_sheet.dart';
import 'package:fifo_page_replacemnt/home/widgets/fifo_inputPanel.dart';
import 'package:fifo_page_replacemnt/fifo%20calculator/fifo_logic.dart';
import 'package:fifo_page_replacemnt/home/widgets/fifo_memory.dart';
import 'package:fifo_page_replacemnt/model/fifo_model.dart';
import 'package:fifo_page_replacemnt/home/widgets/fifo_stats_dashboard_widgets.dart';
import 'package:fifo_page_replacemnt/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/fifo_widgets.dart';
import '../../app/app_colors.dart';

class FifoHome extends StatefulWidget {
  const FifoHome({super.key});

  @override
  State<FifoHome> createState() => _FifoHomeState();
}

class _FifoHomeState extends State<FifoHome> {
  final TextEditingController _pageController = TextEditingController();
  final TextEditingController _frameController = TextEditingController();
  final ScrollController _horizontalController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  final Color primaryColor = AppColors.primaryCyan;

  List<FifoStep> allSteps = [];
  List<FifoStep> visibleSteps = [];
  int currentStep = 0;
  Timer? playTimer;
  bool isPlaying = false;
  String replacementLog = "INITIALIZE TO BEGIN";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showTutorial());
  }

  /* ---------------- HISTORY ---------------- */

  Future<void> saveHistory() async {
    final status = await DatabaseService.saveHistory(
      pages: _pageController.text,
      frameCount: _frameController.text,
      allSteps: allSteps,
    );
    setState(() => replacementLog = status);
  }

  void _showHistoryList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FifoHistorySheet(
        primaryColor: primaryColor,
        onHistorySelected: (pages, frames) {
          setState(() {
            _pageController.text = pages;
            _frameController.text = frames;
            calculateFIFO();
          });
        },
      ),
    );
  }

  /* ---------------- FIFO LOGIC ---------------- */

  void calculateFIFO() {
    final results = FifoLogic.calculate(
      pageInput: _pageController.text,
      frameInput: _frameController.text,
    );

    setState(() {
      allSteps = results['steps'];
      visibleSteps.clear();
      currentStep = 0;
      replacementLog = results['log'];
    });

    if (allSteps.isNotEmpty) saveHistory();
  }

  void nextStep() {
    if (currentStep < allSteps.length) {
      setState(() {
        visibleSteps.add(allSteps[currentStep]);
        replacementLog = allSteps[currentStep].log;
        currentStep++;
      });
      _scrollToEnd();
    } else {
      playTimer?.cancel();
      setState(() => isPlaying = false);
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      setState(() {
        visibleSteps.removeLast();
        currentStep--;
        replacementLog = currentStep > 0
            ? allSteps[currentStep - 1].log
            : "BACK AT START";
      });
    }
  }

  void skipToEnd() {
    if (allSteps.isEmpty) calculateFIFO();
    playTimer?.cancel();
    setState(() {
      visibleSteps = List.from(allSteps);
      currentStep = allSteps.length;
      isPlaying = false;
      replacementLog = "FINAL STATE REACHED";
    });
    _scrollToEnd();
  }

  void clearAll() {
    playTimer?.cancel();
    setState(() {
      _pageController.clear();
      _frameController.clear();
      visibleSteps.clear();
      allSteps.clear();
      currentStep = 0;
      isPlaying = false;
      replacementLog = "SYSTEM RESET COMPLETE";
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_horizontalController.hasClients) {
        _horizontalController.animateTo(
          _horizontalController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showTutorial() {
    FifoDialogs.showTutorial(context, primaryColor);
  }

  /* ---------------- BUILD ---------------- */

  @override
  Widget build(BuildContext context) {
    final int totalHits = visibleSteps.where((s) => s.isHit).length;
    final int totalMisses = visibleSteps.where((s) => !s.isHit).length;
    final double hitRatio =
    visibleSteps.isEmpty ? 0 : (totalHits / visibleSteps.length) * 100;
    final double missRatio =
    visibleSteps.isEmpty ? 0 : (totalMisses / visibleSteps.length) * 100;

    final pages = _pageController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty);

    final int uniquePages =
        pages.map(int.tryParse).whereType<int>().toSet().length;
    final isMobile = Responsive.isMobile(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // _buildTopBar(),
            _buildTopBar(isMobile),
            FifoInputPanel(
              formKey: _formKey,
              pageController: _pageController,
              frameController: _frameController,
              primaryColor: primaryColor,
              onCalculate: () {
                if (_formKey.currentState!.validate()) calculateFIFO();
              },
              onClear: clearAll,
            ),
            FifoDashboard(
              hits: totalHits,
              misses: totalMisses,
              hitRatio: hitRatio,
              missRatio: missRatio,
              uniquePages: uniquePages,
              primaryColor: primaryColor,
            ),
            _buildStatusBanner(),
            Expanded(
              child: FifoMemoryGrid(
                visibleSteps: visibleSteps,
                horizontalController: _horizontalController,
                primaryColor: primaryColor,
              ),
            ),
            // _buildMediaConsole(),
            _buildMediaConsole(isMobile),
          ],
        ),
      ),
    );
  }

  /* ---------------- UI PIECES ---------------- */

  // Widget _buildTopBar() => Padding(
  //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //   child: Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       IconButton(
  //         icon: Icon(
  //           Icons.history,
  //           color: Theme.of(context)
  //               .colorScheme
  //               .onSurface
  //               .withOpacity(0.7),
  //         ),
  //         onPressed: _showHistoryList,
  //       ),
  //       Column(
  //         children: [
  //           ShaderMask(
  //             shaderCallback: (bounds) {
  //               return LinearGradient(
  //                 colors: [
  //                   Theme.of(context).colorScheme.primary,
  //                   Theme.of(context).colorScheme.primary.withOpacity(0.7),
  //                 ],
  //               ).createShader(bounds);
  //             },
  //             child: Text(
  //               "PAGE REPLACEMENT ALGORITHM",
  //               style: GoogleFonts.ubuntu(
  //                 letterSpacing: 4,
  //                 fontWeight: FontWeight.w700,
  //                 fontSize: 28,
  //                 color: Colors.white, // required for ShaderMask
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 2),
  //           Text(
  //             "FIFO",
  //             style: GoogleFonts.oswald(
  //               color: Theme.of(context).colorScheme.primary,
  //               fontWeight: FontWeight.w900,
  //               fontSize: 26,
  //               letterSpacing: 4,
  //             ),
  //           ),
  //         ],
  //       ),
  //       Row(
  //         children: [
  //           IconButton(
  //             icon: Icon(
  //               Icons.play_circle_outline,
  //               color: Theme.of(context)
  //                   .colorScheme
  //                   .onSurface
  //                   .withOpacity(0.7),
  //             ),
  //             onPressed: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (_) => const FifoVideoTutorial(),
  //                 ),
  //               );
  //             },
  //           ),
  //           Consumer<ThemeService>(
  //             builder: (_, theme, __) => IconButton(
  //               icon: Icon(
  //                 theme.isDarkMode
  //                     ? Icons.light_mode
  //                     : Icons.dark_mode,
  //                 color: Theme.of(context)
  //                     .colorScheme
  //                     .onSurface
  //                     .withOpacity(0.7),
  //               ),
  //               onPressed: theme.toggleTheme,
  //             ),
  //           ),
  //           IconButton(
  //             icon: Icon(
  //               Icons.logout,
  //               color: Theme.of(context)
  //                   .colorScheme
  //                   .onSurface
  //                   .withOpacity(0.7),
  //             ),
  //             onPressed: () =>
  //                 Supabase.instance.client.auth.signOut(),
  //           ),
  //         ],
  //       ),
  //     ],
  //   ),
  // );
  Widget _buildTopBar(bool isMobile) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: isMobile
        ? Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.history), onPressed: _showHistoryList),
            const Text("FIFO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            IconButton(icon: const Icon(Icons.logout), onPressed: () => Supabase.instance.client.auth.signOut()),
          ],
        ),
      ],
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.history), onPressed: _showHistoryList),
        Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                ).createShader(bounds);
              },
              child: Text(
                "PAGE REPLACEMENT ALGORITHM",
                style: GoogleFonts.ubuntu(
                  letterSpacing: 4,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: Colors.white, // required for ShaderMask
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "FIFO",
              style: GoogleFonts.oswald(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: 26,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.play_circle_outline), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FifoVideoTutorial()));
            }),
            Consumer<ThemeService>(
              builder: (_, theme, __) => IconButton(
                icon: Icon(theme.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: theme.toggleTheme,
              ),
            ),
            IconButton(icon: const Icon(Icons.logout), onPressed: () => Supabase.instance.client.auth.signOut()),
          ],
        ),
      ],
    ),
  );
  Widget _buildStatusBanner() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 6),
    color:
    Theme.of(context).colorScheme.primary.withOpacity(0.12),
    child: Text(
      replacementLog,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    ),
  );

  // Widget _buildMediaConsole() => FifoWidgets.glassContainer(
  //   margin: const EdgeInsets.all(20),
  //   child: Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       _mediaBtn(Icons.first_page, () {
  //         visibleSteps.clear();
  //         currentStep = 0;
  //       }),
  //       _mediaBtn(Icons.chevron_left, prevStep),
  //       const SizedBox(width: 15),
  //       GestureDetector(
  //         onTap: () {
  //           if (isPlaying) {
  //             playTimer?.cancel();
  //             setState(() => isPlaying = false);
  //           } else {
  //             if (currentStep >= allSteps.length) {
  //               visibleSteps.clear();
  //               currentStep = 0;
  //             }
  //             setState(() => isPlaying = true);
  //             playTimer = Timer.periodic(
  //               const Duration(seconds: 1),
  //                   (_) => nextStep(),
  //             );
  //           }
  //         },
  //         child: CircleAvatar(
  //           radius: 25,
  //           backgroundColor: primaryColor,
  //           child: Icon(
  //             isPlaying ? Icons.pause : Icons.play_arrow,
  //             color: Colors.black,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 15),
  //       _mediaBtn(Icons.chevron_right, nextStep),
  //       _mediaBtn(Icons.last_page, skipToEnd),
  //     ],
  //   ),
  // );
  Widget _buildMediaConsole(bool isMobile) => FifoWidgets.glassContainer(
    margin: const EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: isMobile
          ? [
        _mediaBtn(Icons.chevron_left, prevStep),
        _playBtn(),
        _mediaBtn(Icons.chevron_right, nextStep),
      ]
          : [
        _mediaBtn(Icons.first_page, () {
          visibleSteps.clear();
          currentStep = 0;
        }),
        _mediaBtn(Icons.chevron_left, prevStep),
        _playBtn(),
        _mediaBtn(Icons.chevron_right, nextStep),
        _mediaBtn(Icons.last_page, skipToEnd),
      ],
    ),
  );

  Widget _playBtn() => GestureDetector(
    onTap: () {
      if (isPlaying) {
        playTimer?.cancel();
        setState(() => isPlaying = false);
      } else {
        if (currentStep >= allSteps.length) {
          visibleSteps.clear();
          currentStep = 0;
        }
        setState(() => isPlaying = true);
        playTimer = Timer.periodic(const Duration(seconds: 1), (_) => nextStep());
      }
    },
    child: CircleAvatar(
      radius: 25,
      backgroundColor: primaryColor,
      child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black),
    ),
  );

  Widget _mediaBtn(IconData icon, VoidCallback action) => IconButton(
    icon: Icon(
      icon,
      color:
      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    ),
    onPressed: action,
  );
}
