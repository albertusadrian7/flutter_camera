import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'camera_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Camera Test"),
        ),
        body: SafeArea(
          child: Center(
            child: ElevatedButton(
              onPressed: () async {
                await availableCameras().then((value) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CameraPage(cameras: value))));
              },
              child: const Text("Take a picture"),
            ),
          ),
        ));
  }
}
