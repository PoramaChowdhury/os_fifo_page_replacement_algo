import 'package:fifo_page_replacemnt/fifo_home.dart';
import 'package:flutter/material.dart';

class FifoApp extends StatelessWidget {
  const FifoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF1F4), // light pink
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0x90D1558A),
        ),
        useMaterial3: true,
      ),
      home: const FifoHome(),
    );

  }
}