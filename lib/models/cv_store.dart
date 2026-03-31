import 'package:flutter/foundation.dart';

class CvStore {
  static final ValueNotifier<String?> fileName = ValueNotifier<String?>(null);

  static bool get hasCv => fileName.value != null;

  static void setCv(String name) {
    fileName.value = name;
  }
}
