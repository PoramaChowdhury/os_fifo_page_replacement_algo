import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FifoStep {
  final int page;
  final List<int?> frames;
  final bool isHit;
  final String log;

  _FifoStep({
    required this.page,
    required this.frames,
    required this.isHit,
    required this.log,
  });
}

class FifoHome extends StatefulWidget {
  const FifoHome({super.key});

  @override
  State<FifoHome> createState() => _FifoHomeState();
}

class _FifoHomeState extends State<FifoHome> {
  final TextEditingController _pageController = TextEditingController(
    text: "7 0 1 2 0 3 0 4 2 3",
  );
  final TextEditingController _frameController = TextEditingController(
    text: "3",
  );
  final ScrollController _horizontalController = ScrollController();

  List<_FifoStep> allSteps = [];
  List<_FifoStep> visibleSteps = [];
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
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.isAnonymous || allSteps.isEmpty) {
      setState(() => replacementLog = "GUEST MODE: History Will NOT SAVED");
      return;
    }

    try {
      await Supabase.instance.client.from('history').insert({
        'user_id': user.id,
        'pages': _pageController.text,
        'frame_count': int.parse(_frameController.text),
        'data': allSteps.map((s) => {'p': s.page, 'h': s.isHit}).toList(),
      });
      setState(() => replacementLog = "SYNCED TO Database");
    } catch (e) {
      debugPrint("Save failed: $e");
    }
  }

  void _showHistoryList() {
    final user = Supabase.instance.client.auth.currentUser;
    showModalBottomSheet(
      context: context,
      backgroundColor: bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _glassContainer(
        margin: EdgeInsets.zero,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: Supabase.instance.client
              .from('history')
              .stream(primaryKey: ['id'])
              .eq('user_id', user?.id ?? '')
              .order('created_at'),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final history = snapshot.data!;
            if (history.isEmpty)
              return const Center(child: Text("NO HISTORY FOUND"));

            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: Icon(Icons.history, color: primaryColor),
                title: Text(
                  "Pages: ${history[i]['pages']}",
                  style: const TextStyle(fontSize: 23, color: Colors.white70),
                ),
                subtitle: Text(
                  "Frames: ${history[i]['frame_count']}",
                  style: const TextStyle(fontSize: 20, color: Colors.white24),
                ),
                onTap: () {
                  setState(() {
                    _pageController.text = history[i]['pages'];
                    _frameController.text = history[i]['frame_count']
                        .toString();
                    calculateFIFO();
                  });
                  Navigator.pop(context);
                },
              ),
            );
          },
        ),
      ),
    );
  }
  /*void calculateFIFO() {
    if (_pageController.text.isEmpty || _frameController.text.isEmpty) return;
    final pages = _pageController.text
        .trim()
        .split(RegExp(r'\s+'))
        .map(int.parse)
        .toList();
    final frameCount = int.tryParse(_frameController.text) ?? 3;
    List<int?> frames = List.filled(frameCount, null);
    int pointer = 0;

    allSteps.clear();
    visibleSteps.clear();
    currentStep = 0;

    for (int page in pages) {
      bool hit = frames.contains(page);
      String status = hit
          ? "HIT: $page found in memory."
          : "REPLACE:  with $page.";
      if (!hit) {
        frames[pointer] = page;
        pointer = (pointer + 1) % frameCount;
      }
      allSteps.add(
        _FifoStep(
          page: page,
          frames: List.from(frames),
          isHit: hit,
          log: status,
        ),
      );
    }
    setState(() => replacementLog = "READY: Start Simulation");
    saveHistory();
  }*/
  void calculateFIFO() {
    if (_pageController.text.isEmpty || _frameController.text.isEmpty) return;
    final pages = _pageController.text.trim().split(RegExp(r'\s+')).map(int.parse).toList();
    final frameCount = int.tryParse(_frameController.text) ?? 3;
    List<int?> frames = List.filled(frameCount, null);
    int pointer = 0;

    allSteps.clear();
    visibleSteps.clear();
    currentStep = 0;

    for (int page in pages) {
      bool hit = frames.contains(page);
      String status;

      if (hit) {
        status = "HIT: Page $page is already in memory so hit.";
      } else {
        int? evictedPage = frames[pointer];

        if (evictedPage == null) {
          status = "MISS: Filling empty slot with Page $page.";
        } else {
          status = "Replace Done:   Previous Page $evictedPage ➔ New Page $page.";
        }

        frames[pointer] = page;
        pointer = (pointer + 1) % frameCount;
      }

      allSteps.add(_FifoStep(
        page: page,
        frames: List.from(frames),
        isHit: hit,
        log: status,
      ));
    }
    setState(() => replacementLog = "READY: Detailed Analysis Loaded");
    saveHistory();
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
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            "SYSTEM GUIDE",
            style: TextStyle(
              color: primaryColor,
              letterSpacing: 2,
              fontSize: 15,
            ),
          ),
          content: const Text(
            "1. Set Page String & Frames\n2. Click INITIALIZE\n3. Use centered media keys to control the memory cycle.",
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Got It",
                style: TextStyle(color: primaryColor, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
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
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.history, color: Colors.white70),
                        onPressed: _showHistoryList,
                      ),
                      _buildHeader(),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white70),
                        onPressed: () =>
                            Supabase.instance.client.auth.signOut(),
                      ),
                    ],
                  ),
                ),
                _buildInputPanel(),
                _buildStatsDashboard(
                  totalHits,
                  totalMisses,
                  hitRatio,
                  missRatio,
                  uniquePages,
                ),
                _buildStatusBanner(),
                Expanded(child: _buildUnifiedScrollGrid()),
                _buildMediaConsole(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Column(
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
  );

  Widget _buildStatsDashboard(
    int hits,
    int misses,
    double hitR,
    double missR,
    int unique,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statBox("HITS", hits.toString(), Colors.greenAccent),
        _statBox("MISSES", misses.toString(), Colors.redAccent),
        _statBox("HIT RATIO", "${hitR.toStringAsFixed(1)}%", primaryColor),
        _statBox(
          "MISS RATIO",
          "${missR.toStringAsFixed(1)}%",
          Colors.orangeAccent,
        ),
        _statBox("UNIQUE", unique.toString(), Colors.purpleAccent),
      ],
    ),
  );

  Widget _statBox(String label, String value, Color color) => Column(
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white38,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: color,
          fontFamily: 'monospace',
        ),
      ),
    ],
  );

  Widget _buildInputPanel() => _glassContainer(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Large Page Sequence Field
          Expanded(
            flex: 4,

            child: TextFormField(
              controller: _pageController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
              ],
              style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
              decoration: _inputStyle("PAGE STRING (Ex - 1 2 4 6 9)"),
              validator: (value) {
                if (value == null || value.isEmpty) return "Please enter numbers";
                if (RegExp(r'[a-zA-Z]').hasMatch(value)) {
                  return "Pass numbers only";
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 20),
          // Large Frame Count Field
          Expanded(
            child: TextField(
              controller: _frameController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
              decoration: _inputStyle("FRAMES"),
            ),
          ),
          const SizedBox(width: 15),
          // High-Impact Action Buttons
          _buildLargeActionButton(
              icon: Icons.bolt,
              color: primaryColor,
              onPressed: (){if (_formKey.currentState!.validate()) {
                calculateFIFO();
              }},
              tooltip: "Run Simulator"
          ),
          const SizedBox(width: 10),
          _buildLargeActionButton(
              icon: Icons.refresh_rounded,
              color: Colors.redAccent,
              onPressed: clearAll,
              tooltip: "System Reset"
          ),
        ],
      ),
    ),
  );

// Helper for larger Action Buttons
  Widget _buildLargeActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: IconButton(
          icon: Icon(icon, color: color, size: 28),
          onPressed: onPressed,
        ),
      ),
    );
  }

// Updated Input Style for "Large" Look
  InputDecoration _inputStyle(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 1.2),
    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
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

  Widget _buildUnifiedScrollGrid() {
    if (visibleSteps.isEmpty) {
      return const Center(
        child: Text("SYSTEM IDLE", style: TextStyle(color: Colors.white10)),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: _glassContainer(
        margin: EdgeInsets.zero,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: visibleSteps
                  .map(
                    (step) => Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 15),
                      child: Column(
                        children: [
                          Text(
                            step.isHit ? "HIT" : "MISS",
                            style: TextStyle(
                              color: step.isHit
                                  ? Colors.greenAccent
                                  : Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.15),
                            radius: 20,
                            child: Text(
                              "${step.page}",
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Column(
                            children: step.frames
                                .map(
                                  (f) => Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    height: 35,
                                    width: 55,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: f == step.page && !step.isHit
                                          ? primaryColor.withOpacity(0.3)
                                          : Colors.white.withOpacity(0.03),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: f == step.page && !step.isHit
                                            ? primaryColor
                                            : Colors.white10,
                                      ),
                                    ),
                                    child: Text(
                                      f?.toString() ?? "-",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaConsole() => _glassContainer(
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

  Widget _glassContainer({required Widget child, required EdgeInsets margin}) =>
      Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: child,
            ),
          ),
        ),
      );


}
