import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SafeAssetImage extends StatelessWidget {
  final String path;
  final BoxFit? fit;
  final double? width;
  final double? height;

  const SafeAssetImage({
    super.key,
    required this.path,
    this.fit,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Se o caminho começa com 'assets/', tratamos como asset da app
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    // Caso contrário, tratamos como um ficheiro local (foto tirada pela câmara)
    if (kIsWeb) return _buildErrorWidget();

    try {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      }
    } catch (e) {
      return _buildErrorWidget();
    }

    // Se não for nem asset nem ficheiro válido, mostra o erro
    return _buildErrorWidget();
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: Icon(
        Icons.person_rounded,
        color: Colors.grey.shade600,
        size: (width != null) ? width! * 0.6 : 30,
      ),
    );
  }
}
