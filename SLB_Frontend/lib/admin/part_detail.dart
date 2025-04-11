import 'package:flutter/material.dart';
import 'edit_part.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;

class PartDetailPage extends StatelessWidget {
  final String partId;
  final String partName;
  final String status;
  final String productId;
  final String productName;
  final String cost;
  final String borrowedEmployeeId;

  const PartDetailPage({
    super.key,
    required this.partId,
    required this.partName,
    required this.status,
    required this.productId,
    required this.productName,
    required this.cost,
    required this.borrowedEmployeeId,
  });

  Future<void> _deletePart(BuildContext context) async {
    if (globals.token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found')),
      );
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('http://172.191.111.81:8081/api/components/$partId'),
        headers: {
          'Authorization': globals.token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$partName deleted successfully')),
        );
        Navigator.of(context).pop(true); // Return success signal
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete part: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting part: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Part Detail', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Part ID', partId),
            _infoRow('Part Name', partName),
            _infoRow('Status', status),
            _infoRow('Product ID', productId),
            _infoRow('Product Name', productName),
            _infoRow('Cost', cost),
            _infoRow('Borrowed by', borrowedEmployeeId),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _confirmDelete(context),
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
                            (_) => EditPartPage(
                              partId: partId,
                              partName: partName,
                              status: status,
                              productId: productId,
                              productName: productName,
                              cost: cost,
                              borrowedEmployeeId: borrowedEmployeeId,
                            ),
                      ),
                    ).then((_) {
                      // Refresh data if returning from edit
                      Navigator.of(context).pop(true);
                    });
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Confirm Delete',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to delete "$partName"?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop(); // dismiss dialog
                  await _deletePart(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }
}
