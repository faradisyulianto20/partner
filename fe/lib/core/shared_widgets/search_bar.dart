import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF194F78)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: GoogleFonts.nunito(color: Colors.black54),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.nunito(
              color: Colors.black38, // Warna abu-abu soft
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(Icons.search),
            prefixIconColor: Colors.black38,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical:
                  12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
