import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/app_button.dart';

class OnlineMeetingPage extends StatefulWidget {
  const OnlineMeetingPage({
    super.key,
    required this.meetingLink,
    this.scheduledAt,
    this.title = 'Interview Online',
  });

  final String meetingLink;
  final DateTime? scheduledAt;
  final String title;

  @override
  State<OnlineMeetingPage> createState() => _OnlineMeetingPageState();
}

class _OnlineMeetingPageState extends State<OnlineMeetingPage> {
  bool _checking = false;
  bool _cameraGranted = false;
  bool _micGranted = false;
  bool _openingMeeting = false;

  @override
  void initState() {
    super.initState();
    _refreshPermissionState();
  }

  Future<void> _refreshPermissionState() async {
    final PermissionStatus camera = await Permission.camera.status;
    final PermissionStatus mic = await Permission.microphone.status;
    if (!mounted) return;
    setState(() {
      _cameraGranted = camera.isGranted;
      _micGranted = mic.isGranted;
    });
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _checking = true;
    });
    try {
      final Map<Permission, PermissionStatus> result = await <Permission>[
        Permission.camera,
        Permission.microphone,
      ].request();
      if (!mounted) return;
      setState(() {
        _cameraGranted = result[Permission.camera]?.isGranted ?? false;
        _micGranted = result[Permission.microphone]?.isGranted ?? false;
      });
      if (!_cameraGranted || !_micGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Akses kamera/mikrofon belum diizinkan. Kamu tetap bisa join, tapi audio/video bisa terbatas.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _checking = false;
        });
      }
    }
  }

  Future<void> _joinMeeting() async {
    setState(() {
      _openingMeeting = true;
    });
    try {
      final Uri? uri = Uri.tryParse(widget.meetingLink.trim());
      if (uri == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link meeting tidak valid.')),
        );
        return;
      }
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka aplikasi meeting.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _openingMeeting = false;
        });
      }
    }
  }

  String _formatDateTime(DateTime value) {
    final String day = value.day.toString().padLeft(2, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1013),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF13151A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF24262E)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Persiapan Interview',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.scheduledAt != null)
                  Text(
                    'Jadwal: ${_formatDateTime(widget.scheduledAt!)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                const SizedBox(height: 6),
                Text(
                  'Kamera: ${_cameraGranted ? 'Diizinkan' : 'Belum diizinkan'}',
                  style: TextStyle(
                    color: _cameraGranted
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFF59E0B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Mikrofon: ${_micGranted ? 'Diizinkan' : 'Belum diizinkan'}',
                  style: TextStyle(
                    color: _micGranted
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFF59E0B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: _checking ? 'Meminta Izin...' : 'Izinkan Kamera & Mic',
                  onTap: _checking ? null : _requestPermissions,
                  variant: AppButtonVariant.outline,
                  height: 34,
                  fontSize: 12,
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: _openingMeeting ? 'Membuka...' : 'Masuk Meeting',
                  onTap: _openingMeeting ? null : _joinMeeting,
                  height: 36,
                  fontSize: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
