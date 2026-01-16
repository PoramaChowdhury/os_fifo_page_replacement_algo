import 'package:fifo_page_replacemnt/auth/auth_screen.dart';
import 'package:fifo_page_replacemnt/home/ui/fifo_home.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        return (snapshot.data?.session != null)
            ? const FifoHome()
            : const AuthScreen();
      },
    );
  }
}
