import 'package:flutter/material.dart';
import 'add_employee.dart'; // Make sure this exists

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, String>> employees = [
    {'id': '001', 'name': 'Alice Johnson', 'department': 'HR', 'type': 'Admin'},
    {'id': '002', 'name': 'Bob Smith', 'department': 'Engineering', 'type': 'Normal'},
    {'id': '003', 'name': 'Carol Lee', 'department': 'Marketing', 'type': 'Normal'},
  ];

  String searchQuery = '';
  Set<int> expandedRows = {};

  @override
  Widget build(BuildContext context) {
    final filteredEmployees = employees.where((emp) {
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

            // 📋 Table Header
            Row(
              children: const [
                Expanded(child: Text('ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                // Expanded(child: Text('Department', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(child: Text('Type', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                SizedBox(width: 40),
              ],
            ),
            const Divider(color: Colors.grey),

            // 📄 Table Body
            Expanded(
              child: ListView.builder(
                itemCount: filteredEmployees.length,
                itemBuilder: (context, index) {
                  final emp = filteredEmployees[index];
                  final isExpanded = expandedRows.contains(index);

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(emp['id']!, style: const TextStyle(color: Colors.white))),
                          Expanded(child: Text(emp['name']!, style: const TextStyle(color: Colors.white))),
                          // Expanded(child: Text(emp['department']!, style: const TextStyle(color: Colors.white))),
                          Expanded(child: Text(emp['type']!, style: const TextStyle(color: Colors.white))),
                          IconButton(
                            icon: Icon(
                              isExpanded ? Icons.expand_less : Icons.more_vert,
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
                          )
                        ],
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, bottom: 10),
                          child: Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: implement update functionality
                                },
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Edit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    employees.removeAt(index);
                                  });
                                },
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text('Delete'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B544C),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add New Employee',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
