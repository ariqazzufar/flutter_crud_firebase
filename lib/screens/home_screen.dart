import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_color.dart';
import '../widgets/custom_dialog.dart';
import 'add_todo_screen.dart';
import 'all_todo_screen.dart';
import 'detail_todo_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 1. Stream Profil User & Header
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const SizedBox();
                }
                var userData = snapshot.data!.data() as Map<String, dynamic>?;
                String name = userData?['name'] ?? 'User';

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Selamat datang kembali,",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.secondarySoft,
                          ),
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppColor.error),
                      onPressed: () {
                        CustomDialog.showConfirmation(
                          context: context,
                          title: "Logout",
                          message: "Apakah Anda yakin ingin keluar?",
                          onConfirm: () => FirebaseAuth.instance.signOut(),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // 2. Card Statistik Total Transaksi
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .collection("transactions")
                  .snapshots(),
              builder: (context, snapshot) {
                var docs = snapshot.data?.docs ?? [];
                int totalTransaksi = docs.length;
                int pemasukan = 0;
                int pengeluaran = 0;

                for (var doc in docs) {
                  var d = doc.data() as Map<String, dynamic>;
                  int nominal = (d['amount'] ?? 0) as int;
                  if (d['type'] == 'Pemasukan') {
                    pemasukan += nominal;
                  } else {
                    pengeluaran += nominal;
                  }
                }
                int saldo = pemasukan - pengeluaran;

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColor.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Saldo",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            "Total Transaksi: $totalTransaksi",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatRupiah(saldo),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Masuk: +${formatRupiah(pemasukan)}",
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            "Keluar: -${formatRupiah(pengeluaran)}",
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 3. Header Riwayat Transaksi Terbaru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Riwayat Transaksi Terbaru",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllTodoScreen(),
                      ),
                    );
                  },
                  child: const Text("Tampilkan Semua"),
                ),
              ],
            ),

            // 4. Stream List Transaksi Terbaru (Limit 5)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .collection("transactions")
                  .orderBy("created_at", descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("Belum ada data transaksi")),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                        "${trx['type']} •${trx['created_at'].toString().substring(0, 10)}",
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTodoScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}