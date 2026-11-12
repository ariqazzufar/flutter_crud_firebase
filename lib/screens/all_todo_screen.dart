import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_color.dart';
import 'detail_todo_screen.dart';

class AllTodoScreen extends StatelessWidget {
  const AllTodoScreen({super.key});

  String formatRupiah(int nominal) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(nominal);
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Semua Riwayat Transaksi"),
        backgroundColor: Colors.white,
        foregroundColor: AppColor.secondary,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("transactions")
            .orderBy("created_at", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          var docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("Tidak ada data transaksi"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              var trx = docs[index].data() as Map<String, dynamic>;
              bool isIncome = trx['type'] == 'Pemasukan';
              int amount = (trx['amount'] ?? 0) as int;

              return ListTile(
                tileColor: AppColor.primaryExtraSoft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? AppColor.success : AppColor.error,
                ),
                title: Text(
                  trx['title'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${trx['type']} • ${trx['created_at'].toString().substring(0, 10)}",
                ),
                trailing: Text(
                  "${isIncome ? '+' : '-'} ${formatRupiah(amount)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isIncome ? AppColor.success : AppColor.error,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailTodoScreen(todoData: trx),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}