import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PreviewPage extends StatefulWidget {
  // final XFile picture;
  final File picture;
  final String pictureName;

  const PreviewPage({super.key, required this.picture, required this.pictureName});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview Image"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(
              widget.picture,
              fit: BoxFit.cover,
              width: 250,
            ),
            const SizedBox(
              height: 24,
            ),
            Text(widget.pictureName)
          ],
        ),
      ),
    );
  }
}
