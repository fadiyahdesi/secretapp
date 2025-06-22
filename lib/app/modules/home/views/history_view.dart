import 'package:bicaraku/app/data/controllers/activity_controller.dart';
import 'package:bicaraku/app/data/models/activity_history.dart';
import 'package:bicaraku/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id_ID', null);
    final ActivityController controller = Get.find<ActivityController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.histories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/emptyhistory.png', width: 120),
                const SizedBox(height: 20),
                const Text(
                  'Belum ada riwayat aktivitas',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.histories.length,
          itemBuilder: (context, index) {
            final history = controller.histories[index];
            return _buildHistoryCard(history);
          },
        );
      }),
    );
  }

  Widget _buildHistoryCard(ActivityHistory history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (history.isCompleted)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      if (!history.isCompleted)
                        const Icon(
                          Icons.access_time,
                          color: Colors.orange,
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          history.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(history.date),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  if (!history.isCompleted)
                    ElevatedButton(
                      onPressed: () {
                        // Lanjutkan aktivitas dengan instruksi yang sama
                        Get.toNamed(
                          Routes.CARIOBJEKCAM,
                          arguments: history.instruksi,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent[100],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Lanjutkan'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final formatter = intl.DateFormat('EEEE, d MMMM y', 'id_ID');
    return '${formatter.format(date)} • ${intl.DateFormat.Hm().format(date)}';
  }
}
