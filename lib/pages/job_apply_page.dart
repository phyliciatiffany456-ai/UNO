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
  List<JobApplicationRecord> _applications = <JobApplicationRecord>[];
  int _visibleStatusCount = 0;
  bool _showStatusTitle = false;

  static const List<String> _statusSteps = <String>[
    'Application Submitted...',
    'Application Seen by the HR...',
    'Waiting for review...',
  ];

  bool get _isOwner => _applicationService.currentUser?.id == widget.post.authorId;

  @override
  void initState() {
    super.initState();
    if (_isOwner) {
      _loadApplications();
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status ${record.applicantName} -> $status')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update status: $error')),
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
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1013),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF2D313B)),
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
                                Text(
                                  'Status: ${item.status}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppButton(
                                        label: 'Review',
                                        onTap: () =>
                                            _updateStatus(item, 'under_review'),
                                        variant: AppButtonVariant.outline,
                                        height: 32,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: AppButton(
                                        label: 'Accept',
                                        onTap: () =>
                                            _updateStatus(item, 'accepted'),
                                        height: 32,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: AppButton(
                                        label: 'Reject',
                                        onTap: () =>
                                            _updateStatus(item, 'rejected'),
                                        variant: AppButtonVariant.outline,
                                        height: 32,
                                        fontSize: 11,
                                      ),
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
                          onTap: (_uploadingCv || _isOwner)
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
                          onTap: (_submitted || _isOwner) ? null : _submitCv,
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
                        : 'Status akan muncul setelah CV berhasil disubmit.',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
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
