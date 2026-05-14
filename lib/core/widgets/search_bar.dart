import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String hintText;

  const SearchBarWidget({super.key , required this.controller, required this.onChanged, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
              ],
            ),
            child: TextField(
              controller: controller ,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: Icon(Icons.search),
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
