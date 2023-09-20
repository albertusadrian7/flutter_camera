import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/preview_page.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;

  const CameraPage({super.key, required this.cameras});

  @override
  State<CameraPage> createState() {
    // TODO: implement createState
    return _CameraPageState();
  }
}

class _CameraPageState extends State<CameraPage> {
  // Create a CameraController
  late CameraController cameraController;
  bool isRearCameraSelected = true;
  late File watermarkedImage;

  // Next, initialize the controller. This returns a Future.
  Future<void> initializeCamera(CameraDescription cameraDescription) async {
    cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);

    try {
      await cameraController.initialize().then((value) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("Camera error $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // initialize the rear camera
    initializeCamera(widget.cameras![0]);
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    cameraController.dispose();
    super.dispose();
  }

  Future takePicture() async {
    if (!cameraController.value.isInitialized) {
      return null;
    }
    if (cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await cameraController.setFlashMode(FlashMode.off);
      XFile picture = await cameraController.takePicture();
      File capturedImg = File(picture.path);

      // decode image and return new image
      img.Image? originalImage = img.decodeImage(capturedImg.readAsBytesSync());

      var now = DateTime.now();
      var formatterDate = DateFormat('dd/MM/yy');
      var formatterTime = DateFormat('kk:mm');
      String actualDate = formatterDate.format(now);
      String actualTime = formatterTime.format(now);

      // watermark text
      String watermarkText = "$actualDate $actualTime";

      // add watermark to image and specify the position
      // Draw some text using 24pt arial font
      if (mounted) {
        img.drawString(originalImage!, watermarkText,
            font: img.arial24,
            x: 24,
            y: (MediaQuery.of(context).size.height * 1.5).round());
      }

      // create temporary directory on storage
      var tempDir = await getTemporaryDirectory();
      String imgPath = "${tempDir.path}/${picture.name}";

      // store new image on filename
      File(imgPath).writeAsBytesSync(img.encodePng(originalImage!));

      // set watermarked image from image path
      watermarkedImage = File(imgPath);

      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewPage(
                      picture: watermarkedImage,
                      pictureName: picture.name,
                    )));
      }
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              (cameraController.value.isInitialized)
                  ? CameraPreview(cameraController)
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                      color: Colors.black),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 30,
                        icon: Icon(
                          isRearCameraSelected
                              ? CupertinoIcons.switch_camera
                              : CupertinoIcons.switch_camera_solid,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            isRearCameraSelected = !isRearCameraSelected;
                            initializeCamera(
                                widget.cameras![isRearCameraSelected ? 0 : 1]);
                          });
                        },
                      )),
                      Expanded(
                          child: IconButton(
                        onPressed: takePicture,
                        iconSize: 50,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.circle,
                          color: Colors.white,
                        ),
                      )),
                      const Spacer()
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
