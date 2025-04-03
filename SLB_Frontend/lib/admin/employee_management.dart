import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_employee.dart';
import '../globals.dart' as globals;
import 'edit_employee.dart';

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

  if (globals.token == "") {
    setState(() {
      errorMessage = "No token found";
    });
    return;
  }

  setState(() {
    isLoading = true;
    errorMessage = '';
  });

  try {
    const apiUrl = 'http://172.191.111.81:8081/api/employee/';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': globals.token, // Add Bearer prefix
        'Content-Type': 'application/json',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: "${response.body}"');

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final decoded = json.decode(response.body);

      if (decoded["code"] == 200 && decoded["data"] is List) {
        setState(() {
          employees = decoded["data"].map((employee) {
            return {
              'id': employee['employee_id'].toString(),
              'name': employee['employee_name'] ?? 'No Name',
              'department': employee['department'] ?? 'No Department',
              'type': employee['user_type'] ?? 'Regular User',
            };
          }).toList();
        });
      } else {
        setState(() {
          errorMessage = 'Invalid data format';
        });
      }
    } else {
      setState(() {
        errorMessage = 'Failed to fetch employees: ${response.statusCode}';
      });
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
    if (globals.token == "") {
    setState(() {
      errorMessage = "No token found";
    });
    return;
  }

  setState(() {
    isLoading = true;
    errorMessage = '';
  });
    try {
      // Replace with your actual API endpoint
      final apiUrl = 'http://172.191.111.81:8081/api/employee/$employeeId';
      final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': globals.token,
      },
    );

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
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => EditEmployeePage(
                                                  id: emp['id']!,
                                                  name: emp['name']!,
                                                  department: emp['department'] ?? '',
                                                  type: emp['type'] ?? '',
                                                ),
                                              ),
                                            ).then((_) {
                                              _fetchEmployees(); // Refresh after editing
                                            });
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