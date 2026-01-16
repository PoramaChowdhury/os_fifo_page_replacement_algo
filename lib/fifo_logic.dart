import 'package:fifo_page_replacemnt/fifo_model.dart';


class FifoLogic {

  static Map<String, dynamic> calculate({
    required String pageInput,
    required String frameInput,
  }) {
    if (pageInput.isEmpty || frameInput.isEmpty) {
      return {
        'steps': <FifoStep>[],
        'log': "INPUT ERROR: Missing values"
      };
    }

    final pages = pageInput
        .trim()
        .split(RegExp(r'\s+'))
        .map(int.parse)
        .toList();

    final frameCount = int.tryParse(frameInput) ?? 3;
    List<int?> frames = List.filled(frameCount, null);
    int pointer = 0;
    List<FifoStep> steps = [];

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
          status = "Replace Done: Previous Page $evictedPage ➔ New Page $page.";
        }

        frames[pointer] = page;
        pointer = (pointer + 1) % frameCount;
      }

      steps.add(
        FifoStep(
          page: page,
          frames: List.from(frames),
          isHit: hit,
          log: status,
        ),
      );
    }

    return {
      'steps': steps,
      'log': "READY: Detailed Analysis Loaded"
    };
  }
}