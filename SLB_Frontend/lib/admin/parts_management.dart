import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../globals.dart' as globals;

import 'add_parts.dart';
import 'edit_part.dart';
import 'history_page.dart';

class PartManagementPage extends StatefulWidget {
  const PartManagementPage({super.key});

  @override
  State<PartManagementPage> createState() => _PartManagementPageState();
}

class _PartManagementPageState extends State<PartManagementPage> {
  final TextEditingController searchController = TextEditingController();
  final List<Map<String, dynamic>> _operationHistory = [];

  List<Map<String, dynamic>> parts = [];
  bool isLoading = true;
  String errorMessage = '';

  String searchQuery = '';
  Set<int> expandedRows = {};

  @override
  void initState() {
    super.initState();
    _fetchParts();
  }

  Future<void> _fetchParts() async {
    if (globals.token.isEmpty) {
      print("No token found");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://4.227.176.4:8081/api/components'),
        headers: {
          'Authorization': globals.token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          parts =
              data.map((item) {
                return {
                  'id': item['partId']?.toString() ?? '0',
                  'partNumber': item['partNumber']?.toString() ?? '0',
                  'name': item['partName'] ?? 'Unknown',
                  'status': item['status'] ?? 'available',
                  'cost': item['cost']?.toString() ?? '0',
                  'productId': item['productId']?.toString() ?? '0',
                  'borrowedEmployeeId':
                      item['borrowedEmployeeId']?.toString() ?? '0',
                };
              }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load parts: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching parts: $e';
        isLoading = false;
      });
    }
  }

  void _showHistory() async {
    final shouldClear = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(historyItems: _operationHistory),
      ),
    );

    if (shouldClear == true) {
      setState(() => _operationHistory.clear());
    }
  }

  void _addRangeOfProducts() {
    showDialog(
      context: context,
      builder:
          (context) => _AddRangeDialog(
            onAdd: (startId, endId, name, category, type) {
              final startNum = int.parse(startId.replaceAll('P', ''));
              final endNum = int.parse(endId.replaceAll('P', ''));

              if (startNum > endNum) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('End ID must be greater than Start ID'),
                  ),
                );
                return;
              }

              setState(() {
                for (int i = startNum; i <= endNum; i++) {
                  final id = 'P${i.toString().padLeft(3, '0')}';
                  parts.add({
                    'id': id,
                    'name': name,
                    'category': category,
                    'type': type,
                  });
                }

                _operationHistory.add({
                  'action': 'Added range',
                  'details':
                      'Added ${endNum - startNum + 1} parts ($startId-$endId)',
                  'timestamp': DateTime.now().toString(),
                  'params': {
                    'startId': startId,
                    'endId': endId,
                    'name': name,
                    'category': category,
                    'type': type,
                  },
                });
              });
            },
          ),
    );
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.GridView(
            crossAxisCount: 4,
            childAspectRatio: 1,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children:
                parts
                    .map(
                      (part) => pw.Container(
                        margin: pw.EdgeInsets.all(10),
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: part['id']!,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    )
                    .toList(),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'parts-qrcodes-${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredParts =
        parts.where((item) {
          final query = searchQuery.toLowerCase();
          return item['name']!.toLowerCase().contains(query) ||
              item['status']!.toLowerCase().contains(query) ||
              item['id']!.contains(query);
        }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Product / Part Management',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _showHistory,
          ),
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
              onChanged: (value) => setState(() => searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red))
            else if (parts.isEmpty)
              const Text(
                'No parts found',
                style: TextStyle(color: Colors.white),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredParts.length,
                  itemBuilder: (context, index) {
                    final part = filteredParts[index];
                    final isExpanded = expandedRows.contains(index);
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
                                part['status']!,
                                style: TextStyle(
                                  color:
                                      part['status'] == 'available'
                                          ? Colors.green
                                          : Colors.orange,
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
                              onPressed:
                                  () => setState(() {
                                    isExpanded
                                        ? expandedRows.remove(index)
                                        : expandedRows.add(index);
                                  }),
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
                                ElevatedButton(
                                  onPressed: () => _editPart(part, index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit, size: 16),
                                      SizedBox(width: 4),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () => _deletePart(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.delete, size: 16),
                                      SizedBox(width: 4),
                                      Text('Delete'),
                                    ],
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

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddPartPage()),
                      ).then((_) {
                        _fetchParts();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B544C),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Product',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addRangeOfProducts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C6BC0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Range',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editPart(Map<String, dynamic> part, int index) async {
    final editedPart = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EditPartPage(
              partNumber: int.tryParse(part['partNumber'] ?? '') ?? 0,
              partId: int.tryParse(part['id'] ?? '') ?? 0,
              partName: part['name'] ?? '',
              borrowedEmployeeId:
                  int.tryParse(part['borrowedEmployeeId'] ?? '') ?? 0,
              status: part['status'] ?? 'available',
              cost: int.tryParse(part['cost'] ?? '') ?? 0,
              productId: int.tryParse(part['productId'] ?? '') ?? 0,
            ),
      ),
    );

    if (editedPart != null) {
      try {
        setState(() {
          isLoading = true;
        });

        final response = await http.put(
          Uri.parse('http://4.227.176.4:8081/api/components/${part['id']}'),
          headers: {
            'Authorization': globals.token,
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'partNumber': editedPart['partNumber'],
            'partId': editedPart['partId'],
            'partName': editedPart['partName'],
            'borrowedEmployeeId':
                editedPart['borrowedEmployeeId'] == 0
                    ? null
                    : editedPart['borrowedEmployeeId'],
            'status': editedPart['status'],
            'cost': editedPart['cost'],
            'productId': editedPart['productId'],
          }),
        );

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          // Update the local state with the edited part
          setState(() {
            parts[index] = {
              'id': editedPart['partId'].toString(),
              'partNumber': editedPart['partNumber'].toString(),
              'name': editedPart['partName'],
              'status': editedPart['status'],
              'cost': editedPart['cost'].toString(),
              'productId': editedPart['productId'].toString(),
              'borrowedEmployeeId': editedPart['borrowedEmployeeId'].toString(),
            };
          });

          // Add to operation history
          _operationHistory.add({
            'action': 'Edited part',
            'details': 'Edited ${part['id']}',
            'timestamp': DateTime.now().toString(),
            'newData': editedPart,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Part updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update part: ${response.statusCode}'),
            ),
          );
          print('Response body: ${response.body}');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating part: $e')));
      }
    }
  }

  void _deletePart(int index) async {
    final partToDelete = parts[index];
    try {
      final response = await http.delete(
        Uri.parse(
          'http://4.227.176.4:8081/api/components/${partToDelete['id']}',
        ),
        headers: {
          'Authorization': globals.token, // Include JWT in header
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          parts.removeAt(index);
          _operationHistory.add({
            'action': 'Deleted part',
            'details': 'Deleted ${partToDelete['id']}',
            'timestamp': DateTime.now().toString(),
          });
        });
      } else {
        print(response.statusCode);
        throw Exception('Failed to delete part');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting part: $e')));
    }
  }
}

class _AddRangeDialog extends StatefulWidget {
  final Function(String, String, String, String, String) onAdd;

  const _AddRangeDialog({required this.onAdd});

  @override
  State<_AddRangeDialog> createState() => __AddRangeDialogState();
}

class __AddRangeDialogState extends State<_AddRangeDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startIdController = TextEditingController(
    text: 'P001',
  );
  final TextEditingController _endIdController = TextEditingController(
    text: 'P010',
  );
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String _selectedType = 'Part';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Range of Products',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _buildTextField(_startIdController, 'Start ID (e.g. P001)'),
              const SizedBox(height: 12),
              _buildTextField(_endIdController, 'End ID (e.g. P010)'),
              const SizedBox(height: 12),
              _buildTextField(_nameController, 'Part Name'),
              const SizedBox(height: 12),
              _buildTextField(_categoryController, 'Category'),
              const SizedBox(height: 12),
              _buildTypeDropdown(),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B544C),
                    ),
                    child: const Text('Confirm'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onAdd(
                          _startIdController.text,
                          _endIdController.text,
                          _nameController.text,
                          _categoryController.text,
                          _selectedType,
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF7B544C), width: 1),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      items:
          ['Product', 'Part']
              .map(
                (type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
              .toList(),
      onChanged: (String? value) {
        setState(() => _selectedType = value!);
      },
      dropdownColor: Colors.grey[800],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Type',
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _startIdController.dispose();
    _endIdController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
