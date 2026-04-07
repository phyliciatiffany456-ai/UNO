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
}
