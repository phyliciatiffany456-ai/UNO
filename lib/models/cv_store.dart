import 'package:flutter/foundation.dart';

class CvStore {
  static final ValueNotifier<String?> fileName = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> filePath = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> fileUrl = ValueNotifier<String?>(null);

  static bool get hasCv => fileName.value != null;

  static void setCv({
    required String name,
    String? path,
    String? url,
  }) {
    fileName.value = name;
    filePath.value = path;
    fileUrl.value = url;
  }

  static void clear() {
    fileName.value = null;
    filePath.value = null;
    fileUrl.value = null;
  }
}
