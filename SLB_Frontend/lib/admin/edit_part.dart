import 'package:flutter/material.dart';
import "../globals.dart" as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditPartPage extends StatefulWidget {
  final String partId;
  final String partName;
  final String status;
  final String productId;
  final String productName;
  final String cost;
  final String borrowedEmployeeId;

  const EditPartPage({
    super.key,
    required this.partId,
    required this.partName,
    required this.status,
    required this.productId,
    required this.productName,
    required this.cost,
    required this.borrowedEmployeeId,
  });

  @override
  State<EditPartPage> createState() => _EditPartPageState();
}

class _EditPartPageState extends State<EditPartPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController partNameController;
  late TextEditingController productIdController;
  late TextEditingController productNameController;
  late TextEditingController costController;
  late String selectedStatus;

  Future<void> _edit() async {
    if (globals.token == "") {
      print("No token found");
      return;
    }
    if (partNameController.text.isEmpty ||
        productIdController.text.isEmpty ||
        productNameController.text.isEmpty ||
        costController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("All fields are required"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String apiUrl =
        "http://172.191.111.81:8081/api/components/" + widget.partId;
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': globals.token, // Include JWT in header
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "partId": int.parse(widget.partId),
          "partName": partNameController.text,
          "status": selectedStatus,
          "productName": productNameController.text,
          "productId": int.parse(productIdController.text),
          "cost": costController.text,
          "borrowedEmployeeId": int.parse(widget.borrowedEmployeeId),
        }),
      );
      print(response.statusCode);
      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Edit Success!")));

        Navigator.pop(context);
      } else {
        print(responseBody);
        throw Exception('Failed to edit employees: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    partNameController = TextEditingController(text: widget.partName);
    productIdController = TextEditingController(text: widget.productId);
    productNameController = TextEditingController(text: widget.productName);
    costController = TextEditingController(text: widget.cost);
    selectedStatus = widget.status;
  }

  @override
  void dispose() {
    partNameController.dispose();
    productIdController.dispose();
    productNameController.dispose();
    costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Part', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField(
                controller: partNameController,
                label: 'Part Name',
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: productIdController,
                label: 'Product ID',
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: productNameController,
                label: 'Product Name',
              ),
              const SizedBox(height: 16),
              buildTextField(controller: costController, label: 'Cost'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                dropdownColor: Colors.grey[900],
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                items:
                    ['borrow-out', 'unavailable', 'available'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedStatus = value);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _edit,
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
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
