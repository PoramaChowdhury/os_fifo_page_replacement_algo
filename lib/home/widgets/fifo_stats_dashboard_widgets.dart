// import 'package:flutter/material.dart';
// import 'fifo_widgets.dart';
//
// class FifoDashboard extends StatelessWidget {
//   final int hits;
//   final int misses;
//   final double hitRatio;
//   final double missRatio;
//   final int uniquePages;
//   final Color primaryColor;
//
//   const FifoDashboard({
//     super.key,
//     required this.hits,
//     required this.misses,
//     required this.hitRatio,
//     required this.missRatio,
//     required this.uniquePages,
//     required this.primaryColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           FifoWidgets.statBox(
//             "HITS",
//             hits.toString(),
//             Colors.greenAccent,
//           ),
//           FifoWidgets.statBox(
//             "MISSES",
//             misses.toString(),
//             Colors.redAccent,
//           ),
//           FifoWidgets.statBox(
//             "HIT RATIO",
//             "${hitRatio.toStringAsFixed(1)}%",
//             primaryColor,
//           ),
//           FifoWidgets.statBox(
//             "MISS RATIO",
//             "${missRatio.toStringAsFixed(1)}%",
//             Colors.orangeAccent,
//           ),
//           FifoWidgets.statBox(
//             "UNIQUE",
//             uniquePages.toString(),
//             Colors.purpleAccent,
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'fifo_widgets.dart';

class FifoDashboard extends StatelessWidget {
  final int hits;
  final int misses;
  final double hitRatio;
  final double missRatio;
  final int uniquePages;
  final Color primaryColor;

  const FifoDashboard({
    super.key,
    required this.hits,
    required this.misses,
    required this.hitRatio,
    required this.missRatio,
    required this.uniquePages,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FifoWidgets.statBox("HITS", hits.toString(), Colors.green),
          FifoWidgets.statBox("MISSES", misses.toString(), Colors.red),
          FifoWidgets.statBox(
            "HIT %",
            "${hitRatio.toStringAsFixed(1)}",
            primaryColor,
          ),
          FifoWidgets.statBox(
            "MISS %",
            "${missRatio.toStringAsFixed(1)}",
            Colors.orange,
          ),
          FifoWidgets.statBox(
            "UNIQUE",
            uniquePages.toString(),
            Colors.purple,
          ),
        ],
      ),
    );
  }
}
