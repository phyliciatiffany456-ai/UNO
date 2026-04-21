import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/cv_store.dart';
import '../models/post_item.dart';
import '../pages/chat_box_page.dart';
import '../services/chat_service.dart';
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
  final ChatService _chatService = ChatService();

  bool _submitted = false;
  bool _uploadingCv = false;
  bool _loadingApplications = false;
  bool _loadingMyApplication = false;
  String? _processingApplicationId;
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
    required VoidCallback? onTap,
    bool isProcessing = false,
  }) {
    final bool isActive = currentStatus == targetStatus;
    final bool enabled = !isActive && !isProcessing && onTap != null;
    final Color activeColor = _statusActionColor(targetStatus);
    return Expanded(
      child: SizedBox(
        height: 32,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: enabled ? onTap : null,
            child: Ink(
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withValues(alpha: 0.22)
                    : isProcessing
                    ? const Color(0xFF1A1D24)
                    : const Color(0xFF0E1014),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive ? activeColor : const Color(0xFF2D313B),
                ),
              ),
              child: Center(
                child: Text(
                  isProcessing ? 'Saving...' : label,
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
    if (_processingApplicationId != null) return;

    if (status == 'accepted') {
      final _AcceptanceFormResult? acceptance = await _showAcceptanceDialog(
        record,
      );
      if (acceptance == null) return;

      setState(() {
        _processingApplicationId = record.id;
      });

      try {
        await _applicationService.updateApplicationStatus(
          applicationId: record.id,
          status: status,
          reviewerNote: _encodeQuestions(acceptance.questions),
        );
        await _applicationService.scheduleInterview(
          applicationId: record.id,
          interviewType: 'onsite',
          interviewLocation: acceptance.location,
          interviewAt: acceptance.interviewAt,
        );
        await _loadApplications();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kandidat berhasil di-accept.')));

        try {
          final String roomId = await _chatService.ensureDirectRoomWithUser(
            otherUserId: record.applicantId,
            otherUserName: record.applicantName,
          );
          await _chatService.sendMessage(
            roomId: roomId,
            content: _buildAcceptanceChatMessage(
              applicantName: record.applicantName,
              location: acceptance.location,
              interviewAt: acceptance.interviewAt,
              questions: acceptance.questions,
            ),
          );
        } catch (chatError) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Status tersimpan, tapi gagal kirim chat interview: $chatError',
              ),
            ),
          );
        }
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update status: $error')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _processingApplicationId = null;
          });
        }
      }
      return;
    }

    setState(() {
      _processingApplicationId = record.id;
    });

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
    } finally {
      if (mounted) {
        setState(() {
          _processingApplicationId = null;
        });
      }
    }
  }

  Future<_AcceptanceFormResult?> _showAcceptanceDialog(
    JobApplicationRecord record,
  ) async {
    final TextEditingController locationController = TextEditingController(
      text: record.interviewLocation ?? '',
    );
    final TextEditingController dateController = TextEditingController(
      text: record.interviewAt != null
          ? _formatInterviewDate(record.interviewAt!)
          : '',
    );
    final TextEditingController questionsController = TextEditingController(
      text: _decodeQuestions(record.reviewerNote).join('\n'),
    );

    DateTime? selectedDate = record.interviewAt;

    final _AcceptanceFormResult? result =
        await showDialog<_AcceptanceFormResult>(
          context: context,
          builder: (BuildContext dialogContext) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                Future<void> pickInterviewDate() async {
                  final DateTime now = DateTime.now();
                  final DateTime initialDate =
                      selectedDate != null && !selectedDate!.isBefore(now)
                      ? selectedDate!
                      : now.add(const Duration(days: 1));
                  final DateTime? pickedDate = await showDatePicker(
                    context: dialogContext,
                    initialDate: initialDate,
                    firstDate: DateTime(now.year, now.month, now.day),
                    lastDate: DateTime(now.year + 3),
                  );
                  if (!dialogContext.mounted || pickedDate == null) return;

                  final TimeOfDay initialTime = selectedDate != null
                      ? TimeOfDay.fromDateTime(selectedDate!)
                      : const TimeOfDay(hour: 9, minute: 0);
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: dialogContext,
                    initialTime: initialTime,
                  );
                  if (pickedTime == null) return;

                  final DateTime combined = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                  setDialogState(() {
                    selectedDate = combined;
                    dateController.text = _formatInterviewDate(combined);
                  });
                }

                return AlertDialog(
                  backgroundColor: const Color(0xFF13151A),
                  title: Text(
                    'Accept ${record.applicantName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDialogField(
                          controller: locationController,
                          label: 'Tempat interview',
                          hintText: 'Contoh: Kantor UNO Jakarta',
                        ),
                        const SizedBox(height: 12),
                        _buildDialogField(
                          controller: dateController,
                          label: 'Tanggal interview',
                          hintText: 'Pilih tanggal dan jam',
                          readOnly: true,
                          onTap: pickInterviewDate,
                        ),
                        const SizedBox(height: 12),
                        _buildDialogField(
                          controller: questionsController,
                          label: 'Pertanyaan untuk pelamar',
                          hintText:
                              'Satu pertanyaan per baris.\nContoh:\nCeritakan pengalaman Anda.\nKenapa tertarik di posisi ini?',
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final String location = locationController.text.trim();
                        final List<String> questions = questionsController.text
                            .split('\n')
                            .map((String line) => line.trim())
                            .where((String line) => line.isNotEmpty)
                            .toList();

                        if (location.isEmpty || selectedDate == null) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Tempat dan tanggal interview wajib diisi.',
                              ),
                            ),
                          );
                          return;
                        }

                        if (questions.isEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Isi minimal satu pertanyaan untuk pelamar.',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.of(dialogContext).pop(
                          _AcceptanceFormResult(
                            location: location,
                            interviewAt: selectedDate!,
                            questions: questions,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Simpan'),
                    ),
                  ],
                );
              },
            );
          },
        );

    locationController.dispose();
    dateController.dispose();
    questionsController.dispose();
    return result;
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0F1013),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D313B)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF22C55E)),
            ),
          ),
        ),
      ],
    );
  }

  String _encodeQuestions(List<String> questions) {
    return questions.join('\n');
  }

  List<String> _decodeQuestions(String? note) {
    if (note == null || note.trim().isEmpty) return const <String>[];
    return note
        .split('\n')
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList();
  }

  String _formatInterviewDate(DateTime value) {
    final String day = value.day.toString().padLeft(2, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }

  List<Widget> _acceptedDetails(JobApplicationRecord? record) {
    if (record == null) return const <Widget>[];

    final List<Widget> details = <Widget>[];
    if (record.interviewLocation != null &&
        record.interviewLocation!.trim().isNotEmpty) {
      details.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'Tempat: ${record.interviewLocation!}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ),
      );
    }
    if (record.interviewAt != null) {
      details.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'Tanggal: ${_formatInterviewDate(record.interviewAt!)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    final List<String> questions = _decodeQuestions(record.reviewerNote);
    if (questions.isNotEmpty) {
      details.add(
        const Padding(
          padding: EdgeInsets.only(top: 2, bottom: 6),
          child: Text(
            'Pertanyaan untuk pelamar:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      for (int index = 0; index < questions.length; index++) {
        details.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${index + 1}. ${questions[index]}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        );
      }
    }

    return details;
  }

  String _buildAcceptanceChatMessage({
    required String applicantName,
    required String location,
    required DateTime interviewAt,
    required List<String> questions,
  }) {
    final StringBuffer buffer = StringBuffer()
      ..writeln('Halo $applicantName, aplikasi kamu diterima untuk lanjut ke tahap interview.')
      ..writeln('Tempat: $location')
      ..writeln('Tanggal: ${_formatInterviewDate(interviewAt)}')
      ..writeln('Pertanyaan yang perlu kamu siapkan:');

    for (int index = 0; index < questions.length; index++) {
      buffer.writeln('${index + 1}. ${questions[index]}');
    }

    buffer.write('Silakan balas chat ini kalau ada yang ingin ditanyakan.');
    return buffer.toString();
  }

  Future<void> _openDirectChat({
    required String otherUserId,
    required String otherUserName,
    required String roomTitle,
  }) async {
    try {
      final String roomId = await _chatService.ensureDirectRoomWithUser(
        otherUserId: otherUserId,
        otherUserName: otherUserName,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatBoxPage(
            initialRoomId: roomId,
            roomTitle: roomTitle,
            isGroupRoom: false,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka chat: $error')),
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
                          final bool isProcessing =
                              _processingApplicationId == item.id;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1013),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: (item.status == 'accepted' ||
                                        item.status == 'rejected')
                                    ? statusColor.withValues(alpha: 0.8)
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
                                    color: statusColor.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: statusColor.withValues(alpha: 0.9),
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
                                      isProcessing: isProcessing,
                                      onTap: isProcessing
                                          ? null
                                          : () => _updateStatus(
                                              item,
                                              'under_review',
                                            ),
                                    ),
                                    const SizedBox(width: 6),
                                    _statusActionButton(
                                      label: 'Accept',
                                      targetStatus: 'accepted',
                                      currentStatus: item.status,
                                      isProcessing: isProcessing,
                                      onTap: isProcessing
                                          ? null
                                          : () =>
                                              _updateStatus(item, 'accepted'),
                                    ),
                                    const SizedBox(width: 6),
                                    _statusActionButton(
                                      label: 'Reject',
                                      targetStatus: 'rejected',
                                      currentStatus: item.status,
                                      isProcessing: isProcessing,
                                      onTap: isProcessing
                                          ? null
                                          : () =>
                                              _updateStatus(item, 'rejected'),
                                    ),
                                  ],
                                ),
                                if (item.status == 'accepted') ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: AppButton(
                                      label: 'Chat Pelamar',
                                      onTap: () => _openDirectChat(
                                        otherUserId: item.applicantId,
                                        otherUserName: item.applicantName,
                                        roomTitle: item.applicantName,
                                      ),
                                      height: 34,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
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
                        if ((_myApplication?.status ?? '') == 'accepted')
                          ..._acceptedDetails(_myApplication),
                        if ((_myApplication?.status ?? '') == 'accepted' &&
                            !_isOwner) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              label: 'Chat HR',
                              onTap: () => _openDirectChat(
                                otherUserId: widget.post.authorId,
                                otherUserName: widget.post.name,
                                roomTitle: widget.post.name,
                              ),
                              height: 38,
                              fontSize: 12,
                            ),
                          ),
                        ],
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

class _AcceptanceFormResult {
  const _AcceptanceFormResult({
    required this.location,
    required this.interviewAt,
    required this.questions,
  });

  final String location;
  final DateTime interviewAt;
  final List<String> questions;
}
