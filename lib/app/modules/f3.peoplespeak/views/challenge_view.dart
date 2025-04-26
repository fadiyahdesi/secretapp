import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChallengeView extends StatelessWidget {
  final String title;
  final String instructionImage;
  final String objectImage;

  const ChallengeView({
    super.key,
    required this.title,
    required this.instructionImage,
    required this.objectImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Tombol Back & Volume
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () {
                      // TODO: tambahkan suara nanti
                    },
                  ),
                ],
              ),
            ),

            // Gambar Instruksi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Image.asset(instructionImage),
            ),

            const SizedBox(height: 16),

            // Gambar Anak Ayam (Object Belajar)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Image.asset(objectImage),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.mic,
                        size: 32,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        // TODO: Tambahkan fitur rekam suara
                      },
                    ),
                  ),
                  const SizedBox(width: 30),
                  // Tombol Refresh (bulat)
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        size: 28,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        // TODO: Reset suara
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
