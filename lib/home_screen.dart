import 'package:flutter/material.dart';
import 'motivation_screen.dart';
import 'main.dart'; // <-- import FaceDetectionScreen


// ================= Home Screen =================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("رفيق المشاعر")),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_1.jpg"), // background
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              
              const SizedBox(height: 18),

              Image.asset("assets/images/app_title.png", width: double.infinity, height: 75, fit: BoxFit.contain),

              
              const SizedBox(height: 16),

              const Text(
                "فحص الحالة بالكاميرا",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // First big image box → goes to FaceDetectionScreen
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FaceDetectionScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 150,
                  width: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color.fromARGB(255, 247, 247, 248), width: 3),
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/imgScan.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "أو اختار حالتك بنفسك",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Three image boxes → send values
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _ImageBox(imgPath: "assets/images/imgHappy.png", value: "Happy"),
                  _ImageBox(imgPath: "assets/images/imgNeutral.png", value: "Neutral"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                 Text("سعيد",textAlign: TextAlign.center,style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),),
                  Text("طبيعي",textAlign: TextAlign.center,style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 252, 251, 251),
                  ),),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _ImageBox(imgPath: "assets/images/imgSad.png", value: "Sad"),
                  _ImageBox(imgPath: "assets/images/imgDepressed.png", value: "Depressed"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                Text("حزين",textAlign: TextAlign.center,style:  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),),
                 Text("مكتئب",textAlign: TextAlign.center,style:  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 252, 252, 252),
                  ),),
                ],
              ),

              
            ],
          ),
        ),
      ),
    );
  }
}

// ================= Image Box =================
class _ImageBox extends StatelessWidget {
  final String imgPath;
  final String value;

  const _ImageBox({required this.imgPath, required this.value});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MotivationScreen(result: value),
          ),
        );
      },
      child: Container(
        height: 75,
        width: 75,
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 255, 255, 255), width: 3),
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imgPath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
