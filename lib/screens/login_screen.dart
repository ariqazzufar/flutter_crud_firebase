import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool isLoading = false;
  bool obscureText = true;

  Future<void> login() async {
    if (emailC.text.isEmpty || passC.text.isEmpty) {
      CustomSnackBar.showError(context, "Email dan password wajib diisi");
      return;
    }
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailC.text.trim(),
        password: passC.text,
      );
      // Perpindahan layar ditangani otomatis oleh authStateChanges di main.dart
    } on FirebaseAuthException catch (e) {
      String msg = "Gagal login";
      if (e.code == 'user-not-found') msg = "Akun tidak ditemukan";
      if (e.code == 'wrong-password') msg = "Kata sandi salah";
      CustomSnackBar.showError(context, msg);
    } catch (e) {
      CustomSnackBar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            height: 180,
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(gradient: AppColor.primaryGradient),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TODO App",
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text("Native Flutter + Firebase", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Masuk",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                CustomInput(
                  controller: emailC,
                  label: "Email",
                  hint: "email@domain.com",
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomInput(
                  controller: passC,
                  label: "Kata Sandi",
                  hint: "******",
                  obscureText: obscureText,
                  suffixIcon: IconButton(
                    icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscureText = !obscureText),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: isLoading ? null : login,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Masuk", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColor.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text("Daftar", style: TextStyle(color: AppColor.primary, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}