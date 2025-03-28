import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_employee.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Retrieve token later
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> employees = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';
  Set<int> expandedRows = {};

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    final access_token = await getToken(); // Retrieve saved token
    if (access_token == null) {
      print("No token found");
      return;
    }
    print(access_token);
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Replace with your actual API endpoint
      const apiUrl = 'http://172.191.111.81:8081/api/employee/';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': access_token, // Include JWT in header
          'Content-Type': 'application/json',
        },
      );
      final responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody["code"] == 200) {
        setState(() {
          employees =
              responseBody["data"].map((employee) {
                return {
                  'id': employee['employee_id'].toString(),
                  'name': employee['username'] ?? 'No Name',
                  'department': employee['department'] ?? 'No Department',
                  'type': employee['manager'] ?? 'Regular User',
                };
              }).toList();
        });
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching employees: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteEmployee(String employeeId) async {
    try {
      // Replace with your actual API endpoint
      final apiUrl = 'http://your-api-endpoint.com/api/employees/$employeeId';
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Refresh the employee list after successful deletion
        await _fetchEmployees();
      } else {
        throw Exception('Failed to delete employee: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error deleting employee: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEmployees =
        employees.where((emp) {
          final query = searchQuery.toLowerCase();
          return emp['name']!.toLowerCase().contains(query) ||
              emp['department']!.toLowerCase().contains(query) ||
              emp['id']!.contains(query);
        }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Employees', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEmployees,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search Bar
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

            // Error message
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Loading indicator
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              // 📋 Table Header
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

              // 📄 Table Body
              Expanded(
                child:
                    filteredEmployees.isEmpty
                        ? const Center(
                          child: Text(
                            'No employees found',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                        : ListView.builder(
                          itemCount: filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final emp = filteredEmployees[index];
                            final isExpanded = expandedRows.contains(index);

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        emp['id']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        emp['name']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        emp['type']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.more_vert,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (isExpanded) {
                                            expandedRows.remove(index);
                                          } else {
                                            expandedRows.add(index);
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                if (isExpanded)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      bottom: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            // TODO: Implement edit functionality
                                            // Navigator.push(...)
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 16,
                                          ),
                                          label: const Text('Edit'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.orangeAccent,
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            await _deleteEmployee(emp['id']!);
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 16,
                                          ),
                                          label: const Text('Delete'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                          ),
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

              const SizedBox(height: 20),

              // ➕ Add New Employee Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddEmployeePage()),
                  ).then((_) {
                    // Refresh the list when returning from AddEmployeePage
                    _fetchEmployees();
                  });
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
                  'Add New Employee',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
