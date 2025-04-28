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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.purpleAccent,
                    ),
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
                    Image.asset('assets/images/iconuser.png', width: 170),
                    const SizedBox(width: 60),
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
