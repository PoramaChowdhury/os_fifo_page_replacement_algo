import 'package:fifo_page_replacemnt/auth_screen.dart';
import 'package:fifo_page_replacemnt/fifo_home.dart';
import 'package:flutter/material.dart';

class FifoApp extends StatelessWidget {
  const FifoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, primaryColor: const Color(0xFF00E5FF)),
      home: const FifoHome() ,
    );
  }
}