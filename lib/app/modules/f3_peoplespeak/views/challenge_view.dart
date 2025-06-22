import 'package:bicaraku/app/modules/f3_peoplespeak/controllers/peoplespeak_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChallengeView extends StatefulWidget {
  final String phrase;
  final String interactiveImage;

  const ChallengeView({
    super.key,
    required this.phrase,
    required this.interactiveImage,
  });

  @override
  State<ChallengeView> createState() => _ChallengeViewState();
}

class _ChallengeViewState extends State<ChallengeView> {
  late BerbicaraController controller;
  bool _showPopup = true;

  @override
  void initState() {
    super.initState();
    controller = Get.put(BerbicaraController());
    controller.currentSentence.value = widget.phrase;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latihan Pengucapan'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Gambar interaktif (diperbesar)
            Positioned.fill(
              child: Image.asset(
                widget.interactiveImage,
                fit: BoxFit.cover,
              ),
            ),
            
            // Overlay semi transparan
            if (_showPopup) ...[
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                ),
              ),
              
              // Popup instruksi
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/iconuser.png',
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Kamu akan mengucapkan:",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '"${widget.phrase}"',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Arahkan ke mikrofon dan ucapkan dengan jelas",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showPopup = false;
                          });
                          controller.startPractice(widget.phrase);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Mulai",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            // Tombol Mikrofon (hanya muncul setelah popup ditutup)
            if (!_showPopup) ...[
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Obx(
                    () => FloatingActionButton.large(
                      onPressed: () => controller.toggleRecording(),
                      backgroundColor: controller.isListening.value 
                          ? Colors.red 
                          : Theme.of(context).primaryColor,
                      child: Icon(
                        controller.isListening.value ? Icons.stop : Icons.mic,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Petunjuk teks (hanya muncul setelah popup ditutup)
              Positioned(
                bottom: 130,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Ucapkan: \"${widget.phrase}\"",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}