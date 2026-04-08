import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/cv_store.dart';
import '../models/post_item.dart';
import '../services/job_application_service.dart';
import '../widgets/app_button.dart';

class JobApplyPage extends StatefulWidget {
  const JobApplyPage({super.key, required this.post});

  final PostItem post;

  @override
  State<JobApplyPage> createState() => _JobApplyPageState();
}

class _JobApplyPageState extends State<JobApplyPage> {
  final JobApplicationService _applicationService = JobApplicationService();

  bool _submitted = false;
  bool _uploadingCv = false;
  bool _loadingApplications = false;
  bool _loadingMyApplication = false;
  List<JobApplicationRecord> _applications = <JobApplicationRecord>[];
  JobApplicationRecord? _myApplication;

  bool get _isOwner => _applicationService.currentUser?.id == widget.post.authorId;
  bool get _isDeadlineClosed {
    final DateTime? deadline = widget.post.jobDeadline;
    if (deadline == null) return false;
    final DateTime now = DateTime.now();
    final DateTime todayDateOnly = DateTime(now.year, now.month, now.day);
    final DateTime deadlineDateOnly = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
    );
    return todayDateOnly.isAfter(deadlineDateOnly);
  }

  @override
  void initState() {
    super.initState();
    if (_isOwner) {
      _loadApplications();
    } else {
      _loadMyApplication();
    }
  }

  Future<void> _loadMyApplication() async {
    setState(() {
      _loadingMyApplication = true;
    });
    try {
      final JobApplicationRecord? record = await _applicationService
          .fetchMyApplicationForJob(widget.post.id);
      if (!mounted) return;
      setState(() {
        _myApplication = record;
        _submitted = record != null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingMyApplication = false;
        });
      }
    }
  }

  Future<void> _loadApplications() async {
    setState(() {
      _loadingApplications = true;
    });
    try {
      final List<JobApplicationRecord> rows = await _applicationService
          .fetchApplicationsForJob(widget.post.id);
      if (!mounted) return;
      setState(() {
        _applications = rows;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat pelamar.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingApplications = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadCv() async {
    setState(() {
      _uploadingCv = true;
    });

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['pdf', 'doc', 'docx'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;
      final PlatformFile file = result.files.first;
      final CvUploadResult uploaded = await _applicationService.uploadCv(file);
      CvStore.setCv(
        name: uploaded.fileName,
        path: uploaded.storagePath,
        url: uploaded.publicUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CV berhasil di-upload: ${uploaded.fileName}'),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload CV: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingCv = false;
        });
      }
    }
  }

  Future<void> _submitCv() async {
    if (_isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pemilik loker tidak bisa submit CV sendiri.'),
        ),
      );
      return;
    }
    if (_isDeadlineClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lowongan ini sudah ditutup karena melewati deadline.'),
        ),
      );
      return;
    }
    final String? fileName = CvStore.fileName.value;
    final String? filePath = CvStore.filePath.value;
    final String? fileUrl = CvStore.fileUrl.value;

    if (fileName == null || filePath == null || fileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CV belum ada. Upload dulu.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final CvUploadResult cv = CvUploadResult(
      fileName: fileName,
      storagePath: filePath,
      publicUrl: fileUrl,
    );

    try {
      await _applicationService.submitApplication(
        jobPostId: widget.post.id,
        cv: cv,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal submit aplikasi: $error')),
      );
      return;
    }

    setState(() {
      _submitted = true;
    });
    await _loadMyApplication();
  }

  List<String> _statusLinesForApplicant(String status) {
    switch (status) {
      case 'accepted':
        return const <String>[
          'Application Submitted...',
          'Application Seen by the HR...',
          'Accepted. Kamu lolos tahap ini.',
        ];
      case 'rejected':
        return const <String>[
          'Application Submitted...',
          'Application Seen by the HR...',
          'Rejected. Tetap semangat, coba lowongan lain.',
        ];
      case 'under_review':
        return const <String>[
          'Application Submitted...',
          'Application Seen by the HR...',
          'Waiting for review...',
        ];
      case 'waiting_review':
      default:
        return const <String>[
          'Application Submitted...',
          'Waiting for review...',
        ];
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'under_review':
        return const Color(0xFFF59E0B);
      case 'waiting_review':
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'under_review':
        return 'Under Review';
      case 'waiting_review':
      default:
        return 'Waiting Review';
    }
  }

  Color _statusActionColor(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'under_review':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Widget _statusActionButton({
    required String label,
    required String targetStatus,
    required String currentStatus,
    required VoidCallback onTap,
  }) {
    final bool isActive = currentStatus == targetStatus;
    final Color activeColor = _statusActionColor(targetStatus);
    return Expanded(
      child: SizedBox(
        height: 32,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: isActive ? null : onTap,
            child: Ink(
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withOpacity(0.22)
                    : const Color(0xFF0E1014),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive ? activeColor : const Color(0xFF2D313B),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? activeColor : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    JobApplicationRecord record,
    String status,
  ) async {
    try {
      await _applicationService.updateApplicationStatus(
        applicationId: record.id,
        status: status,
      );
      await _loadApplications();
    } catch (error) {
      if (!mounted) return;
      final String raw = error.toString().toLowerCase();
      final String message =
          (raw.contains('owner_update_application_status') ||
              raw.contains('not_job_owner'))
          ? 'Gagal update status. Pastikan kamu pemilik loker dan schema Supabase terbaru sudah dijalankan (supabase/schema.sql).'
          : 'Gagal update status: $error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1013),
        title: Text(
          '${widget.post.name} - Apply',
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF13151A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF24262E)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Perusahaan: ${widget.post.name}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Bidang: ${widget.post.role}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_isOwner) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF13151A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF24262E)),
              ),
              child: _loadingApplications
                  ? const Center(child: CircularProgressIndicator())
                  : _applications.isEmpty
                  ? const Text(
                      'Belum ada kandidat yang submit CV.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Review Kandidat',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._applications.map((JobApplicationRecord item) {
                          final Color statusColor = _statusColor(item.status);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1013),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: (item.status == 'accepted' ||
                                        item.status == 'rejected')
                                    ? statusColor.withOpacity(0.8)
                                    : const Color(0xFF2D313B),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.applicantName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'CV: ${item.cvFileName}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: statusColor.withOpacity(0.9),
                                    ),
                                  ),
                                  child: Text(
                                    _statusLabel(item.status),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _statusActionButton(
                                      label: 'Review',
                                      targetStatus: 'under_review',
                                      currentStatus: item.status,
                                      onTap: () =>
                                          _updateStatus(item, 'under_review'),
                                    ),
                                    const SizedBox(width: 6),
                                    _statusActionButton(
                                      label: 'Accept',
                                      targetStatus: 'accepted',
                                      currentStatus: item.status,
                                      onTap: () => _updateStatus(item, 'accepted'),
                                    ),
                                    const SizedBox(width: 6),
                                    _statusActionButton(
                                      label: 'Reject',
                                      targetStatus: 'rejected',
                                      currentStatus: item.status,
                                      onTap: () => _updateStatus(item, 'rejected'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
            ),
            const SizedBox(height: 12),
          ],
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
                        width: 106,
                        child: AppButton(
                          label: _uploadingCv ? 'Uploading...' : 'Upload CV',
                          onTap: (_uploadingCv || _isOwner || _isDeadlineClosed)
                              ? null
                              : _pickAndUploadCv,
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
                          onTap: (_submitted || _isOwner || _isDeadlineClosed)
                              ? null
                              : _submitCv,
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
                ? Text(
                    _isOwner
                        ? 'Kamu pemilik loker. Review kandidat dari daftar di atas.'
                        : (_isDeadlineClosed
                            ? 'Lowongan ini sudah ditutup karena melewati deadline.'
                            : 'Status akan muncul setelah CV berhasil disubmit.'),
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_loadingMyApplication && !_isOwner)
                        const Text(
                          'Memuat status terbaru...',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      for (final String line in _statusLinesForApplicant(
                        _myApplication?.status ?? 'waiting_review',
                      ))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            line,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.45,
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
