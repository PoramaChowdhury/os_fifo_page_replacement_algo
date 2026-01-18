import 'package:fifo_page_replacemnt/model/fifo_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  static final _supabase = Supabase.instance.client;

  static Future<String> saveHistory({
    required String pages,
    required String frameCount,
    required List<FifoStep> allSteps,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null || user.isAnonymous || allSteps.isEmpty) {
      return "GUEST MODE: History Will NOT SAVED";
    }

    try {
      final int frames = int.tryParse(frameCount) ?? 0;
      final List<Map<String, dynamic>> stepsData = allSteps
          .map((s) => {'p': s.page, 'h': s.isHit})
          .toList();

      await _supabase.from('history').insert({
        'user_id': user.id,
        'pages': pages,
        'frame_count': frames,
        'data': stepsData,
      });

      return "Saved In Database";
    } catch (e) {
      debugPrint("Save failed: $e");
      return "SYNC ERROR: Could not save data";
    }
  }
}
