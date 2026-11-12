import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../utils/app_color.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final titleC = TextEditingController();
  final amountC = TextEditingController();
  String selectedType = 'Pemasukan';
  bool isLoading = false;

  Future<void> addTransaction() async {
    if (titleC.text.isEmpty || amountC.text.isEmpty) {
      CustomSnackBar.showError(context, "Semua form wajib diisi");
      return;
    }

    int? parsedAmount = int.tryParse(amountC.text.trim());
    if (parsedAmount == null || parsedAmount <= 0) {
      CustomSnackBar.showError(context, "Nominal harus berupa angka yang valid");
      return;
    }

    setState(() => isLoading = true);
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String trxId = const Uuid().v1();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("transactions")
          .doc(trxId)
          .set({
        "transaction_id": trxId,
        "title": titleC.text.trim(),
        "amount": parsedAmount,
        "type": selectedType,
        "created_at": DateTime.now().toIso8601String(),
      });

      if (mounted) {
        CustomSnackBar.showSuccess(context, "Berhasil menambahkan transaksi");
        Navigator.pop(context);
      }
    } catch (e) {
      CustomSnackBar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    titleC.dispose();
    amountC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Transaksi"),
        backgroundColor: Colors.white,
        foregroundColor: AppColor.secondary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CustomInput(
            controller: titleC,
            label: "Judul Transaksi",
            hint: "Contoh: Uang Saku / Beli Buku",
          ),
          CustomInput(
            controller: amountC,
            label: "Nominal Angka (Rp)",
            hint: "Contoh: 50000",
            keyboardType: TextInputType.number,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 1, color: AppColor.secondaryExtraSoft),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: "Pemasukan", child: Text("Pemasukan")),
                  DropdownMenuItem(value: "Pengeluaran", child: Text("Pengeluaran")),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => selectedType = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
              onPressed: isLoading ? null : addTransaction,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Tambah Transaksi", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}