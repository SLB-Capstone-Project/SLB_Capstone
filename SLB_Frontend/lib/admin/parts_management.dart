import 'package:flutter/material.dart';
import 'add_parts.dart';
import 'edit_part.dart';
import 'part_detail.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';

class PartManagementPage extends StatefulWidget {
  const PartManagementPage({super.key});

  @override
  State<PartManagementPage> createState() => _PartManagementPageState();
}

class _PartManagementPageState extends State<PartManagementPage> {
  final TextEditingController searchController = TextEditingController();
  String errorMessage = '';
  List<dynamic> parts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchParts();
  }

  Future<void> _fetchParts() async {
    if (globals.token.isEmpty) {
      setState(() {
        errorMessage = "No token found";
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      const apiUrl = 'http://172.191.111.81:8081/api/components';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': globals.token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final decoded = json.decode(response.body);
          setState(() {
            parts =
                decoded.map((part) {
                  return {
                    'partId': part['partId']?.toString() ?? 'N/A',
                    'partName': part['partName'] ?? 'Unknown',
                    'status': part['status'] ?? 'Unknown',
                    'productId': part['productId']?.toString() ?? 'N/A',
                    'productName': part['productName'] ?? 'Unknown',
                    'cost': part['cost']?.toString() ?? '0.00',
                    'borrowedEmployeeId':
                        part['borrowedEmployeeId']?.toString() ?? 'None',
                  };
                }).toList();
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch parts: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching parts: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = searchController.text.toLowerCase();
    final filteredParts =
        parts.where((part) {
          return part['partId'].toLowerCase().contains(searchQuery) ||
              part['partName'].toLowerCase().contains(searchQuery) ||
              part['status'].toLowerCase().contains(searchQuery);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchParts,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by ID, name or status...',
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

            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else ...[
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Part ID',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Part Name',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Status',
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

              if (filteredParts.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No parts found',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredParts.length,
                    itemBuilder: (context, index) {
                      final part = filteredParts[index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PartDetailPage(
                                        partId: part['partId'],
                                        partName: part['partName'],
                                        status: part['status'],
                                        productId: part['productId'],
                                        productName: part['productName'],
                                        cost: part['cost'],
                                        borrowedEmployeeId:
                                            part['borrowedEmployeeId'],
                                      ),
                                ),
                              ).then((_) => _fetchParts());
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    part['partId'],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    part['partName'],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    part['status'],
                                    style: TextStyle(
                                      color:
                                          part['status'] == 'Available'
                                              ? Colors.green
                                              : Colors.orange,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.grey),
                        ],
                      );
                    },
                  ),
                ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPartPage()),
                );
                _fetchParts();
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
