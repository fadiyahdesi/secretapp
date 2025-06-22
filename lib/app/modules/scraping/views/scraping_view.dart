import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:bicaraku/core/widgets/custom_bottom_nav.dart';

const List<String> stopWords = [
  'yang',
  'dan',
  'di',
  'ke',
  'dari',
  'untuk',
  'dengan',
  'atau',
  'pada',
  'oleh',
  'sebagai',
  'adalah',
  'itu',
  'ini',
  'saat',
  'karena',
  'dalam',
  'juga',
  'agar',
  'bagi',
  'maka',
  'sebuah',
  'lebih',
  'kurang',
  'tersebut',
  'akan',
  'telah',
  'bila',
  'bisa',
  'mungkin',
  'mulai',
  'kecil',
];

class ScrapingView extends StatefulWidget {
  const ScrapingView({super.key});

  @override
  State<ScrapingView> createState() => _ScrapingViewState();
}

class _ScrapingViewState extends State<ScrapingView> {
  bool showVisualization = true;
  List<dynamic> articles = [];
  Map<String, dynamic> keywords = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchScrapingData();
  }

  Future<void> fetchScrapingData() async {
    final response = await http.get(
      Uri.parse("https://fadiyahdesi-scraping.hf.space/api/dashboard"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        articles = data['articles'];
        keywords = Map<String, dynamic>.from(data['keywords']);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, int> get articleCountBySource {
    final map = <String, int>{};
    for (var article in articles) {
      final source = article['source'];
      map[source] = (map[source] ?? 0) + 1;
    }
    return map;
  }

  Widget buildBarChart() {
    final items =
        keywords.entries
            .where((entry) => !stopWords.contains(entry.key.toLowerCase()))
            .toList();

    if (items.isEmpty) return const Text("Tidak ada data keyword");

    items.sort((a, b) => (b.value as int).compareTo(a.value as int));
    final topItems = items.take(7).toList();
    final max = topItems.first.value as int;

    // Hitung kelipatan 100 terdekat ke atas
    final yStep = 100;
    final yMax = ((max / yStep).ceil()) * yStep;

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Sumbu Y
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              (yMax ~/ yStep) + 1,
              (index) => SizedBox(
                height: 150 / (yMax ~/ yStep),
                child: Text(
                  '${yMax - (index * yStep)}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Bar Chart
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children:
                  topItems.map((entry) {
                    final label = entry.key;
                    final value = entry.value as int;
                    final barHeight = (value / yMax) * 150;

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: barHeight,
                            width: 12,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                255,
                                255,
                                241,
                                51,
                              ).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildKeywordGrid() {
    final filteredItems =
        keywords.entries
            .where((entry) => !stopWords.contains(entry.key.toLowerCase()))
            .toList();

    if (filteredItems.isEmpty) return const Text("Tidak ada keyword.");

    filteredItems.sort((a, b) => (b.value as int).compareTo(a.value as int));
    final max = filteredItems.first.value as int;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          filteredItems.map((entry) {
            final scale = (entry.value as int) / max;
            final fontSize = 14.0 + (scale * 16); // 14 - 30
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1 + (scale * 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                entry.key,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget buildPieChart() {
    final data = articleCountBySource;
    final total = data.values.fold(0, (a, b) => a + b);
    if (data.isEmpty) return const Text("Tidak ada data artikel.");

    final Map<String, Color> sourceColors = {
      "Haibunda": Color.fromARGB(255, 255, 155, 74),
      "Wikipedia": Colors.purpleAccent,
      "Hellosehat": Color.fromARGB(255, 255, 241, 51),
    };

    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            data.entries.map((e) {
              final percent = ((e.value / total) * 100).toStringAsFixed(1);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: sourceColors[e.key] ?? Colors.grey,
                    child: Text(
                      "${e.value}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${e.key} ($percent%)",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget buildVisualizationView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      children: [
        const Text(
          "Top Keywords",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        buildBarChart(),
        const SizedBox(height: 20),

        const Text(
          "Total Artikel",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        buildPieChart(),

        const Text(
          "Tag Cloud",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        buildKeywordGrid(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildArticleView() {
    final filteredArticles =
        articles.where((article) {
          final url = article['url'] as String?;
          return url != null && url.isNotEmpty;
        }).toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      itemCount: filteredArticles.length,
      itemBuilder: (context, index) {
        final article = filteredArticles[index];
        final title = article['title'] ?? '';
        final source = article['source'] ?? '';
        final url = article['url'] ?? '';

        return GestureDetector(
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.platformDefault);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak bisa membuka link')),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.open_in_new, color: Colors.purple),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Sumber: $source",
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNav(),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              top: 70,
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : showVisualization
                      ? buildVisualizationView()
                      : buildArticleView(),
            ),

            Positioned(
              top: 16,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
              ),
            ),

            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showVisualization = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            showVisualization
                                ? Colors.purple[300]
                                : Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Visualisasi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showVisualization = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !showVisualization
                                ? Colors.yellow[300]
                                : Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Artikel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
