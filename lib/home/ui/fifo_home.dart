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

  @override
  Widget build(BuildContext context) {
    final int totalHits = visibleSteps.where((s) => s.isHit).length;
    final int totalMisses = visibleSteps.where((s) => !s.isHit).length;
    final double hitRatio = visibleSteps.isEmpty
        ? 0
        : (totalHits / visibleSteps.length) * 100;
    final double missRatio = visibleSteps.isEmpty
        ? 0
        : (totalMisses / visibleSteps.length) * 100;

    final pages = _pageController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty);

    final int uniquePages = pages
        .map(int.tryParse)
        .whereType<int>()
        .toSet()
        .length;
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
            _buildScrollDirection(),
            _buildMediaConsole(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isMobile) {
    final double titleFontSize = isMobile ? 16 : 28;
    final double subTitleFontSize = isMobile ? 14 : 26;
    final double letterSpacing = isMobile ? 2 : 4;
    final double iconSize = isMobile ? 22 : 26;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            iconSize: iconSize,
            icon: const Icon(Icons.history),
            onPressed: _showHistoryList,
          ),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ubuntu(
                      letterSpacing: letterSpacing,
                      fontWeight: FontWeight.w700,
                      fontSize: titleFontSize,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "FIFO",
                  style: GoogleFonts.oswald(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: subTitleFontSize,
                    letterSpacing: letterSpacing,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: iconSize,
                icon: const Icon(Icons.play_circle_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FifoVideoTutorial(),
                    ),
                  );
                },
              ),
              Consumer<ThemeService>(
                builder: (_, theme, __) => IconButton(
                  iconSize: iconSize,
                  icon: Icon(
                    theme.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                  onPressed: theme.toggleTheme,
                ),
              ),
              IconButton(
                iconSize: iconSize,
                icon: const Icon(Icons.logout),
                onPressed: () => Supabase.instance.client.auth.signOut(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 6),
    color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
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

  Widget _buildScrollDirection() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 6),
    color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
    child: Text(
      "⬅️➡️ Swipe to see more",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    ),
  );

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
        playTimer = Timer.periodic(
          const Duration(seconds: 1),
          (_) => nextStep(),
        );
      }
    },
    child: CircleAvatar(
      radius: 25,
      backgroundColor: primaryColor,
      child: Icon(
        isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.black,
      ),
    ),
  );

  Widget _mediaBtn(IconData icon, VoidCallback action) => IconButton(
    icon: Icon(
      icon,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    ),
    onPressed: action,
  );
}
