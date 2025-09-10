import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchWidget({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[500]!.withOpacity(0.6),
            offset: const Offset(1.0, 1.0),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextFormField(
        onChanged: onChanged, // ✅ fire search filter
        decoration: InputDecoration(
          hintText: 'Search by job...',
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(38)),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          suffixIcon: const Icon(Icons.search, size: 24),
          prefixIcon: const Icon(Icons.work, size: 24),
        ),
      ),
    );
  }
}
