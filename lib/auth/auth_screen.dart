// import 'dart:async';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});
//
//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }
//
// class _AuthScreenState extends State<AuthScreen> {
//   final _email = TextEditingController();
//   final _pass = TextEditingController();
//   bool isLogin = true;
//   bool isLoading = false;
//   final Color primaryColor = const Color(0xFF00E5FF);
//
//   void _showStatus(String msg, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
//
//   Future<void> _handleAuth() async {
//     setState(() => isLoading = true);
//     try {
//       if (isLogin) {
//         await Supabase.instance.client.auth.signInWithPassword(
//           email: _email.text.trim(),
//           password: _pass.text.trim(),
//         );
//         _showStatus("Welcome Back Fifo.");
//       } else {
//         await Supabase.instance.client.auth.signUp(
//           email: _email.text.trim(),
//           password: _pass.text.trim(),
//         );
//         _showStatus("Verification link sent to email.");
//       }
//     } catch (e) {
//       _showStatus(e.toString(), isError: true);
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1117),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Container(
//             width: 550,
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               // color: Colors.white.withOpacity(0.05),
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? Colors.white.withOpacity(0.08)
//                   : Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               // border: Border.all(color: Colors.white10),
//               border: Border.all(
//                 color: Theme.of(context).brightness == Brightness.dark
//                     ? Colors.white12
//                     : Colors.grey.shade200,
//               ),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   isLogin ? "Login" : "New Here? Sign Up",
//                   style: const TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 3,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextField(
//                   controller: _email,
//                   decoration: const InputDecoration(labelText: "Email",labelStyle:const TextStyle(fontSize: 16, color: Colors.white) ),
//                 ),
//                 SizedBox(height: 8,),
//                 TextField(
//                   controller: _pass,
//                   obscureText: true,
//                   decoration: const InputDecoration(labelText: "PASSWORD",labelStyle:const TextStyle(fontSize: 16, color: Colors.white),)
//                 ),
//                 const SizedBox(height: 20),
//                 if (isLoading)
//                   const CircularProgressIndicator()
//                 else
//                   ElevatedButton(
//                     onPressed: _handleAuth,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryColor,
//                       foregroundColor: Colors.black,
//                       minimumSize: const Size(double.infinity, 50),
//                     ),
//                     child: Text(isLogin ? "Sign In" : "Sign Up",),
//                   ),
//                 SizedBox(height: 10,),
//                 TextButton(
//                   onPressed: () async {
//                     if (_email.text.isEmpty)
//                       return _showStatus("Enter email first", isError: true);
//                     await Supabase.instance.client.auth.resetPasswordForEmail(
//                       _email.text.trim(),
//                     );
//                     _showStatus("Reset link sent to inbox.");
//                   },
//                   child: const Text(
//                     "Forgot Credentials?",
//                     style: TextStyle(fontSize: 15),
//                   ),
//                 ),
//                 SizedBox(height: 10,),
//
//                 TextButton(
//
//                   onPressed: () => setState(() => isLogin = !isLogin),
//                   child: Text(isLogin ? "Create Account" : "Back to Sign in",style: TextStyle(fontSize: 15),),
//                 ),
//
//                 const Divider(),
//                 TextButton(
//                   onPressed: () =>
//                       Supabase.instance.client.auth.signInAnonymously(),
//                   child: const Text("Login As Guest",style: TextStyle(fontSize: 15),),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:fifo_page_replacemnt/app/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Future<void> _handleForgotPassword() async {
    if (_email.text.trim().isEmpty) {
      _showStatus("Please enter your email first", isError: true);
      return;
    }

    try {
      await Supabase.instance.client.auth
          .resetPasswordForEmail(_email.text.trim());

      _showStatus("Password reset link sent to your email 📩");
    } catch (e) {
      _showStatus("Failed to send reset email", isError: true);
    }
  }

  final _email = TextEditingController();
  final _pass = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  final Color primaryColor = const Color(0xFF39CEDF);

  void _showStatus(String msg, {bool isError = false}) {
    final cs = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
        isError ? cs.error : cs.primary.withOpacity(0.9),
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
        _showStatus("Welcome back 👋");
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cs.onSurface.withOpacity(0.12),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔥 HEADER + THEME TOGGLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isLogin ? "LOGIN" : "SIGN UP",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: cs.onSurface,
                      ),
                    ),
                    Consumer<ThemeService>(
                      builder: (_, themeService, __) => IconButton(
                        tooltip: "Toggle theme",
                        icon: Icon(
                          themeService.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                        onPressed: themeService.toggleTheme,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                  ),
                ),

                const SizedBox(height: 24),

                if (isLoading)
                  CircularProgressIndicator(color: cs.primary)
                else
                  ElevatedButton(
                    onPressed: _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(isLogin ? "Sign In" : "Create Account"),
                  ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () async {
                    if (_email.text.isEmpty) {
                      return _showStatus(
                        "Enter email first",
                        isError: true,
                      );
                    }
                    await Supabase.instance.client.auth
                        .resetPasswordForEmail(_email.text.trim());
                    _showStatus("Reset link sent to inbox.");
                  },
                  child:  Text("Forgot Credentials?",style: TextStyle(
                    color: Color(0xFF038585),

                  ),),
                ),

                TextButton(
                  onPressed: () =>
                      setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? "Create Account" : "Back to Login",
                  ),
                ),

                const Divider(),

                TextButton(
                  onPressed: () =>
                      Supabase.instance.client.auth.signInAnonymously(),
                  child: const Text("Continue as Guest"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

