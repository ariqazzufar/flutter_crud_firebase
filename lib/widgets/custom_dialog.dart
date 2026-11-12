import 'package:flutter/material.dart';
import '../utils/app_color.dart';

class CustomDialog {
  static void showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColor.secondarySoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: AppColor.secondarySoft)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text("Ya", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}