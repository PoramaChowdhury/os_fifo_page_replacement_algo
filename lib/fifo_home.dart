import 'dart:async';
import 'package:flutter/material.dart';

class FifoHome extends StatefulWidget {
  const FifoHome({super.key});

  @override
  State<FifoHome> createState() => _FifoHomeState();
}

class _FifoHomeState extends State<FifoHome>
    with SingleTickerProviderStateMixin {
  final TextEditingController pageController = TextEditingController();
  final TextEditingController customFrameController = TextEditingController();

  int selectedFrames = 3;
  bool useCustom = false;

  List<_FifoStep> allSteps = [];
  List<_FifoStep> visibleSteps = [];

  int currentStep = 0;
  Timer? playTimer;

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  // ================= FIFO LOGIC =================
  void calculateFIFO() {
    final pages = pageController.text
        .trim()
        .split(RegExp(r'\s+'))
        .map(int.parse)
        .toList();

    final frameCount =
    useCustom ? int.parse(customFrameController.text) : selectedFrames;

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

      allSteps.add(
        _FifoStep(
          page: page,
          frames: List.from(frames),
          isHit: hit,
        ),
      );
    }

    setState(() {});
  }

  // ================= CONTROLS =================
  void startSimulation() {
    visibleSteps.clear();
    currentStep = 0;
    setState(() {});
  }

  void nextStep() {
    if (currentStep < allSteps.length) {
      visibleSteps.add(allSteps[currentStep]);
      currentStep++;
      setState(() {});
    }
  }

  void previousStep() {
    if (visibleSteps.isNotEmpty) {
      visibleSteps.removeLast();
      currentStep--;
      setState(() {});
    }
  }

  void playSimulation() {
    playTimer?.cancel();
    playTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (currentStep >= allSteps.length) {
        timer.cancel();
      } else {
        nextStep();
      }
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            _inputCard(),
            const SizedBox(height: 20),
            _controlButtons(),
            const SizedBox(height: 20),
            if (visibleSteps.isNotEmpty) ...[
              _resultTabs(),
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: tabController,
                  children: [
                    _fifoTable(),
                    _hitMissView(),
                    _statsView(),
                    _sequenceView(),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // ================= INPUT CARD =================
  Widget _inputCard() {
    return Container(
      width: 900,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "FIFO Page Replacement",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text("Page Reference String"),
          TextField(
            controller: pageController,
            decoration: const InputDecoration(
              hintText: "Enter pages (e.g. 1 2 3 4)",
            ),
          ),
          const SizedBox(height: 20),
          const Text("No. of Frames"),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFrames = i;
                      useCustom = false;
                    });
                  },
                  child: _frameBox(i, selectedFrames == i && !useCustom),
                ),
              const SizedBox(width: 20),
              Checkbox(
                value: useCustom,
                onChanged: (v) => setState(() => useCustom = v!),
              ),
              const Text("Custom"),
              const SizedBox(width: 10),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: customFrameController,
                  enabled: useCustom,
                  keyboardType: TextInputType.number,
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: calculateFIFO,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D6D),
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text("Calculate"),
            ),
          )
        ],
      ),
    );
  }

  Widget _frameBox(int value, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFF4D6D) : Colors.white,
        border: Border.all(),
      ),
      child: Text(
        "$value",
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= CONTROL BUTTONS =================
  Widget _controlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: startSimulation,
          child: const Text("Start Simulation"),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: previousStep,
          child: const Text("Previous Step"),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: nextStep,
          child: const Text("Next Step"),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: playSimulation,
          child: const Text("Play"),
        ),
      ],
    );
  }

  // ================= RESULT =================
  Widget _resultTabs() {
    return TabBar(
      controller: tabController,
      labelColor: const Color(0xFFFF4D6D),
      tabs: const [
        Tab(text: "FIFO Table"),
        Tab(text: "Hit/Miss"),
        Tab(text: "Stats"),
        Tab(text: "Sequence"),
      ],
    );
  }

  Widget _fifoTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(),
        defaultColumnWidth: const FixedColumnWidth(50),
        children: [
          TableRow(
            children: [
              const Center(child: Text("Page")),
              ...visibleSteps.map((e) => Center(child: Text("${e.page}"))),
            ],
          ),
          for (int i = 0; i < visibleSteps.first.frames.length; i++)
            TableRow(
              children: [
                Center(child: Text("F${i + 1}")),
                ...visibleSteps.map(
                      (e) => Center(child: Text(e.frames[i]?.toString() ?? "")),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _hitMissView() => Wrap(
    children: visibleSteps
        .map((e) => Chip(label: Text(e.isHit ? "H" : "M")))
        .toList(),
  );

  Widget _statsView() => Padding(
    padding: const EdgeInsets.all(20),
    child: Text(
        "Hits: ${visibleSteps.where((e) => e.isHit).length} | Misses: ${visibleSteps.where((e) => !e.isHit).length}"),
  );

  Widget _sequenceView() => Wrap(
    children: visibleSteps
        .map((e) => Text(e.isHit ? "H " : "M ",
        style: const TextStyle(fontSize: 18)))
        .toList(),
  );
}

// ================= MODEL =================
class _FifoStep {
  final int page;
  final List<int?> frames;
  final bool isHit;

  _FifoStep({
    required this.page,
    required this.frames,
    required this.isHit,
  });
}
