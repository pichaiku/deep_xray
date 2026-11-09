import 'dart:io';
import 'package:flutter/material.dart';

class XRayViewer extends StatelessWidget {
  final File xrayFile;

  const XRayViewer({
    super.key,
    required this.xrayFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            xrayFile,
            fit: BoxFit.contain,
            color: Colors.white,
            colorBlendMode: BlendMode.modulate,
          ),
        ),
      ),
    );
  }
} 