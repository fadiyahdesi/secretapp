import 'package:bicaraku/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CariobjekView extends StatelessWidget {
  const CariobjekView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text(
                    'Tantangan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Grid of activity cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    buildActivityCard(
                      'assets/images/f2.cariobjek/1.png',
                      '"AYO TEMUKAN BOLA"',
                    ),
                    buildActivityCard(
                      'assets/images/f2.cariobjek/2.png',
                      '"AYO TEMUKAN BOTOL"',
                    ),
                    buildActivityCard(
                      'assets/images/f2.cariobjek/3.png',
                      '"AYO TEMUKAN KURSI"',
                    ),
                    buildActivityCard(
                      'assets/images/f2.cariobjek/5.png',
                      '"AYO TEMUKAN TEMPAT TIDUR"',
                    ),
                    buildActivityCard(
                      'assets/images/f2.cariobjek/6.png',
                      '"AYO TEMUKAN TAS"',
                    ),
                    buildActivityCard(
                      'assets/images/f2.cariobjek/4.png',
                      '"AYO TEMUKAN TELEVISI"',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFBF8C),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility),
            label: 'Melihat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore),
            label: 'Temukan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over),
            label: 'Berbicara',
          ),
        ],
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.toNamed(Routes.HOME);
              break;
            case 1:
              Get.toNamed(Routes.LOOKNHEAR);
              break;
            case 2:
              Get.toNamed(Routes.CARIOBJEK);
              break;
            case 3:
              Get.toNamed(Routes.PEOPLESPEAK);
              break;
          }
        },
      ),
    );
  }

  /// Builder function for square activity cards with instruction
  Widget buildActivityCard(String imageAsset, String instruksi) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke kamera sambil kirim instruksi
        Get.toNamed(Routes.CARIOBJEKCAM, arguments: instruksi);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(imageAsset, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
