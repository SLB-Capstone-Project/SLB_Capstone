import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart' as globals;

class AddPartPage extends StatefulWidget {
  const AddPartPage({super.key});

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final TextEditingController partIdController = TextEditingController();
  final TextEditingController partNameController = TextEditingController();
  final TextEditingController productIdController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  String selectedStatus = "available";

  @override
  void dispose() {
    partIdController.dispose();
    partNameController.dispose();
    productIdController.dispose();
    productNameController.dispose();
    costController.dispose();
    super.dispose();
  }

  Future<void> _addPart() async {
    if (!_formKey.currentState!.validate()) return;
    if (globals.token.isEmpty) {
      _showErrorSnackbar("Authentication required. Please login again.");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse("http://172.191.111.81:8081/api/components"),
        headers: {
          'Authorization': globals.token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "partId": int.tryParse(partIdController.text) ?? 0,
          "partName": partNameController.text,
          "status": selectedStatus,
          "productId": int.tryParse(productIdController.text) ?? 0,
          "productName": productNameController.text,
          "cost": double.tryParse(costController.text) ?? 0.0,
          "borrowedEmployeeId": 0,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessSnackbar("Part added successfully!");
        Navigator.pop(context, true); // Return success signal
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Unknown error';
        throw Exception('Failed to add part: $error (${response.statusCode})');
      }
    } on FormatException catch (e) {
      _showErrorSnackbar("Invalid number format: ${e.message}");
    } on http.ClientException catch (e) {
      _showErrorSnackbar("Network error: ${e.message}");
    } catch (e) {
      _showErrorSnackbar("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Add Product / Part',
          style: TextStyle(color: Colors.white),
        ),
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
          child: ListView(
            children: [
              _buildNumberField(
                controller: partIdController,
                label: 'Part ID',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required field';
                  if (int.tryParse(value) == null) return 'Must be a number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: partNameController,
                label: 'Part Name',
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Required field'
                            : null,
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                controller: productIdController,
                label: 'Product ID',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required field';
                  if (int.tryParse(value) == null) return 'Must be a number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: productNameController,
                label: 'Product Name',
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Required field'
                            : null,
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                controller: costController,
                label: 'Cost',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required field';
                  if (double.tryParse(value) == null) return 'Invalid amount';
                  return null;
                },
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusDropdown(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _addPart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B544C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Add Part',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedStatus,
      dropdownColor: Colors.grey[900],
      decoration: InputDecoration(
        labelText: 'Status',
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      style: const TextStyle(color: Colors.white),
      items:
          ['available', 'unavailable', 'borrow-out']
              .map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
              .toList(),
      onChanged: (value) => setState(() => selectedStatus = value!),
    );
  }
}
