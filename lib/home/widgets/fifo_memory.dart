
import 'package:fifo_page_replacemnt/model/fifo_model.dart';
import 'package:fifo_page_replacemnt/utils/responsive.dart';
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
    final cs = Theme.of(context).colorScheme;

    if (visibleSteps.isEmpty) {
      return Center(
        child: Text(
          "SYSTEM IDLE",
          style: TextStyle(
            color: cs.onSurface.withOpacity(0.25),
            letterSpacing: 2,
          ),
        ),
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
              children: visibleSteps.map((s) => _buildColumn(context, s)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(BuildContext context, FifoStep step) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: Responsive.isMobile(context) ? 60 : 70,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Text(
            step.isHit ? "HIT" : "MISS",
            style: TextStyle(
              color: step.isHit ? Colors.green : Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.15),
            radius: 20,
            child: Text(
              "${step.page}",
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Column(
            children: step.frames
                .map((f) => _buildFrameBox(context, f, step))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameBox(BuildContext context, int? f, FifoStep step) {
    final cs = Theme.of(context).colorScheme;
    final bool isNew = f == step.page && !step.isHit;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      height: 35,
      width: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isNew
            ? primaryColor.withOpacity(0.25)
            : cs.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isNew
              ? primaryColor
              : cs.onSurface.withOpacity(0.2),
        ),
      ),
      child: Text(
        f?.toString() ?? "-",
        style: TextStyle(
          color: cs.onSurface.withOpacity(0.85),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
