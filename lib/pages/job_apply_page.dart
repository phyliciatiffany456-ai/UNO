import 'package:flutter/material.dart';

import '../models/cv_store.dart';
import '../widgets/app_button.dart';
import 'profile_edit_page.dart';

class JobApplyPage extends StatefulWidget {
  const JobApplyPage({super.key, required this.company});

  final String company;

  @override
  State<JobApplyPage> createState() => _JobApplyPageState();
}

class _JobApplyPageState extends State<JobApplyPage> {
  bool _submitted = false;
  int _visibleStatusCount = 0;
  bool _showStatusTitle = false;

  static const List<String> _statusSteps = <String>[
    'Application Submitted...',
    'Application Seen by the HR...',
    'Waiting for review...',
  ];

  Future<void> _submitCv() async {
    if (!CvStore.hasCv) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CV belum ada. Upload dulu di Edit Profil.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _submitted = true;
      _showStatusTitle = false;
      _visibleStatusCount = 0;
    });

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _showStatusTitle = true;
    });

    for (int i = 1; i <= _statusSteps.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() {
        _visibleStatusCount = i;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1013),
        title: Text(
          '${widget.company} - Apply',
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
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: const Color(0xFFCFCFCF),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<String?>(
            valueListenable: CvStore.fileName,
            builder: (BuildContext context, String? fileName, Widget? child) {
              final bool hasCv = fileName != null;
              return Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF13151A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF24262E)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Curriculum Vitae',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasCv ? fileName : 'Belum ada CV yang di-upload',
                            style: TextStyle(
                              color: hasCv ? Colors.white70 : Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (!hasCv)
                      SizedBox(
                        width: 96,
                        child: AppButton(
                          label: 'Upload CV',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ProfileEditPage(),
                            ),
                          ),
                          variant: AppButtonVariant.outline,
                          height: 34,
                          fontSize: 11,
                        ),
                      )
                    else
                      SizedBox(
                        width: 96,
                        child: AppButton(
                          label: _submitted ? 'Submitted' : 'Submit CV',
                          onTap: _submitted ? null : _submitCv,
                          height: 34,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF13151A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF24262E)),
            ),
            child: !_submitted
                ? const Text(
                    'Status akan muncul setelah CV berhasil disubmit.',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedOpacity(
                        opacity: _showStatusTitle ? 1 : 0,
                        duration: const Duration(milliseconds: 350),
                        child: const Text(
                          'Status',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (int i = 0; i < _visibleStatusCount; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: AnimatedOpacity(
                            opacity: 1,
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _statusSteps[i],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          if (_submitted) ...[
            const SizedBox(height: 8),
            const Text(
              'Progres akan update otomatis. Pantau halaman ini secara berkala.',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
