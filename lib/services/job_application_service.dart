import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CvUploadResult {
  const CvUploadResult({
    required this.fileName,
    required this.storagePath,
    required this.publicUrl,
  });

  final String fileName;
  final String storagePath;
  final String publicUrl;
}

class JobApplicationRecord {
  const JobApplicationRecord({
    required this.id,
    required this.jobPostId,
    required this.applicantId,
    required this.applicantName,
    required this.cvFileName,
    required this.cvPublicUrl,
    required this.status,
    this.reviewerNote,
    this.reviewedAt,
    this.interviewType,
    this.interviewLocation,
    this.interviewLink,
    this.interviewAt,
    this.createdAt,
  });

  final String id;
  final String jobPostId;
  final String applicantId;
  final String applicantName;
  final String cvFileName;
  final String cvPublicUrl;
  final String status;
  final String? reviewerNote;
  final DateTime? reviewedAt;
  final String? interviewType;
  final String? interviewLocation;
  final String? interviewLink;
  final DateTime? interviewAt;
  final DateTime? createdAt;
}

class JobApplicationService {
  JobApplicationService({
    SupabaseClient? client,
    Random? random,
  })  : _client = client ?? Supabase.instance.client,
        _random = random ?? Random.secure();

  static const String applicationsTable = 'job_applications';
  static const String cvBucket = 'job-cvs';

  final SupabaseClient _client;
  final Random _random;

  User? get currentUser => _client.auth.currentUser;

  User _requireUser() {
    final User? user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Please sign in first.');
    }
    return user;
  }

  Future<CvUploadResult> uploadCv(PlatformFile file) async {
    final User user = _requireUser();
    final Uint8List? bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw Exception('File CV tidak terbaca. Coba pilih ulang file.');
    }

    final String extension = _extension(file.name);
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int randomPart = _random.nextInt(1000000000);
    final String path = '${user.id}/$now-$randomPart$extension';

    await _client.storage.from(cvBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: _contentType(extension),
          ),
        );

    final String url = _client.storage.from(cvBucket).getPublicUrl(path);

    return CvUploadResult(
      fileName: file.name,
      storagePath: path,
      publicUrl: url,
    );
  }

  Future<void> submitApplication({
    required String jobPostId,
    required CvUploadResult cv,
  }) async {
    final User user = _requireUser();
    final List<Map<String, dynamic>> posts = await _client
        .from('posts')
        .select('author_id,job_deadline')
        .eq('id', jobPostId)
        .limit(1);
    if (posts.isNotEmpty && posts.first['author_id']?.toString() == user.id) {
      throw Exception('Pemilik loker tidak bisa submit CV ke post sendiri.');
    }
    if (posts.isNotEmpty) {
      final DateTime? deadline = DateTime.tryParse(
        (posts.first['job_deadline'] as String?) ?? '',
      );
      if (_isDeadlineClosed(deadline)) {
        throw Exception('Lowongan ini sudah ditutup karena melewati deadline.');
      }
    }

    await _client.from(applicationsTable).upsert(
      <String, dynamic>{
        'job_post_id': jobPostId,
        'applicant_id': user.id,
        'cv_file_name': cv.fileName,
        'cv_storage_path': cv.storagePath,
        'cv_public_url': cv.publicUrl,
        'status': 'waiting_review',
      },
      onConflict: 'job_post_id,applicant_id',
    );
  }

  Future<List<JobApplicationRecord>> fetchApplicationsForJob(
    String jobPostId,
  ) async {
    final User reviewer = _requireUser();
    final List<Map<String, dynamic>> rows = await _client
        .from(applicationsTable)
        .select()
        .eq('job_post_id', jobPostId)
        .neq('applicant_id', reviewer.id)
        .order('created_at', ascending: false);

    final List<String> applicantIds = rows
        .map((Map<String, dynamic> row) => row['applicant_id'].toString())
        .toSet()
        .toList();
    Map<String, String> applicantNames = <String, String>{};
    if (applicantIds.isNotEmpty) {
      final List<Map<String, dynamic>> profileRows = await _client
          .from('profiles')
          .select('user_id,full_name')
          .inFilter('user_id', applicantIds);
      applicantNames = <String, String>{
        for (final Map<String, dynamic> row in profileRows)
          row['user_id'].toString():
              (row['full_name'] as String?)?.trim().isNotEmpty == true
                  ? row['full_name'].toString()
                  : 'User',
      };
    }

    return rows.map((Map<String, dynamic> row) {
      final String applicantId = row['applicant_id'].toString();
      return JobApplicationRecord(
        id: row['id'].toString(),
        jobPostId: row['job_post_id'].toString(),
        applicantId: applicantId,
        applicantName: applicantNames[applicantId] ?? applicantId,
        cvFileName: (row['cv_file_name'] as String?) ?? '-',
        cvPublicUrl: (row['cv_public_url'] as String?) ?? '',
        status: (row['status'] as String?) ?? 'waiting_review',
        reviewerNote: row['reviewer_note'] as String?,
        reviewedAt: DateTime.tryParse((row['reviewed_at'] as String?) ?? ''),
        interviewType: row['interview_type'] as String?,
        interviewLocation: row['interview_location'] as String?,
        interviewLink: row['interview_link'] as String?,
        interviewAt: DateTime.tryParse((row['interview_at'] as String?) ?? ''),
        createdAt: DateTime.tryParse((row['created_at'] as String?) ?? ''),
      );
    }).toList();
  }

  Future<JobApplicationRecord?> fetchMyApplicationForJob(String jobPostId) async {
    final User me = _requireUser();
    final List<Map<String, dynamic>> rows = await _client
        .from(applicationsTable)
        .select()
        .eq('job_post_id', jobPostId)
        .eq('applicant_id', me.id)
        .limit(1);
    if (rows.isEmpty) return null;
    final Map<String, dynamic> row = rows.first;
    return JobApplicationRecord(
      id: row['id'].toString(),
      jobPostId: row['job_post_id'].toString(),
      applicantId: row['applicant_id'].toString(),
      applicantName: me.email ?? 'User',
      cvFileName: (row['cv_file_name'] as String?) ?? '-',
      cvPublicUrl: (row['cv_public_url'] as String?) ?? '',
      status: (row['status'] as String?) ?? 'waiting_review',
      reviewerNote: row['reviewer_note'] as String?,
      reviewedAt: DateTime.tryParse((row['reviewed_at'] as String?) ?? ''),
      interviewType: row['interview_type'] as String?,
      interviewLocation: row['interview_location'] as String?,
      interviewLink: row['interview_link'] as String?,
      interviewAt: DateTime.tryParse((row['interview_at'] as String?) ?? ''),
      createdAt: DateTime.tryParse((row['created_at'] as String?) ?? ''),
    );
  }

  Future<void> scheduleInterview({
    required String applicationId,
    required String interviewType,
    String? interviewLocation,
    String? interviewLink,
    DateTime? interviewAt,
  }) async {
    _requireUser();
    final String normalizedType = interviewType.toLowerCase();
    if (normalizedType != 'onsite' && normalizedType != 'online') {
      throw Exception('Tipe interview tidak valid.');
    }
    if (normalizedType == 'onsite' &&
        (interviewLocation == null || interviewLocation.trim().isEmpty)) {
      throw Exception('Lokasi interview onsite wajib diisi.');
    }
    if (normalizedType == 'online' &&
        (interviewLink == null || interviewLink.trim().isEmpty)) {
      throw Exception('Link meeting online wajib diisi.');
    }

    await _client.from(applicationsTable).update(<String, dynamic>{
      'interview_type': normalizedType,
      'interview_location':
          normalizedType == 'onsite' ? interviewLocation?.trim() : null,
      'interview_link': normalizedType == 'online' ? interviewLink?.trim() : null,
      'interview_at': interviewAt?.toIso8601String(),
    }).eq('id', applicationId);
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? reviewerNote,
  }) async {
    final User reviewer = _requireUser();
    try {
      await _client.rpc(
        'owner_update_application_status',
        params: <String, dynamic>{
          'target_application_id': applicationId,
          'new_status': status,
          'new_note': reviewerNote,
        },
      );
    } on PostgrestException catch (error) {
      final String message = error.message.toLowerCase();
      final bool rpcNotFound =
          error.code == 'PGRST202' ||
          message.contains('owner_update_application_status') ||
          message.contains('function') && message.contains('not found');
      if (!rpcNotFound) {
        rethrow;
      }

      await _client.from(applicationsTable).update(<String, dynamic>{
        'status': status,
        'reviewer_id': reviewer.id,
        'reviewer_note': reviewerNote,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', applicationId);
    }
  }

  String _extension(String fileName) {
    final int dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '.pdf';
    final String ext = fileName.substring(dot).toLowerCase();
    if (ext.length > 10) return '.pdf';
    return ext;
  }

  String _contentType(String ext) {
    switch (ext) {
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.pdf':
      default:
        return 'application/pdf';
    }
  }

  bool _isDeadlineClosed(DateTime? deadline) {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline);
  }
}
