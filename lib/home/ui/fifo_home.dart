import 'dart:async';
import 'dart:ui';
import 'package:fifo_page_replacemnt/database/database_service.dart';
import 'package:fifo_page_replacemnt/home/widgets/fifo_video_tutorial.dart';
import 'package:fifo_page_replacemnt/home/widgets/fifo_dialog_tutorial.dart';
import 'package:fifo_page_replacemnt/home/widgets/fifo_history_sheet.dart';
import 'package:fifo_page_replacemnt/home/widgets/fifo_inputPanel.dart';
import 'package:fifo_page_replacemnt/fifo%20calculator/fifo_logic.dart';
import 'package:fifo_page_replacemnt/home/widgets/fifo_memory.dart';
import 'package:fifo_page_replacemnt/model/fifo_model.dart';
import 'package:fifo_page_replacemnt/home/widgets/fifo_stats_dashboard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/fifo_widgets.dart';


class FifoHome extends StatefulWidget {
  const FifoHome({super.key});

  @override
  State<FifoHome> createState() => _FifoHomeState();
}

class _FifoHomeState extends State<FifoHome> {
  final TextEditingController _pageController = TextEditingController(text: "");
  final TextEditingController _frameController = TextEditingController(
    text: "",
  );
  final ScrollController _horizontalController = ScrollController();

  List<FifoStep> allSteps = [];
  List<FifoStep> visibleSteps = [];
  int currentStep = 0;
  Timer? playTimer;
  bool isPlaying = false;
  String replacementLog = "INITIALIZE  TO BEGIN";

  final Color primaryColor = const Color(0xFF00E5FF);
  final Color bgDark = const Color(0xFF0D1117);
  final _formKey = GlobalKey<FormState>();

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
      backgroundColor: bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FifoHistorySheet(
        bgDark: bgDark,
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

    if (allSteps.isNotEmpty) {
      saveHistory();
    }
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
          duration: const Duration(milliseconds: 500),
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
    int totalHits = visibleSteps.where((s) => s.isHit).length;
    int totalMisses = visibleSteps.where((s) => !s.isHit).length;
    double hitRatio = visibleSteps.isEmpty
        ? 0
        : (totalHits / visibleSteps.length) * 100;
    double missRatio = visibleSteps.isEmpty
        ? 0
        : (totalMisses / visibleSteps.length) * 100;
    final pages = _pageController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty);
    int uniquePages = pages
        .map(int.tryParse)
        .where((p) => p != null)
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
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
            _buildMediaConsole(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.history, color: Colors.white70),
          onPressed: _showHistoryList,
        ),
        Column(
          children: [
            Text(
              " Page Replacement Algorithm",
              style: TextStyle(
                color: primaryColor,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            Text(
              "FIFO",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.play_circle_outline,
                color: Colors.white70,
              ),
              tooltip: "FIFO Video Tutorial",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FifoVideoTutorial(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              onPressed: () =>
                  Supabase.instance.client.auth.signOut(),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildStatusBanner() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 6),
    color: primaryColor.withOpacity(0.1),
    child: Text(
      replacementLog,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    ),
  );



  Widget _buildMediaConsole() => FifoWidgets.glassContainer(
    margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _mediaBtn(
          Icons.first_page,
          () => setState(() {
            visibleSteps.clear();
            currentStep = 0;
          }),
        ),
        _mediaBtn(Icons.chevron_left, prevStep),
        const SizedBox(width: 15),
        GestureDetector(
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
                (t) => nextStep(),
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
        ),
        const SizedBox(width: 15),
        _mediaBtn(Icons.chevron_right, nextStep),
        _mediaBtn(Icons.last_page, skipToEnd),
      ],
    ),
  );

  Widget _mediaBtn(IconData icon, VoidCallback action) => IconButton(
    icon: Icon(icon, color: Colors.white70),
    onPressed: action,
  );
}
