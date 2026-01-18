import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fifo_widgets.dart';

class FifoHistorySheet extends StatelessWidget {
  final Color primaryColor;
  final Function(String pages, String frames) onHistorySelected;

  const FifoHistorySheet({
    super.key,
    required this.primaryColor,
    required this.onHistorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FifoWidgets.glassContainer(
      margin: EdgeInsets.zero,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('history')
            .stream(primaryKey: ['id'])
            .eq('user_id', user?.id ?? '')
            .order('created_at'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return Center(
              child: Text(
                "NO HISTORY FOUND",
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.4),
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (ctx, i) {
              return ListTile(
                leading: Icon(Icons.history, color: primaryColor),
                title: Text(
                  "Pages: ${history[i]['pages']}",
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.onSurface.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  "Frames: ${history[i]['frame_count']}",
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                onTap: () {
                  onHistorySelected(
                    history[i]['pages'].toString(),
                    history[i]['frame_count'].toString(),
                  );
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}
