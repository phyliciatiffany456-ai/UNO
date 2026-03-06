import 'package:flutter/material.dart';

class JobApplyPage extends StatelessWidget {
  const JobApplyPage({super.key, required this.company});

  final String company;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1013),
        title: Text(
          '$company - Apply',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
        children: [
          Container(height: 260, color: const Color(0xFFCFCFCF)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFF6A2D)),
            ),
            child: const Text(
              'Send My Curriculum Vitae',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFF6A2D)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Application Submitted...\n'
                  'Application Seen by the HR...\n'
                  'Waiting for review...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
