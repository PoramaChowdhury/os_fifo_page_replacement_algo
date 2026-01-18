import 'package:fifo_page_replacemnt/app/theme_service.dart';
import 'package:fifo_page_replacemnt/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FifoApp extends StatelessWidget {
  const FifoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeService.currentTheme,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
