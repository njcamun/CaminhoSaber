// lib/services/web_admin_service.dart

import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class WebAdminService {
  // MÉTODO PARA FAZER DOWNLOAD DO JSON NO NAVEGADOR
  static void downloadJson(Map<String, dynamic> data, String fileName) {
    if (!kIsWeb) return;

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final bytes = utf8.encode(jsonString);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
