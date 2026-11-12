import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool isLoading = false;
  bool obscureText = true;

  Future<void> register() async {
    if (nameC.text.isEmpty || emailC.text.isEmpty || passC.text.isEmpty) {
      CustomSnackBar.showError(context, "Semua form wajib diisi");
      return;
    }
    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailC.text.trim(),
        password: passC.text,
      );
      String uid = userCredential.user!.uid;

      // Simpan data user ke Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "user_id": uid,
        "name": nameC.text,
        "email": emailC.text.trim(),
        "created_at": DateTime.now().toIso8601String(),
      });

      if (mounted) {
        CustomSnackBar.showSuccess(context, "Berhasil mendaftar!");
        Navigator.pop(context); // Kembali ke Login
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Terjadi kesalahan";
      if (e.code == 'weak-password') msg = "Kata sandi terlalu lemah";
      if (e.code == 'email-already-in-use') msg = "Email sudah terdaftar";
      CustomSnackBar.showError(context, msg);
    } catch (e) {
      CustomSnackBar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pendaftaran"),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Daftar Akun Baru",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          CustomInput(
            controller: nameC,
            label: "Nama Lengkap",
            hint: "Nama Anda",
          ),
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
              onPressed: isLoading ? null : register,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Daftar", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}