import 'package:bicaraku/app/modules/f3.peoplespeak/views/challenge_view.dart';
import 'package:bicaraku/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PeopleSpeakView extends StatelessWidget {
  const PeopleSpeakView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Berlatih Membaca',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // List Challenge Card
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  buildActivityCard(
                    'assets/images/f3.peoplespeak/2.png',
                    'assets/images/f3.peoplespeak/2kata.png',
                    'assets/images/f3.peoplespeak/c_2kata.png',
                  ),
                  buildActivityCard(
                    'assets/images/f3.peoplespeak/3.png',
                    'assets/images/f3.peoplespeak/3kata.png',
                    'assets/images/f3.peoplespeak/c_3kata.png',
                  ),
                  buildActivityCard(
                    'assets/images/f3.peoplespeak/4.png',
                    'assets/images/f3.peoplespeak/4kata.png',
                    'assets/images/f3.peoplespeak/c_4kata.png',
                  ),
                  buildActivityCard(
                    'assets/images/f3.peoplespeak/5.png',
                    'assets/images/f3.peoplespeak/5kata.png',
                    'assets/images/f3.peoplespeak/c_5kata.png',
                  ),
                  buildActivityCard(
                    'assets/images/f3.peoplespeak/6.png',
                    'assets/images/f3.peoplespeak/6kata.png',
                    'assets/images/f3.peoplespeak/c_6kata.png',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

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

  /// Widget Builder for Activity Card
  Widget buildActivityCard(
    String imageAsset,
    String instructionImage,
    String objectImage,
  ) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ChallengeView(
            title: 'Berlatih Membaca',
            instructionImage: instructionImage,
            objectImage: objectImage,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(imageAsset),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
