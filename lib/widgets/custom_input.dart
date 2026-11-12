import 'package:flutter/material.dart';
import '../utils/app_color.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool disabled;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  const CustomInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.disabled = false,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: disabled ? AppColor.primaryExtraSoft : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: AppColor.secondaryExtraSoft),
      ),
      child: TextField(
        readOnly: disabled,
        obscureText: obscureText,
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          label: Text(
            label,
            style: const TextStyle(color: AppColor.secondarySoft, fontSize: 14),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.secondarySoft,
          ),
        ),
      ),
    );
  }
}