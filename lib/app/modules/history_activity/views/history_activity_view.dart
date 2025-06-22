import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/history_activity_controller.dart';

class HistoryActivityView extends GetView<HistoryActivityController> {
  const HistoryActivityView({super.key});

  String formatTime(String timestamp) {
    final utcTime = DateTime.parse(timestamp);
    final wibTime = utcTime.add(const Duration(hours: 7));
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(wibTime) + ' WIB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Aktivitas")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.activityList.isEmpty) {
          return const Center(child: Text("Tidak ada aktivitas ditemukan."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.activityList.length,
          itemBuilder: (context, index) {
            final item = controller.activityList[index];

            return Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: Text(item['type'].toUpperCase()),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item['detail'] != null) Text(item['detail']),
                    Text(formatTime(item['timestamp'])),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
