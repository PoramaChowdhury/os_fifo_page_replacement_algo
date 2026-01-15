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
  bool isPasswordVisible = false;

  final Color primaryColor = const Color(0xFF00E5FF);
  final Color glassColor = Colors.white.withOpacity(0.05);

  void _showStatus(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleAuth() async {
    if (_email.text.isEmpty || _pass.text.isEmpty) {
      _showStatus("Please fill in all fields", isError: true);
      return;
    }

    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
            email: _email.text.trim(),
            password: _pass.text.trim()
        );
        _showStatus("Login Successful! Initializing Kernel...");
      } else {
        await Supabase.instance.client.auth.signUp(
            email: _email.text.trim(),
            password: _pass.text.trim()
        );
        _showStatus("Account Created! Check your email for verification.");
      }
    } on AuthException catch (e) {
      _showStatus(e.message, isError: true);
    } catch (e) {
      _showStatus("An unexpected error occurred", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_email.text.isEmpty) {
      _showStatus("Enter your email to receive a reset link", isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(_email.text.trim());
      _showStatus("Security link sent! Check your inbox.");
    } catch (e) {
      _showStatus("Failed to send reset link", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned(
            top: -150, left: -100,
            child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(0.15), )),
          ),
          Center(
            child: SingleChildScrollView(
              child: _glassMorphicPanel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isLogin ? "KERNEL LOGIN" : "NEW OPERATOR", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 3, color: Colors.white)),
                    const SizedBox(height: 30),
                    _buildTextField(_email, "EMAIL", Icons.email_outlined),
                    const SizedBox(height: 15),
                    _buildTextField(_pass, "PASSWORD", Icons.lock_outline, isPassword: true),
                    const SizedBox(height: 25),

                    // Main Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleAuth,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : Text(isLogin ? "INITIALIZE" : "REGISTER"),
                      ),
                    ),

                    const SizedBox(height: 10),
                    TextButton(onPressed: () => setState(() => isLogin = !isLogin), child: Text(isLogin ? "Need access? Create Account" : "Existing Operator? Login", style: const TextStyle(color: Colors.white70, fontSize: 12))),
                    TextButton(onPressed: _resetPassword, child: const Text("Forgot Security Credentials?", style: TextStyle(color: Colors.white38, fontSize: 10))),

                    const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(color: Colors.white10)),

                    // Guest Option
                    TextButton.icon(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signInAnonymously();
                        _showStatus("Logged in as Guest. Cloud sync disabled.");
                      },
                      icon: const Icon(Icons.person_outline, size: 16, color: Colors.white38),
                      label: const Text("ACCESS AS GUEST", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        suffixIcon: isPassword ? IconButton(icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white38, size: 18), onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible)) : null,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 11),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white10), borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor), borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
      ),
    );
  }

  Widget _glassMorphicPanel({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: glassColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
          child: child,
        ),
      ),
    );
  }
}
