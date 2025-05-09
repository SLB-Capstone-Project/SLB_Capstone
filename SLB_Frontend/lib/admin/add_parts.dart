import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;

class AddPartPage extends StatefulWidget {
  const AddPartPage({super.key});

  @override
  State<AddPartPage> createState() => _AddPartPageState();
}

class _AddPartPageState extends State<AddPartPage> {
  final _formKey = GlobalKey<FormState>();

  final _partNumberController = TextEditingController();
  final _partIdController = TextEditingController();
  final _partNameController = TextEditingController();
  final _borrowedEmployeeIdController = TextEditingController();
  final _costController = TextEditingController();
  final _productIdController = TextEditingController();

  String _status = 'available';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Add Part', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_partNumberController, 'Part Number'),
              const SizedBox(height: 16),
              _buildTextField(_partIdController, 'Part ID'),
              const SizedBox(height: 16),
              _buildTextField(_partNameController, 'Part Name'),
              const SizedBox(height: 16),
              _buildTextField(_costController, 'Cost'),
              const SizedBox(height: 16),
              _buildTextField(_productIdController, 'Product ID'),
              const SizedBox(height: 16),
              _buildStatusDropdown(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B544C),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Add', style: TextStyle(color: Colors.white)),
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
      keyboardType: TextInputType.numberWithOptions(
        signed: false,
        decimal: false,
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
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
      value: _status,
      items:
          ['available', 'borrow-out']
              .map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
              .toList(),
      onChanged: (value) => setState(() => _status = value!),
      decoration: InputDecoration(
        labelText: 'Status',
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dropdownColor: Colors.grey[900],
    );
  }

  void _submitForm() async {
    if (globals.token == "") {
      print("No token found");
      return;
    }
    if (_formKey.currentState!.validate()) {
      final partData = {
        "partNumber": int.parse(_partNumberController.text),
        "partId": int.parse(_partIdController.text),
        "partName": _partNameController.text,
        "borrowedEmployeeId":
            _borrowedEmployeeIdController.text.isEmpty
                ? null
                : int.parse(_borrowedEmployeeIdController.text),
        "status": _status,
        "cost": int.parse(_costController.text),
        "productId": int.parse(_productIdController.text),
      };

      final url = Uri.parse('http://4.227.176.4:8081/api/components');

      try {
        final response = await http.post(
          url,
          headers: {
            'Authorization': globals.token, // Include JWT in header
            'Content-Type': 'application/json',
          },
          body: jsonEncode(partData),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          Navigator.pop(context);
        } else {
          _showErrorDialog(
            'Failed to add part. Status code: ${response.statusCode}',
          );
        }
      } catch (e) {
        _showErrorDialog('Failed to connect to the server: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _partNumberController.dispose();
    _partIdController.dispose();
    _partNameController.dispose();
    _borrowedEmployeeIdController.dispose();
    _costController.dispose();
    _productIdController.dispose();
    super.dispose();
  }
}
