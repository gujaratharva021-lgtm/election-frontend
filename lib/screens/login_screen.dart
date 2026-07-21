import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  static const _darkText = Color(0xFF1A1A2E);
  static const _mutedText = Color(0xFF6B7280);
  static const _blue = Color(0xFF2563EB);

  void _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email and password'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _loading = true);
    final error = await AuthService.signInWithEmail(_emailController.text.trim(), _passwordController.text);
    if (error == null) {
      await AuthService.saveLogin(_emailController.text.trim());
      setState(() => _loading = false);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      }
    } else {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: Colors.white,
      body: isWide ? _wideLayout() : _narrowLayout(),
    );
  }

  Widget _wideLayout() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 64),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              ),
            ),
            child: Center(child: _brandPanel()),
          ),
        ),
        Expanded(
          flex: 4,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _formPanel(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _narrowLayout() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const FaIcon(FontAwesomeIcons.bolt, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OneVote', style: TextStyle(color: _darkText, fontSize: 22, fontWeight: FontWeight.w800)),
                      Text('Election Intelligence Platform', style: TextStyle(color: _mutedText, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _formPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brandPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const FaIcon(FontAwesomeIcons.bolt, color: Colors.white, size: 40),
        const SizedBox(height: 20),
        const Text('OneVote', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Election Intelligence Platform', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15)),
        const SizedBox(height: 32),
        _brandFeature(FontAwesomeIcons.userGroup, '4,424+ Candidates tracked'),
        const SizedBox(height: 14),
        _brandFeature(FontAwesomeIcons.mapLocationDot, '288 Constituencies covered'),
        const SizedBox(height: 14),
        _brandFeature(FontAwesomeIcons.chartLine, '48 MPs \u2014 live data'),
      ],
    );
  }

  Widget _brandFeature(FaIconData icon, String text) {
    return Row(
      children: [
        FaIcon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _formPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Welcome back', style: TextStyle(color: _darkText, fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Sign in to continue', style: TextStyle(color: _mutedText, fontSize: 14)),
        const SizedBox(height: 28),

        const Text('Email', style: TextStyle(color: _darkText, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: _darkText, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'you@example.com',
            hintStyle: const TextStyle(color: Color(0xFFAAB2C0), fontSize: 15),
            prefixIcon: const Icon(Icons.mail_outline, color: _mutedText, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _blue, width: 1.5)),
          ),
        ),
        const SizedBox(height: 18),

        const Text('Password', style: TextStyle(color: _darkText, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscure,
          style: const TextStyle(color: _darkText, fontSize: 15),
          decoration: InputDecoration(
            hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
            hintStyle: const TextStyle(color: Color(0xFFAAB2C0), fontSize: 15),
            prefixIcon: const Icon(Icons.lock_outline, color: _mutedText, size: 20),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: _mutedText, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _blue, width: 1.5)),
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _loading ? null : _login,
            style: ElevatedButton.styleFrom(backgroundColor: _blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: _mutedText, fontSize: 14),
              children: [
                const TextSpan(text: "Don't have an account? "),
                TextSpan(
                  text: 'Sign up',
                  style: const TextStyle(color: _blue, fontWeight: FontWeight.w700),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}