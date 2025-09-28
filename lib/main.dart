import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'motivation_screen.dart';
import 'splash_screen.dart';
import 'home_screen.dart';   // <-- import the other file
import 'package:flutter/services.dart';

import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:path_provider/path_provider.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // optional (portrait upside down)
  ]);

  cameras = await availableCameras();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

// ---- Image normalization helpers (platform-aware) ----
Future<String> _ensureJpeg(String path) async {
  final lower = path.toLowerCase();
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return path;

  final target = p.setExtension(path, '.jpg');
  final out = await FlutterImageCompress.compressAndGetFile(
    path,
    target,
    quality: 85,          // smaller → faster normalize/detect (esp. first run)
    minWidth: 1280,       // cap size; keeps enough detail for face/smile
    minHeight: 1280,
    format: CompressFormat.jpeg,
  );
  return out?.path ?? path;
}

Future<String> _normalizeStill(String path) async {
  final jpg = await _ensureJpeg(path);
  try {
    final rotated = await FlutterExifRotation.rotateImage(path: jpg);
    return rotated.path;
  } catch (_) {
    return jpg; // if EXIF rotation fails, carry on
  }
}

Future<String> normalizeForDetection(String path) async {
  // iOS: normalize (HEIC + EXIF common)
  if (Platform.isIOS) {
    return await _normalizeStill(path);
  }
  // Android: only convert if it’s actually HEIC/HEIF; otherwise leave as-is
  final ext = p.extension(path).toLowerCase();
  if (ext == '.heic' || ext == '.heif') {
    return await _ensureJpeg(path);
  }
  return path;
}

class MoodMateApp extends StatelessWidget {
  const MoodMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'رفيق المشاعر',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  CameraController? _cameraController;
  int _selectedCameraIndex = 1; // Start with front camera
  late final FaceDetector _detector;
  bool _busy = false;

  @override
  void initState() {
    super.initState();

    // Use a single, long-lived detector. Faster and avoids duplicate init.
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableClassification: true,  // smilingProbability
        enableLandmarks: false,      // not needed for mood; faster
        enableContours: false,
        minFaceSize: 0.1,            // default; faster than very small faces
      ),
    );

    _initCamera();
    _warmUpPipelines(); // Pre-load ML Kit/TFLite & native codecs once
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    try { _detector.close(); } catch (_) {}
    super.dispose();
  }

  Future<void> _initCamera() async {
    if (cameras == null || cameras!.isEmpty) return;

    // if device doesn’t have a front camera → fallback to back
    if (_selectedCameraIndex >= cameras!.length) {
      _selectedCameraIndex = 0;
    }

    final camera = cameras![_selectedCameraIndex];

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  void _switchCamera() async {
    if (cameras == null || cameras!.length < 2) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras!.length;

    await _cameraController?.dispose();
    await _initCamera();
  }

  void _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (_busy) return;
    _busy = true;
    try {
      final image = await _cameraController!.takePicture();
      final normalizedPath = await normalizeForDetection(image.path);
      await _analyzeImage(File(normalizedPath));
    } finally {
      _busy = false;
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    // Use the shared detector + fromFilePath for reliability
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final faces = await _detector.processImage(inputImage);

    String mood = "صورة الوجه غير متاحة";
    String advice = "حاول التصوير فى إضاءة جيدة";

    if (faces.isNotEmpty) {
      final face = faces.first;
      final smileProb = face.smilingProbability;
      if (smileProb != null) {
        if (smileProb > 0.6) {
          mood = "Happy";
        } else if (smileProb < 0.1) {
          mood = "Depressed";
        } else if (smileProb < 0.3) {
          mood = "Sad";
        } else {
          mood = "Neutral";
        }
      }
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResultScreen(imageFile: imageFile, mood: mood, advice: advice),
      ),
    );
  }

  // Warm up ML Kit and native codecs by processing a small bundled image once
  Future<void> _warmUpPipelines() async {
    try {
      // Use your existing bg asset so you don’t need to add a new file.
      final data = await rootBundle.load('assets/images/bg_1.jpg');
      final dir = await getTemporaryDirectory();
      final tmp = File(p.join(dir.path, 'mm_warmup.jpeg'));
      await tmp.writeAsBytes(data.buffer.asUint8List());

      final normalizedPath = await normalizeForDetection(tmp.path);
      final input = InputImage.fromFilePath(normalizedPath);
      await _detector.processImage(input); // discard result
    } catch (e) {
      debugPrint('Warm-up skipped: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تحليل الحالة بالكاميرا")),
      body: Stack(
        children: [
          /// 🔹 Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg_1.jpg",
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Camera preview aligned at top
          Align(
            alignment: Alignment.topCenter,
            child: _cameraController == null ||
                !_cameraController!.value.isInitialized
                ? const Padding(
              padding: EdgeInsets.only(top: 50),
              child: CircularProgressIndicator(),
            )
                : Container(
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border:
                Border.all(color: Colors.white, width: 4), // border
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text("تصوير",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: null,
            onPressed: _captureImage,
            tooltip: 'Capture',
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(width: 18),
          const Text("تغيير الكاميرا",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: null,
            onPressed: _switchCamera,
            tooltip: 'Switch Camera',
            child: const Icon(Icons.switch_camera),
          ),
        ],
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final File imageFile;
  final String mood;
  final String advice;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.mood,
    required this.advice,
  });

  @override
  Widget build(BuildContext context) {
    String moodLabel = "";
    if (mood == "Happy") {
      moodLabel = "سعيد 😀";
    } else if (mood == "Sad") {
      moodLabel = "حزين 😔";
    } else if (mood == "Depressed"){
      moodLabel = "مكتئب 😩";
    } else{
      moodLabel = "طبيعي 😐";
    }

    return Scaffold(
      appBar: AppBar(title: const Text("التحليل")),
      body: Stack(
        children: [
          /// 🔹 Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg_1.jpg",
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Foreground Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.file(imageFile, height: 300),
                const SizedBox(height: 20),
                Text(
                  moodLabel,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // visible on bg
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                if (mood.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MotivationScreen(result: mood),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(206, 2, 183, 29),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "نصائح",
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
