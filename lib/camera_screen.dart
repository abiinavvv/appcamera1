import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'gallery_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isUsingFrontCamera = false;
  List<String> _capturedImages = []; // Store captured image paths

  @override
  void initState() {
    super.initState();
    _initializeCamera(0);
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![cameraIndex],
        ResolutionPreset.high,
      );

      try {
        await _controller!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      } catch (e) {
        _showToast("Error initializing camera: $e");
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) {
      print("Error: Camera is not initialized.");
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final imagePath = p.join(directory.path, '${DateTime.now()}.png');

    try {
      final XFile picture = await _controller!.takePicture();
      await picture.saveTo(imagePath);
      _capturedImages.add(imagePath); // Store the captured image path

      // Show toast to confirm picture taken
      _showToast("Picture taken");
    } catch (e) {
      _showToast("Error taking picture");
    }
  }

  void _switchCamera() {
    if (_cameras != null && _cameras!.length > 1) {
      setState(() {
        _isCameraInitialized = false;
        _isUsingFrontCamera = !_isUsingFrontCamera;
      });
      _initializeCamera(_isUsingFrontCamera ? 1 : 0);
    } else {
      _showToast("no Front camera Found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text('Camera',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          if (_isCameraInitialized)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: "Switch camera",
                    backgroundColor: Colors.black,
                    onPressed: _switchCamera,
                    child: const Icon(Icons.switch_camera_rounded,
                        color: Colors.white),
                  ),
                  FloatingActionButton(
                    heroTag: 'take_picture',
                    backgroundColor: Colors.black,
                    onPressed: _takePicture,
                    child: const Icon(Icons.camera, color: Colors.white),
                  ),
                  FloatingActionButton(
                    heroTag: 'gallery',
                    backgroundColor: Colors.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GalleryScreen()),
                      );
                    },
                    child: const Icon(Icons.photo_library, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
