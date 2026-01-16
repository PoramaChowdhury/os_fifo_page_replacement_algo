import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;
  final Color primaryColor = const Color(0xFF00E5FF);

  void _showStatus(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleAuth() async {
    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _email.text.trim(),
          password: _pass.text.trim(),
        );
        _showStatus("Welcome Back Fifo.");
      } else {
        await Supabase.instance.client.auth.signUp(
          email: _email.text.trim(),
          password: _pass.text.trim(),
        );
        _showStatus("Verification link sent to email.");
      }
    } catch (e) {
      _showStatus(e.toString(), isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 550,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLogin ? "Login" : "New Here? Sign Up",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: "Email",labelStyle:const TextStyle(fontSize: 16, color: Colors.white) ),
                ),
                TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "PASSWORD",labelStyle:const TextStyle(fontSize: 16, color: Colors.white),)
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(isLogin ? "Sign In" : "Sign Up",),
                  ),
                SizedBox(height: 10,),
                TextButton(
                  onPressed: () async {
                    if (_email.text.isEmpty)
                      return _showStatus("Enter email first", isError: true);
                    await Supabase.instance.client.auth.resetPasswordForEmail(
                      _email.text.trim(),
                    );
                    _showStatus("Reset link sent to inbox.");
                  },
                  child: const Text(
                    "Forgot Credentials?",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(height: 10,),

                TextButton(

                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(isLogin ? "Create Account" : "Back to Sign in",style: TextStyle(fontSize: 15),),
                ),

                const Divider(),
                TextButton(
                  onPressed: () =>
                      Supabase.instance.client.auth.signInAnonymously(),
                  child: const Text("Login As Guest",style: TextStyle(fontSize: 15),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
