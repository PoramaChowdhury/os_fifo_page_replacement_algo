/*
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
class _FifoStep {
  final int page;
  final List<int?> frames;
  final bool isHit;
  final String log;
  _FifoStep({required this.page, required this.frames, required this.isHit, required this.log});
}

class FifoHome extends StatefulWidget {
  const FifoHome({super.key});
  @override
  State<FifoHome> createState() => _FifoHomeState();
}

class _FifoHomeState extends State<FifoHome> {
  final TextEditingController _pageController = TextEditingController(text: "7 0 1 2 0 3 0 4 2 3");
  final TextEditingController _frameController = TextEditingController(text: "3");
  final ScrollController _scrollController = ScrollController();

  List<_FifoStep> allSteps = [];
  List<_FifoStep> visibleSteps = [];
  int currentStep = 0;
  Timer? playTimer;
  bool isPlaying = false;
  String replacementLog = "INITIALIZE KERNEL TO BEGIN";

  final Color primaryColor = const Color(0xFF00E5FF);
  final Color bgDark = const Color(0xFF0D1117);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showTutorial());
  }

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.black87,
          title: Text("SYSTEM GUIDE", style: TextStyle(color: primaryColor, letterSpacing: 2)),
          content: const Text("1. Set Page String & Frames\n2. Click INITIALIZE\n3. Use centered media keys to control the memory cycle."),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Got It", style: TextStyle(color: primaryColor)))],
        ),
      ),
    );
  }

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
        status = "HIT: Page $page found in memory.";
      } else {
        String evicted = frames[pointer] == null ? "Empty Slot" : "Oldest Page ${frames[pointer]}";
        status = "REPLACE: $evicted with Page $page.";
        frames[pointer] = page;
        pointer = (pointer + 1) % frameCount;
      }
      allSteps.add(_FifoStep(page: page, frames: List.from(frames), isHit: hit, log: status));
    }
    setState(() => replacementLog = "KERNEL READY: Start Simulation");
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
        replacementLog = currentStep > 0 ? allSteps[currentStep - 1].log : "BACK AT START";
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
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalHits = visibleSteps.where((s) => s.isHit).length;
    int totalMisses = visibleSteps.where((s) => !s.isHit).length;
    double ratio = visibleSteps.isEmpty ? 0 : (totalHits / visibleSteps.length) * 100;

    return Scaffold(
      backgroundColor: bgDark,
      body: Stack(
        children: [
          // _buildBackgroundGlow(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildInputPanel(),
                _buildStatsDashboard(totalHits, totalMisses, ratio),
                _buildStatusBanner(),
                Expanded(child: _buildMemoryGrid()),
                _buildMediaConsole(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildBackgroundGlow() {
  //   return Positioned(
  //     top: -100, left: -50,
  //     child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(0.08))),
  //   );
  // }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Text("MEMORY KERNEL V2.0", style: TextStyle(color: Color(0xFF00E5FF), letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 18)),
          Text("FIFO SIMULATOR • LARGE SCALE ENGINE", style: TextStyle(color: Colors.white24, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(int hits, int misses, double hitR, double missR, int unique) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statBox("HITS", hits.toString(), Colors.greenAccent),
          _statBox("MISSES", misses.toString(), Colors.redAccent),
          _statBox("HIT RATIO", "${hitR.toStringAsFixed(1)}%", primaryColor),
          _statBox("MISS RATIO", "${missR.toStringAsFixed(1)}%", Colors.orangeAccent),
          _statBox("UNIQUE", unique.toString(), Colors.purpleAccent),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildInputPanel() {
    return _glassContainer(
      margin: const EdgeInsets.all(15),
      child: Column(
        children: [
          TextField(controller: _pageController, decoration: _inputStyle("PAGE SEQUENCE")),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: TextField(controller: _frameController, decoration: _inputStyle("FRAME COUNT"))),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: calculateFIFO,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.black),
                child: const Text("INIT"),
              ),
              const SizedBox(width: 10),
              IconButton(onPressed: clearAll, icon: const Icon(Icons.refresh, color: Colors.redAccent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8),
      color: primaryColor.withOpacity(0.1),
      child: Text(replacementLog, textAlign: TextAlign.center, style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
    );
  }

  Widget _buildMemoryGrid() {
    return Center(
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: visibleSteps.length,
        itemBuilder: (ctx, i) {
          final step = visibleSteps[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              children: [
                Text(step.isHit ? "HIT" : "MISS", style: TextStyle(color: step.isHit ? Colors.greenAccent : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                CircleAvatar(backgroundColor: primaryColor.withOpacity(0.15), radius: 18, child: Text("${step.page}", style: const TextStyle(color: Colors.white, fontSize: 14))),
                const SizedBox(height: 15),
                // Vertical scrolling for frames
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: step.frames.map((f) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        height: 40, width: 50, alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: f == step.page && !step.isHit ? primaryColor.withOpacity(0.3) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: f == step.page && !step.isHit ? primaryColor : Colors.white10),
                        ),
                        child: Text(f?.toString() ?? "-", style: const TextStyle(color: Colors.white70)),
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaConsole() {
    return _glassContainer(
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.first_page), onPressed: () => setState(() { visibleSteps.clear(); currentStep = 0; })),
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: prevStep),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (isPlaying) { playTimer?.cancel(); setState(() => isPlaying = false); }
              else {
                if (currentStep >= allSteps.length) { visibleSteps.clear(); currentStep = 0; }
                setState(() => isPlaying = true);
                playTimer = Timer.periodic(const Duration(seconds: 1), (t) => nextStep());
              }
            },
            child: CircleAvatar(radius: 25, backgroundColor: primaryColor, child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black)),
          ),
          const SizedBox(width: 10),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: nextStep),
          IconButton(icon: const Icon(Icons.last_page), onPressed: skipToEnd),
        ],
      ),
    );
  }

  Widget _glassContainer({required Widget child, required EdgeInsets margin}) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
            child: child,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: Colors.white38, fontSize: 10),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
  );
}

*/
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
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
  String replacementLog = "INITIALIZE KERNEL TO BEGIN";

  final Color primaryColor = const Color(0xFF00E5FF);
  final Color bgDark = const Color(0xFF0D1117);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showTutorial());
  }
  Future<void> saveHistory() async {
    final user = Supabase.instance.client.auth.currentUser;

    // If user is guest or not logged in, DO NOT try to save
    if (user == null || user.isAnonymous) {
      setState(() => replacementLog = "GUEST MODE: PROGRESS NOT SAVED");
      return;
    }

    try {
      await Supabase.instance.client.from('history').insert({
        'user_id': user.id,
        'pages': _pageController.text,
        'frame_count': int.parse(_frameController.text),
        'data': allSteps.map((s) => {'page': s.page, 'isHit': s.isHit}).toList(),
      });
      setState(() => replacementLog = "SYNCED TO SUPABASE");
    } catch (e) {
      debugPrint("Save failed: $e");
    }
  }
  void _showHistoryList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _glassContainer(
        margin: EdgeInsets.zero,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: Supabase.instance.client
              .from('history')
              .select()
              .order('created_at'),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final history = snapshot.data!;
            if (history.isEmpty)
              return const Center(child: Text("No history found."));

            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: Icon(Icons.history, color: primaryColor),
                title: Text(
                  "Pages: ${history[i]['pages']}",
                  style: const TextStyle(fontSize: 13),
                ),
                subtitle: Text(
                  "Frames: ${history[i]['frame_count']}",
                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                ),
                onTap: () {
                  setState(() {
                    _pageController.text = history[i]['pages'];
                    _frameController.text = history[i]['frame_count']
                        .toString();
                    calculateFIFO(); // Reload that simulation
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

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            "SYSTEM GUIDE",
            style: TextStyle(color: primaryColor, letterSpacing: 2),
          ),
          content: const Text(
            "1. Set Page String & Frames\n2. Click INITIALIZE\n3. Use centered media keys to control the memory cycle.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Got It", style: TextStyle(color: primaryColor)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> calculateFIFO() async {
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
      String status;
      if (hit) {
        status = "HIT: Page $page found in memory.";
      } else {
        String evicted = frames[pointer] == null
            ? "Empty Slot"
            : "Oldest Page ${frames[pointer]}";
        status = "REPLACE: $evicted with Page $page.";
        frames[pointer] = page;
        pointer = (pointer + 1) % frameCount;
      }
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && !user.isAnonymous) {
        await Supabase.instance.client.from('history').insert({
          'user_id': user.id,
          'pages': _pageController.text,
          'frame_count': frameCount,
          'data': allSteps
              .map(
                (s) => {'page': s.page, 'isHit': s.isHit, 'frames': s.frames},
              )
              .toList(),
        });
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
    setState(() => replacementLog = "KERNEL READY: Start Simulation");
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
          _buildBackgroundGlow(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //todo history
                      IconButton(icon: const Icon(Icons.history, color: Colors.white70), onPressed: _showHistoryList),
                      _buildHeader(),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white70),
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                        },
                      ),                    ],
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

  Widget _buildBackgroundGlow() {
    return Positioned(
      top: -100,
      left: -50,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor.withOpacity(0.08),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Text(
            "MEMORY KERNEL V3.0",
            style: TextStyle(
              color: Color(0xFF00E5FF),
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            "FIFO ANALYTICS • FULL TABLE SCROLL",
            style: TextStyle(color: Colors.white24, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(
    int hits,
    int misses,
    double hitR,
    double missR,
    int unique,
  ) {
    return Padding(
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
  }

  Widget _statBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Colors.white38,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildInputPanel() {
    return _glassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _pageController,
              decoration: _inputStyle("PAGE STRING"),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _frameController,
              decoration: _inputStyle("FRAMES"),
            ),
          ),
          IconButton(
            onPressed: calculateFIFO,
            icon: Icon(Icons.bolt, color: primaryColor),
          ),
          IconButton(
            onPressed: clearAll,
            icon: const Icon(Icons.refresh, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: primaryColor.withOpacity(0.1),
      child: Text(
        replacementLog,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: primaryColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildUnifiedScrollGrid() {
    if (visibleSteps.isEmpty)
      return const Center(
        child: Text("SYSTEM IDLE", style: TextStyle(color: Colors.white10)),
      );

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
              children: visibleSteps.map((step) {
                return Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 15),
                  child: Column(
                    children: [
                      Text(
                        step.isHit ? "HIT" : "MISS",
                        style: TextStyle(
                          color: step.isHit
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CircleAvatar(
                        backgroundColor: primaryColor.withOpacity(0.15),
                        radius: 15,
                        child: Text(
                          "${step.page}",
                          style: const TextStyle(
                            fontSize: 12,
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
                                width: 45,
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
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaConsole() {
    return _glassContainer(
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
  }

  Widget _mediaBtn(IconData icon, VoidCallback action) => IconButton(
    icon: Icon(icon, color: Colors.white70),
    onPressed: action,
  );

  Widget _glassContainer({required Widget child, required EdgeInsets margin}) {
    return Container(
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

  InputDecoration _inputStyle(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white38, fontSize: 9),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: primaryColor),
    ),
  );

}
