import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';

class EditTodoScreen extends StatefulWidget {
  final Map<String, dynamic> todoData;
  const EditTodoScreen({super.key, required this.todoData});

  @override
  State<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  late TextEditingController titleC;
  late TextEditingController amountC;
  late String selectedType;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleC = TextEditingController(text: widget.todoData['title']);
    amountC = TextEditingController(text: widget.todoData['amount'].toString());
    selectedType = widget.todoData['type'] ?? 'Pemasukan';
  }

  Future<void> updateTransaction() async {
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

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("transactions")
          .doc(widget.todoData['transaction_id'])
          .update({
        "title": titleC.text.trim(),
        "amount": parsedAmount,
        "type": selectedType,
      });

      if (mounted) {
        CustomSnackBar.showSuccess(context, "Berhasil memperbarui transaksi");
        Navigator.pop(context);
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
        title: const Text("Edit Transaksi"),
        backgroundColor: Colors.white,
        foregroundColor: AppColor.secondary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CustomInput(controller: titleC, label: "Judul Transaksi", hint: "Edit Judul"),
          CustomInput(
            controller: amountC,
            label: "Nominal Angka (Rp)",
            hint: "Edit Nominal",
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
              onPressed: isLoading ? null : updateTransaction,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}