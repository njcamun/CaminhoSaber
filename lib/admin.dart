// lib/admin.dart
import 'package:flutter/material.dart';
import 'package:caminho_do_saber/ui/screens/web_content_admin_screen.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SelectionArea(child: WebContentAdminScreen()),
  ));
}
