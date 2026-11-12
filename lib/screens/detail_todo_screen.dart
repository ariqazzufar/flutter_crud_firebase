import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';
import 'edit_todo_screen.dart';

class DetailTodoScreen extends StatelessWidget {
  final Map<String, dynamic> todoData;
  const DetailTodoScreen({super.key, required this.todoData});

  Future<void> deleteTransaction(BuildContext context) async {
    CustomDialog.showConfirmation(
      context: context,
      title: "Hapus Transaksi",
      message: "Apakah Anda yakin ingin menghapus catatan transaksi ini?",
      onConfirm: () async {
        try {
          String uid = FirebaseAuth.instance.currentUser!.uid;
          await FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .collection("transactions")
              .doc(todoData['transaction_id'])
              .delete();

          if (context.mounted) {
            CustomSnackBar.showSuccess(context, "Data berhasil dihapus");
            Navigator.pop(context);
          }
        } catch (e) {
          if (context.mounted) {
            CustomSnackBar.showError(context, e.toString());
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleC = TextEditingController(text: todoData['title']);
    final amountC = TextEditingController(text: todoData['amount'].toString());
    final typeC = TextEditingController(text: todoData['type']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Transaksi"),
        backgroundColor: Colors.white,
        foregroundColor: AppColor.secondary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTodoScreen(todoData: todoData),
                ),
              );
            },
            child: const Text("Edit"),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CustomInput(controller: titleC, label: "Judul Transaksi", hint: "", disabled: true),
          CustomInput(controller: amountC, label: "Nominal Angka (Rp)", hint: "", disabled: true),
          CustomInput(controller: typeC, label: "Tipe Transaksi", hint: "", disabled: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColor.warning),
              onPressed: () => deleteTransaction(context),
              child: const Text("Hapus Transaksi", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}