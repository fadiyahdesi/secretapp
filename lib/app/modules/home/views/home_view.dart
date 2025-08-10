import 'package:bicaraku/app/data/controllers/activity_controller.dart';
import 'package:bicaraku/app/data/controllers/total_points_controller.dart';
import 'package:bicaraku/app/data/controllers/user_controller.dart';
import 'package:bicaraku/app/data/models/activity_history.dart';
import 'package:bicaraku/app/routes/app_routes.dart';
import 'package:bicaraku/core/widgets/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

// Mengubah menjadi StatelessWidget karena GetX sudah mengelola state. Lebih ringkas & efisien.
class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    final ActivityController activityController = Get.put(ActivityController());
    final TotalPointsController pointsController = Get.put(
      TotalPointsController(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomBottomNav(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Halo, ${userController.userRx.value?.name ?? ''}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        // Text poin juga reaktif
                        Text(
                          '${pointsController.totalPoints.value} Poin',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.person,
                            size: 30.0,
                            color: Colors.purpleAccent,
                          ),
                          onPressed: () {
                            Get.toNamed(Routes.PROFIL);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- AKHIR DARI KODE HEADER YANG DIPERBAIKI ---
              const SizedBox(height: 16),

              // Banner edukasi
              Container(
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Image.asset('assets/images/iconuser.png', width: 175),
                    const SizedBox(width: 30),
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

              // Scraping section
              const Text(
                'Infografis',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.SCRAPING);
                },
                child: _buildActivityCard('assets/images/scraping.jpg'),
              ),

              const SizedBox(height: 16),

              // Section Aktivitas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aktivitas Terbaru',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Obx(() {
                    if (activityController.histories.isNotEmpty) {
                      return TextButton(
                        onPressed: () => Get.toNamed(Routes.HISTORY),
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (activityController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (activityController.histories.isEmpty) {
                  return _buildEmptyActivity();
                }

                final histories = [...activityController.histories];
                histories.sort((a, b) => b.date.compareTo(a.date));

                return Column(
                  children: [
                    for (var history in histories.take(3))
                      _buildHistoryCard(history),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods, bisa tetap di sini atau dipindah ke file terpisah
  Widget _buildActivityCard(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(imagePath, fit: BoxFit.cover),
    );
  }

  Widget _buildEmptyActivity() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Image.asset('assets/images/emptyhistory.png', width: 120),
          const SizedBox(height: 16),
          const Text(
            'Belum ada aktivitas',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Get.toNamed(Routes.CARIOBJEK);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Mulai Aktivitas'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ActivityHistory history) {
    final formatter = intl.DateFormat('EEEE, d MMMM y', 'id_ID');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.asset(
              history.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        history.isCompleted
                            ? Icons.check_circle
                            : Icons.access_time,
                        color:
                            history.isCompleted ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          history.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (history.points > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${history.points} Poin',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${formatter.format(history.date)} • ${intl.DateFormat.Hm().format(history.date)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
