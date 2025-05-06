import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'edit_employee.dart';
import '../globals.dart' as globals;

class EmployeeDetailPage extends StatefulWidget {
  final String id;
  final String name;
  final String department;
  final String type;

  const EmployeeDetailPage({
    super.key,
    required this.id,
    required this.name,
    required this.department,
    required this.type,
  });

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  bool isDeleting = false;
  String errorMessage = '';

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Confirm Delete',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to delete this employee?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      _deleteEmployee();
    }
  }

  Future<void> _deleteEmployee() async {
    if (globals.token == "") {
      setState(() {
        errorMessage = "No token found";
      });
      return;
    }

    setState(() {
      isDeleting = true;
    });

    try {
      final apiUrl = 'http://4.227.176.4:8081/api/employee/${widget.id}';
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {'Authorization': globals.token},
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // Go back after delete
      } else {
        setState(() {
          errorMessage = 'Failed to delete: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Employee Detail',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),
            _infoRow('ID', widget.id),
            _infoRow('Name', widget.name),
            _infoRow('Department', widget.department),
            _infoRow('Type', widget.type),

            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: isDeleting ? null : _confirmDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => EditEmployeePage(
                              id: widget.id,
                              name: widget.name,
                              department: widget.department,
                              type: widget.type,
                            ),
                      ),
                    ).then((_) => Navigator.pop(context));
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
