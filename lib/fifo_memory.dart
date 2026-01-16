import 'package:fifo_page_replacemnt/fifo_model.dart';
import 'package:flutter/material.dart';
import 'fifo_widgets.dart';

class FifoMemoryGrid extends StatelessWidget {
  final List<FifoStep> visibleSteps;
  final ScrollController horizontalController;
  final Color primaryColor;

  const FifoMemoryGrid({
    super.key,
    required this.visibleSteps,
    required this.horizontalController,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (visibleSteps.isEmpty) {
      return const Center(
        child: Text("SYSTEM IDLE", style: TextStyle(color: Colors.white10)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FifoWidgets.glassContainer(
        margin: EdgeInsets.zero,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            controller: horizontalController,
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: visibleSteps.map((step) => _buildColumn(step)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(FifoStep step) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [

          Text(
            step.isHit ? "HIT" : "MISS",
            style: TextStyle(
              color: step.isHit ? Colors.greenAccent : Colors.red,
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
              style: const TextStyle(fontSize: 17, color: Colors.white),
            ),
          ),
          const SizedBox(height: 15),
          Column(
            children: step.frames.map((f) => _buildFrameBox(f, step)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameBox(int? f, FifoStep step) {
    final bool isNewlyAdded = f == step.page && !step.isHit;

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      height: 35,
      width: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isNewlyAdded
            ? primaryColor.withOpacity(0.3)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isNewlyAdded ? primaryColor : Colors.white10,
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
    );
  }
}