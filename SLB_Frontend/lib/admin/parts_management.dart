import 'package:flutter/material.dart';
import 'add_parts.dart';
import 'edit_part.dart';
import 'part_detail.dart';

class PartManagementPage extends StatefulWidget {
  const PartManagementPage({super.key});

  @override
  State<PartManagementPage> createState() => _PartManagementPageState();
}

class _PartManagementPageState extends State<PartManagementPage> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, String>> parts = [
    {
      'id': 'P001',
      'name': 'Gearbox',
      'category': 'Mechanical',
      'type': 'Product',
    },
    {'id': 'P002', 'name': 'Sensor', 'category': 'Electronics', 'type': 'Part'},
    {'id': 'P003', 'name': 'Valve', 'category': 'Hydraulics', 'type': 'Part'},
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredParts =
        parts.where((item) {
          final query = searchQuery.toLowerCase();
          return item['name']!.toLowerCase().contains(query) ||
              item['category']!.toLowerCase().contains(query) ||
              item['id']!.contains(query);
        }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Product / Part Management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'ID',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Type',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 40),
              ],
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView.builder(
                itemCount: filteredParts.length,
                itemBuilder: (context, index) {
                  final part = filteredParts[index];

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              part['id']!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              part['name']!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              part['type']!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PartDetailPage(
                                        id: part['id']!,
                                        name: part['name']!,
                                        category: part['category']!,
                                        type: part['type']!,
                                      ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(color: Colors.grey),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPartPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B544C),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add New Part',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
