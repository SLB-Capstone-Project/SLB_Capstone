import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

  List<Map<String, String>> parts = [
    {'id': 'P001', 'name': 'Gearbox', 'category': 'Mechanical', 'type': 'Product'},
    {'id': 'P002', 'name': 'Sensor', 'category': 'Electronics', 'type': 'Part'},
    {'id': 'P003', 'name': 'Valve', 'category': 'Hydraulics', 'type': 'Part'},
  ];

  String searchQuery = '';
  Set<int> expandedRows = {};

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
      builder: (context) => _AddRangeDialog(
        onAdd: (startId, endId, name, category, type) {
          final startNum = int.parse(startId.replaceAll('P', ''));
          final endNum = int.parse(endId.replaceAll('P', ''));

          if (startNum > endNum) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('End ID must be greater than Start ID')));
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
              'details': 'Added ${endNum - startNum + 1} parts ($startId-$endId)',
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
            children: parts.map((part) => pw.Container(
              margin: pw.EdgeInsets.all(10),
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: part['id']!,
                width: 30,
                height: 30,
              ),
            )).toList(),
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
    final filteredParts = parts.where((item) {
      final query = searchQuery.toLowerCase();
      return item['name']!.toLowerCase().contains(query) ||
          item['category']!.toLowerCase().contains(query) ||
          item['id']!.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Product / Part Management',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _showHistory,
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
                          Expanded(child: Text(part['id']!,
                              style: const TextStyle(color: Colors.white))),
                          Expanded(child: Text(part['name']!,
                              style: const TextStyle(color: Colors.white))),
                          Expanded(child: Text(part['type']!,
                              style: const TextStyle(color: Colors.white))),
                          IconButton(
                            icon: Icon(isExpanded ? Icons.expand_less : Icons.more_vert,
                                color: Colors.white70),
                            onPressed: () => setState(() {
                              isExpanded ? expandedRows.remove(index) : expandedRows.add(index);
                            }),
                          ),
                        ],
                      ),
                      if (isExpanded) Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 10),
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _editPart(part, index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    onPressed: () async {
                      final newPart = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddPartPage()),
                      );
                      if (newPart != null) {
                        setState(() {
                          parts.add(newPart);
                          _operationHistory.add({
                            'action': 'Added part',
                            'details': '${newPart['id']} (${newPart['name']})',
                            'timestamp': DateTime.now().toString(),
                            'params': newPart,
                          });
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B544C),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add Product',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    child: const Text('Add Range',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editPart(Map<String, String> part, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPartPage(
          id: part['id']!,
          name: part['name']!,
          category: part['category']!,
          type: part['type']!,
        ),
      ),
    ).then((_) {
      setState(() {
        _operationHistory.add({
          'action': 'Edited part',
          'details': 'Edited ${part['id']}',
          'timestamp': DateTime.now().toString(),
        });
      });
    });
  }

  void _deletePart(int index) {
    setState(() {
      final deletedPart = parts.removeAt(index);
      _operationHistory.add({
        'action': 'Deleted part',
        'details': 'Deleted ${deletedPart['id']}',
        'timestamp': DateTime.now().toString(),
      });
    });
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
  final TextEditingController _startIdController = TextEditingController(text: 'P001');
  final TextEditingController _endIdController = TextEditingController(text: 'P010');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String _selectedType = 'Part';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Range of Products',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),

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
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white70)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B544C)),
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
      items: ['Product', 'Part'].map((type) => DropdownMenuItem<String>(
        value: type,
        child: Text(type, style: const TextStyle(color: Colors.white)),
      )).toList(),
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
