import 'package:flutter/foundation.dart';

const String kBaseUrl = 'http://localhost:8000';
const int kUserId = 1;

String get resolvedBaseUrl {
  if (kIsWeb) {
    return kBaseUrl;
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    // Android emulators cannot reach host machine services via localhost.
    return kBaseUrl.replaceFirst('localhost', '10.0.2.2');
  }

  return kBaseUrl;
}
