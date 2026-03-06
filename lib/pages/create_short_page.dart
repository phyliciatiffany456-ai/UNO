import 'package:flutter/material.dart';

class CreateShortPage extends StatelessWidget {
  const CreateShortPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1013),
        title: const Text(
          'Tambah Short',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1E24),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: const Center(
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tulis caption short...',
                hintStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0x44FFFFFF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF6A2D)),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6A2D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Bagikan Short'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
