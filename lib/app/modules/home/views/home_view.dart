import 'package:bicaraku/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFBF8C),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.black, // <-- Warna ikon aktif (terpilih)
        unselectedItemColor: Colors.black, // <-- Warna ikon tidak aktif
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.remove_red_eye), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over),
            label: '',
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
              Get.toNamed('/search');
              break;
            case 3:
              Get.toNamed('/people-speak');
              break;
          }
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Halo, Desi!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      // Navigasi ke halaman setting profil
                      Get.toNamed('/profil');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Image.asset('assets/images/iconuser.png', width: 200),
                    const SizedBox(width: 80),
                    const Expanded(
                      child: Text(
                        'Lihat, Dengar, Ucapkan – Belajar Bicara Jadi Lebih Mudah!',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Skor Anda', style: TextStyle(fontSize: 16)),
                  Text(
                    '10 Poin',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Aktivitas Anda', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildActivityCard('assets/images/home1.png'),
                  _buildActivityCard('assets/images/home2.png'),
                  _buildActivityCard('assets/images/home3.png'),
                  _buildActivityCard('assets/images/home4.png'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildActivityCard(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(imagePath, fit: BoxFit.cover),
    );
  }
}
